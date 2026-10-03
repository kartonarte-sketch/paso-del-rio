import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/local_database.dart';
import '../models/document_record.dart';

class FirebaseRestSync {
  FirebaseRestSync(this._database);

  final LocalDatabase _database;
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const email = String.fromEnvironment('FIREBASE_EMAIL');
  static const password = String.fromEnvironment('FIREBASE_PASSWORD');
  String? _idToken;

  bool get configured =>
      projectId.isNotEmpty &&
      apiKey.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty;

  Future<bool> sync() async {
    if (!configured) return false;
    _idToken ??= await _signIn();
    final pending = await _database.pendingOutbox(limit: 100);
    final acknowledged = <String>[];
    for (final row in pending) {
      final record = DocumentRecord.fromMap(row);
      final eventId = row['event_id']! as String;
      final encodedCollection = Uri.encodeComponent(record.collection);
      final encodedId = Uri.encodeComponent(record.id);
      final uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/restaurants/paso-del-rio/$encodedCollection/$encodedId',
      );
      final response = record.deleted
          ? await http.delete(uri, headers: _headers())
          : await http.patch(
              uri,
              headers: _headers(),
              body: jsonEncode({
                'fields': _encodeMap({
                  ...record.data,
                  '_updatedAt': record.updatedAt.toUtc().toIso8601String(),
                  '_deviceId': record.deviceId,
                }),
              }),
            );
      if (response.statusCode == 401) {
        _idToken = null;
        return false;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      acknowledged.add(eventId);
    }
    await _database.acknowledgeOutbox(acknowledged);
    return acknowledged.isNotEmpty;
  }

  Future<String> _signIn() async {
    final response = await http.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
      ),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    if (response.statusCode != 200) {
      throw StateError('Firebase Auth rechazó el usuario de sincronización.');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['idToken']
        as String;
  }

  Map<String, String> _headers() => {
    'authorization': 'Bearer $_idToken',
    'content-type': 'application/json',
  };

  Map<String, dynamic> _encodeMap(Map<String, dynamic> value) =>
      value.map((key, item) => MapEntry(key, _encodeValue(item)));

  Map<String, dynamic> _encodeValue(dynamic value) {
    if (value == null) return {'nullValue': null};
    if (value is bool) return {'booleanValue': value};
    if (value is int) return {'integerValue': '$value'};
    if (value is double) return {'doubleValue': value};
    if (value is String) return {'stringValue': value};
    if (value is List) {
      return {
        'arrayValue': {'values': value.map(_encodeValue).toList()},
      };
    }
    if (value is Map) {
      return {
        'mapValue': {'fields': _encodeMap(Map<String, dynamic>.from(value))},
      };
    }
    return {'stringValue': '$value'};
  }
}
