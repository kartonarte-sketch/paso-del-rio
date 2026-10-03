import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class CashScreen extends StatelessWidget {
  const CashScreen({super.key});

  Future<void> _settle(
    BuildContext context,
    DiningTable table,
    int total,
  ) async {
    final state = context.read<AppState>();
    var method = 'Efectivo';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Cobrar mesa M${table.number}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'es_CO',
                  symbol: r'$ ',
                  decimalDigits: 0,
                ).format(total),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items:
                    [
                          'Efectivo',
                          'Nequi / Daviplata',
                          'Transferencia',
                          'Tarjeta',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => method = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirmar pago'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) await state.settleTable(table, method);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    final billedTables = state.tables
        .where(
          (table) => state.orders.any(
            (order) => order.tableId == table.id && !order.paid,
          ),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.payments)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ingresos registrados hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  money.format(state.incomeToday),
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (billedTables.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No hay cuentas pendientes.')),
            ),
          ),
        ...billedTables.map((table) {
          final orders = state.orders
              .where((order) => order.tableId == table.id && !order.paid)
              .toList();
          final total = orders.fold(0, (sum, order) => sum + order.total);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Text('M${table.number}')),
              title: Text(table.groupName ?? 'Mesa M${table.number}'),
              subtitle: Text('${orders.length} comandas'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    money.format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _settle(context, table, total),
                    child: const Text('Cobrar'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
