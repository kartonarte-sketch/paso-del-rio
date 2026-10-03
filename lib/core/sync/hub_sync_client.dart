import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/local_database.dart';
import '../models/document_record.dart';

class HubSyncClient {
  HubSyncClient(this._database, {required this.baseUrl, required this.secret});

  final LocalDatabase _database;
  final String baseUrl;
  final String secret;

  Future<bool> sync() async {
    final outbox = await _database.pendingOutbox();
    final cursor =
        int.tryParse(await _database.readMetadata('hub_cursor') ?? '0') ?? 0;
    final events = outbox.map((row) {
      final eventId = row['event_id']! as String;
      return {
        'eventId': eventId,
        'record': DocumentRecord.fromMap(row).toWire(),
      };
    }).toList();
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/v1/sync'),
          headers: {'content-type': 'application/json', 'x-hub-secret': secret},
          body: jsonEncode({
            'deviceId': _database.deviceId,
            'cursor': cursor,
            'events': events,
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    await _database.acknowledgeOutbox(
      (body['acknowledged'] as List).cast<String>(),
    );
    var changed = false;
    for (final raw in body['changes'] as List) {
      final change = Map<String, dynamic>.from(raw as Map);
      final record = DocumentRecord.fromWire(
        Map<String, dynamic>.from(change['record'] as Map),
      );
      changed =
          await _database.put(record, addToOutbox: false, addToHubLog: false) ||
          changed;
    }
    await _database.writeMetadata('hub_cursor', '${body['cursor']}');
    return changed;
  }
}
