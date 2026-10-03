import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app/app_state.dart';
import '../data/local_database.dart';
import 'firebase_rest_sync.dart';
import 'hub_sync_client.dart';

class SyncCoordinator {
  SyncCoordinator(this.database, this.state);

  final LocalDatabase database;
  final AppState state;
  Timer? _timer;
  bool _running = false;

  static const hubUrl = String.fromEnvironment('HUB_URL');
  static const hubSecret = String.fromEnvironment(
    'HUB_SECRET',
    defaultValue: 'cambiar-este-secreto',
  );

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _tick());
    unawaited(_tick());
  }

  Future<void> _tick() async {
    if (_running) return;
    _running = true;
    try {
      var changed = false;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        changed = await FirebaseRestSync(database).sync();
      } else if (!kIsWeb && hubUrl.isNotEmpty) {
        changed = await HubSyncClient(
          database,
          baseUrl: hubUrl,
          secret: hubSecret,
        ).sync();
      }
      if (changed) await state.refresh();
    } catch (_) {
      // La cola local conserva las operaciones; se reintenta en el próximo ciclo.
    } finally {
      _running = false;
    }
  }
}
