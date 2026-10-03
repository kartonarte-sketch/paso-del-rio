import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../data/local_database.dart';
import '../models/document_record.dart';

class HubServer {
  HubServer(this._database);

  final LocalDatabase _database;
  HttpServer? _server;
  static const port = 8787;
  static const _secret = String.fromEnvironment(
    'HUB_SECRET',
    defaultValue: 'cambiar-este-secreto',
  );

  Future<void> start() async {
    if (_server != null) return;
    final router = Router()
      ..get('/api/v1/health', _health)
      ..post('/api/v1/sync', _sync);
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_cors())
        .addHandler(router.call);
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  }

  Response _health(Request request) => _json({
    'service': 'paso-del-rio-hub',
    'status': 'ok',
    'deviceId': _database.deviceId,
  });

  Future<Response> _sync(Request request) async {
    if (request.headers['x-hub-secret'] != _secret) {
      return _json({'error': 'unauthorized'}, status: HttpStatus.unauthorized);
    }
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final cursor = body['cursor'] as int? ?? 0;
      final events = body['events'] as List? ?? const [];
      final acknowledged = <String>[];
      for (final raw in events) {
        final event = Map<String, dynamic>.from(raw as Map);
        final record = DocumentRecord.fromWire(
          Map<String, dynamic>.from(event['record'] as Map),
        );
        await _database.put(record, addToOutbox: true, addToHubLog: true);
        acknowledged.add(event['eventId'] as String);
      }
      final changes = await _database.changesAfter(cursor);
      final records = changes.map((row) {
        final record = DocumentRecord.fromMap(row);
        return {'sequence': row['sequence'], 'record': record.toWire()};
      }).toList();
      return _json({
        'acknowledged': acknowledged,
        'cursor': await _database.latestSequence(),
        'changes': records,
      });
    } catch (error) {
      return _json({
        'error': 'invalid_request',
        'detail': '$error',
      }, status: HttpStatus.badRequest);
    }
  }

  Middleware _cors() =>
      (innerHandler) => (request) async {
        if (request.method == 'OPTIONS') return _withCors(Response.ok(''));
        return _withCors(await innerHandler(request));
      };

  Response _withCors(Response response) => response.change(
    headers: {
      ...response.headers,
      'access-control-allow-origin': '*',
      'access-control-allow-headers': 'content-type,x-hub-secret',
    },
  );

  Response _json(Object body, {int status = 200}) => Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
