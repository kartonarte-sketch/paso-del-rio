import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/data/local_database.dart';
import 'core/data/restaurant_repository.dart';
import 'core/platform/os_info.dart';
import 'core/sync/hub_server.dart';
import 'core/sync/sync_coordinator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = LocalDatabase();
  await database.open();
  final repository = RestaurantRepository(database);
  await repository.seedIfEmpty();
  final appState = AppState(repository);
  await appState.initialize();

  if (!kIsWeb && isWindowsDesktop) {
    await HubServer(database).start();
  }
  SyncCoordinator(database, appState).start();

  runApp(
    ChangeNotifierProvider.value(value: appState, child: const PasoDelRioRoot()),
  );
}

class PasoDelRioRoot extends StatefulWidget {
  const PasoDelRioRoot({super.key});

  @override
  State<PasoDelRioRoot> createState() => _PasoDelRioRootState();
}

class _PasoDelRioRootState extends State<PasoDelRioRoot> {
  bool _showSplash = true;
  AudioPlayer? _audioPlayer;

  void _skipSplash() {
    if (!_showSplash) return;
    _audioPlayer?.stop();
    setState(() {
      _showSplash = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initAudioAndPlay();
    
    final splashDuration = kIsWeb ? const Duration(seconds: 2) : const Duration(seconds: 4);
    Future.delayed(splashDuration, () {
      if (mounted) {
        _skipSplash();
      }
    });
  }

  Future<void> _initAudioAndPlay() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.play(AssetSource('audio/nature_ambience.mp3'));
    } catch (e) {
      debugPrint('No se pudo reproducir el audio de fondo automáticamente: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skipSplash,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logotipo institucional limpio y sin textos adicionales
                    Image.asset(
                      'assets/images/Logo 02.jpg',
                      width: 320,
                      height: 320,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.eco, size: 100, color: Color(0xFF1B4D3E));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return App();
  }
}