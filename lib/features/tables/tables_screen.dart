import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  Future<void> _tapTable(BuildContext context, DiningTable table) async {
    final state = context.read<AppState>();
    if (table.status == 'occupied') {
      final orders = state.orders.where(
        (order) => order.tableId == table.id && !order.paid,
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Mesa M${table.number}'),
          content: Text(
            '${table.groupName ?? 'Grupo'}\nCuenta pendiente: ${orders.length} comandas',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }
    final available = state.groups
        .where((group) => group.active && group.tableId == null)
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay grupos pendientes de mesa.')),
      );
      return;
    }
    GuestGroup selected = available.first;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Asignar mesa M${table.number}'),
          content: DropdownButtonFormField<GuestGroup>(
            initialValue: selected,
            decoration: const InputDecoration(labelText: 'Grupo'),
            items: available
                .map(
                  (group) => DropdownMenuItem(
                    value: group,
                    child: Text(
                      '${group.leader} (${group.adults + group.minors})',
                    ),
                  ),
                )
                .toList(),
            onChanged: (group) => setState(() => selected = group!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) await state.assignTable(table, selected);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 150,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.tables.length,
      itemBuilder: (context, index) {
        final table = state.tables[index];
        final occupied = table.status == 'occupied';
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _tapTable(context, table),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 34,
                    color: occupied
                        ? Colors.orange.shade800
                        : Colors.green.shade700,
                  ),
                  Text(
                    'M${table.number}',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    occupied ? 'OCUPADA' : 'LIBRE',
                    style: TextStyle(
                      color: occupied
                          ? Colors.orange.shade800
                          : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (table.groupName != null)
                    Text(
                      table.groupName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
