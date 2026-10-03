import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/login_screen.dart';
import '../features/shell/app_shell.dart';
import '../core/theme/app_theme.dart';
import 'app_state.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paso del Río - Eco Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select((AppState state) => state.role != null);
    return loggedIn ? const AppShell() : const LoginScreen();
  }
}
