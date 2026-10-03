import 'dart:io';

import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../models/document_record.dart';

class LocalDatabase {
  late final Database _database;
  late final String deviceId;

  Database get raw => _database;

  Future<void> open() async {
    final DatabaseFactory factory;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    } else {
      factory = mobile.databaseFactory;
    }
    final supportDirectory = await getApplicationSupportDirectory();
    await Directory(supportDirectory.path).create(recursive: true);
    final databasePath = path_util.join(
      supportDirectory.path,
      'paso_del_rio.db',
    );
    _database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE documents (
              collection_name TEXT NOT NULL,
              document_id TEXT NOT NULL,
              data_json TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              device_id TEXT NOT NULL,
              deleted INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY (collection_name, document_id)
            )
          ''');
          await db.execute('''
            CREATE TABLE outbox (
              event_id TEXT PRIMARY KEY,
              collection_name TEXT NOT NULL,
              document_id TEXT NOT NULL,
              data_json TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              device_id TEXT NOT NULL,
              deleted INTEGER NOT NULL DEFAULT 0,
              attempts INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE hub_changes (
              sequence INTEGER PRIMARY KEY AUTOINCREMENT,
              collection_name TEXT NOT NULL,
              document_id TEXT NOT NULL,
              data_json TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              device_id TEXT NOT NULL,
              deleted INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE metadata (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_documents_collection ON documents(collection_name, deleted)',
          );
          await db.execute(
            'CREATE INDEX idx_hub_changes_sequence ON hub_changes(sequence)',
          );
        },
      ),
    );
    final rows = await _database.query(
      'metadata',
      where: 'key = ?',
      whereArgs: ['device_id'],
      limit: 1,
    );
    if (rows.isEmpty) {
      deviceId = const Uuid().v4();
      await _database.insert('metadata', {
        'key': 'device_id',
        'value': deviceId,
      });
    } else {
      deviceId = rows.first['value']! as String;
    }
  }

  Future<bool> put(
    DocumentRecord record, {
    bool addToOutbox = true,
    bool addToHubLog = true,
  }) async {
    return _database.transaction((transaction) async {
      final current = await transaction.query(
        'documents',
        where: 'collection_name = ? AND document_id = ?',
        whereArgs: [record.collection, record.id],
        limit: 1,
      );
      if (current.isNotEmpty) {
        final existing = DocumentRecord.fromMap(current.first);
        final compare = record.updatedAt.compareTo(existing.updatedAt);
        if (compare < 0 ||
            (compare == 0 &&
                record.deviceId.compareTo(existing.deviceId) <= 0)) {
          return false;
        }
      }

      await transaction.insert(
        'documents',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (addToOutbox) {
        await transaction.insert('outbox', {
          'event_id': const Uuid().v4(),
          ...record.toMap(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      if (addToHubLog) {
        await transaction.insert('hub_changes', record.toMap());
      }
      return true;
    });
  }

  Future<List<DocumentRecord>> list(
    String collection, {
    bool includeDeleted = false,
  }) async {
    final rows = await _database.query(
      'documents',
      where: includeDeleted
          ? 'collection_name = ?'
          : 'collection_name = ? AND deleted = 0',
      whereArgs: [collection],
      orderBy: 'updated_at DESC',
    );
    return rows.map(DocumentRecord.fromMap).toList();
  }

  Future<List<DocumentRecord>> allDocuments() async {
    final rows = await _database.query('documents', orderBy: 'updated_at');
    return rows.map(DocumentRecord.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> pendingOutbox({int limit = 200}) =>
      _database.query('outbox', orderBy: 'updated_at', limit: limit);

  Future<void> acknowledgeOutbox(Iterable<String> eventIds) async {
    if (eventIds.isEmpty) return;
    await _database.transaction((transaction) async {
      for (final id in eventIds) {
        await transaction.delete(
          'outbox',
          where: 'event_id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<List<Map<String, Object?>>> changesAfter(int sequence) =>
      _database.query(
        'hub_changes',
        where: 'sequence > ?',
        whereArgs: [sequence],
        orderBy: 'sequence',
        limit: 1000,
      );

  Future<int> latestSequence() async {
    final value = await _database.rawQuery(
      'SELECT COALESCE(MAX(sequence), 0) AS sequence FROM hub_changes',
    );
    return value.first['sequence']! as int;
  }

  Future<int> count(String collection) async {
    final value = await _database.rawQuery(
      'SELECT COUNT(*) AS count FROM documents WHERE collection_name = ? AND deleted = 0',
      [collection],
    );
    return value.first['count']! as int;
  }

  Future<String?> readMetadata(String key) async {
    final rows = await _database.query(
      'metadata',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value']! as String;
  }

  Future<void> writeMetadata(String key, String value) => _database.insert(
    'metadata',
    {'key': key, 'value': value},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
