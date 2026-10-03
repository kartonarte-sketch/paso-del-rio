import 'dart:convert';
import 'dart:html' as html;
import 'package:uuid/uuid.dart';

import '../models/document_record.dart';

class LocalDatabase {
  final Map<String, Map<String, DocumentRecord>> _documents = {};
  final List<Map<String, Object?>> _outbox = [];
  final List<Map<String, Object?>> _hubChanges = [];
  final Map<String, String> _metadata = {};
  late final String deviceId;
  int _sequence = 0;

  Future<void> open() async {
    _loadFromLocalStorage();
    deviceId = _metadata.putIfAbsent('device_id', () => const Uuid().v4());
    _saveToLocalStorage();
  }

  void _loadFromLocalStorage() {
    try {
      final rawDocs = html.window.localStorage['pdr_pwa_docs'];
      if (rawDocs != null && rawDocs.isNotEmpty) {
        final decoded = jsonDecode(rawDocs) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final col = _documents.putIfAbsent(entry.key, () => {});
          final colData = entry.value as Map<String, dynamic>;
          for (final docEntry in colData.entries) {
            col[docEntry.key] = DocumentRecord.fromMap(
              Map<String, Object?>.from(docEntry.value as Map),
            );
          }
        }
      }
      final rawMeta = html.window.localStorage['pdr_pwa_meta'];
      if (rawMeta != null && rawMeta.isNotEmpty) {
        final decoded = jsonDecode(rawMeta) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _metadata[entry.key] = entry.value.toString();
        }
      }
    } catch (_) {}
  }

  void _saveToLocalStorage() {
    try {
      final rawDocs = <String, Map<String, dynamic>>{};
      for (final col in _documents.entries) {
        rawDocs[col.key] = col.value.map((k, v) => MapEntry(k, v.toMap()));
      }
      html.window.localStorage['pdr_pwa_docs'] = jsonEncode(rawDocs);
      html.window.localStorage['pdr_pwa_meta'] = jsonEncode(_metadata);
    } catch (_) {}
  }

  Future<bool> put(
    DocumentRecord record, {
    bool addToOutbox = true,
    bool addToHubLog = true,
  }) async {
    final collection = _documents.putIfAbsent(record.collection, () => {});
    final current = collection[record.id];
    if (current != null) {
      final compare = record.updatedAt.compareTo(current.updatedAt);
      if (compare < 0 ||
          (compare == 0 && record.deviceId.compareTo(current.deviceId) <= 0)) {
        return false;
      }
    }

    collection[record.id] = record;
    if (addToOutbox) {
      _outbox.add({'event_id': const Uuid().v4(), ...record.toMap()});
    }
    if (addToHubLog) {
      _sequence++;
      _hubChanges.add({'sequence': _sequence, ...record.toMap()});
    }
    _saveToLocalStorage();
    return true;
  }

  Future<List<DocumentRecord>> list(
    String collection, {
    bool includeDeleted = false,
  }) async {
    final rows = (_documents[collection] ?? const <String, DocumentRecord>{})
        .values
        .where((record) => includeDeleted || !record.deleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return rows;
  }

  Future<List<DocumentRecord>> allDocuments() async {
    final rows = _documents.values.expand((items) => items.values).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return rows;
  }

  Future<List<Map<String, Object?>>> pendingOutbox({int limit = 200}) async =>
      _outbox.take(limit).map(Map<String, Object?>.from).toList();

  Future<void> acknowledgeOutbox(Iterable<String> eventIds) async {
    final acknowledged = eventIds.toSet();
    _outbox.removeWhere((row) => acknowledged.contains(row['event_id']));
  }

  Future<List<Map<String, Object?>>> changesAfter(int sequence) async =>
      _hubChanges
          .where((row) => (row['sequence']! as int) > sequence)
          .take(1000)
          .map(Map<String, Object?>.from)
          .toList();

  Future<int> latestSequence() async => _sequence;

  Future<int> count(String collection) async =>
      (_documents[collection] ?? const <String, DocumentRecord>{})
          .values
          .where((record) => !record.deleted)
          .length;

  Future<String?> readMetadata(String key) async => _metadata[key];

  Future<void> writeMetadata(String key, String value) async {
    _metadata[key] = value;
    _saveToLocalStorage();
  }
}
