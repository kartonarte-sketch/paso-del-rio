import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final occupied = state.tables
        .where((table) => table.status == 'occupied')
        .length;
    final pending = state.orders
        .where((order) => order.status != 'delivered')
        .length;
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    return RefreshIndicator(
      onRefresh: state.refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resumen de hoy',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 1050 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _StatCard(
                'Personas',
                '${state.peopleToday}',
                Icons.groups_outlined,
              ),
              _StatCard(
                'Mesas ocupadas',
                '$occupied/${state.tables.length}',
                Icons.table_restaurant,
              ),
              _StatCard(
                'Comandas activas',
                '$pending',
                Icons.soup_kitchen_outlined,
              ),
              _StatCard(
                'Ingresos',
                money.format(state.incomeToday),
                Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad reciente',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (state.orders.isEmpty && state.groups.isEmpty)
                    const Text('Aún no hay movimientos registrados.')
                  else ...[
                    ...state.orders
                        .take(6)
                        .map(
                          (order) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.receipt_long),
                            ),
                            title: Text(
                              '${order.tableLabel} · ${order.lines.length} productos',
                            ),
                            subtitle: Text(
                              DateFormat('dd/MM HH:mm')
                                  .format(order.createdAt.toLocal()),
                            ),
                            trailing: Text(money.format(order.total)),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.mint,
              child: Icon(icon, color: AppColors.forest),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
