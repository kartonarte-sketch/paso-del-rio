import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_sections.dart';
import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';
import '../../core/theme/app_theme.dart';
import '../admin/admin_screen.dart';
import '../bar/bar_screen.dart';
import '../cash/cash_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../events/events_screen.dart';
import '../orders/orders_screen.dart';
import '../packages/packages_screen.dart';
import '../production/production_screen.dart';
import '../reception/reception_screen.dart';
import '../reservations/reservations_screen.dart';
import '../tables/tables_screen.dart';

const _sectionPages = <Widget>[
  DashboardScreen(),
  ReceptionScreen(),
  PackagesScreen(),
  ReservationsScreen(),
  EventsScreen(),
  TablesScreen(),
  OrdersScreen(),
  ProductionScreen(),
  CashScreen(),
  BarScreen(),
  AdminScreen(),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  void _logout(BuildContext context) {
    context.read<AppState>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        
        // Contenido principal con la marca de agua institucional más visible en el fondo
        final contentWithWatermark = Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.16, // Aumentada ligeramente para que se note mejor
                child: Image.asset(
                  'assets/images/Logo 02.jpg',
                  width: 500,
                  height: 500,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IndexedStack(
              index: state.sectionIndex,
              children: _sectionPages,
            ),
          ],
        );

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                // Barra lateral personalizada (Estilo idéntico a tu referencia de texto amarillo)
                Container(
                  width: 260,
                  color: AppColors.forest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cabecera institucional con texto en amarillo/dorado y sin logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        color: const Color(0xFF143B30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Paso del Río',
                              style: TextStyle(
                                color: Color(0xFFE5C158), // Tono amarillo/dorado característico
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'ECO HOTEL & RESTAURANTE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Opciones del menú lateral
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: state.allowedSections.map((index) {
                            final destination = kAppSections[index];
                            final isSelected = state.sectionIndex == index;
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                selected: isSelected,
                                selectedTileColor: Colors.white.withValues(alpha: 0.12),
                                leading: Icon(
                                  destination.icon,
                                  color: isSelected ? const Color(0xFFE5C158) : Colors.white70,
                                ),
                                title: Text(
                                  destination.label,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFFE5C158) : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () => state.selectSection(index),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Botón inferior de salida
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Cerrar sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scaffold(
                    appBar: _appBar(context, state),
                    body: contentWithWatermark,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: _appBar(context, state),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Paso del Río', style: TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold)),
                    subtitle: Text(state.role?.label ?? ''),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: state.allowedSections.map((index) {
                        final destination = kAppSections[index];
                        return ListTile(
                          selected: state.sectionIndex == index,
                          leading: Icon(destination.icon),
                          title: Text(destination.label),
                          onTap: () {
                            state.selectSection(index);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
          body: contentWithWatermark,
        );
      },
    );
  }

  AppBar _appBar(BuildContext context, AppState state) {
    return AppBar(
      title: Text(kAppSections[state.sectionIndex].label),
      actions: [
        const Icon(Icons.cloud_done_outlined, size: 18),
        const SizedBox(width: 6),
        const Text('Guardado local'),
        const SizedBox(width: 14),
        Chip(
          visualDensity: VisualDensity.compact,
          label: Text(kIsWeb ? 'PWA' : 'Local'),
        ),
        const SizedBox(width: 8),
        Chip(label: Text(state.role?.label ?? '')),
        const SizedBox(width: 12),
      ],
    );
  }
}