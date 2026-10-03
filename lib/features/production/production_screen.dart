import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  String destination = 'cocina';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final orders = state.orders
        .where(
          (order) =>
              order.status != 'delivered' &&
              order.lines.any((line) => line.destination == destination),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'cocina',
                label: Text('Cocina'),
                icon: Icon(Icons.soup_kitchen),
              ),
              ButtonSegment(
                value: 'barra',
                label: Text('Barra'),
                icon: Icon(Icons.local_bar),
              ),
            ],
            selected: {destination},
            onSelectionChanged: (value) =>
                setState(() => destination = value.first),
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? const Center(child: Text('Sin pedidos pendientes.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 285,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _OrderTicket(
                    order: orders[index],
                    destination: destination,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderTicket extends StatelessWidget {
  const _OrderTicket({required this.order, required this.destination});
  final RestaurantOrder order;
  final String destination;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final nextStatus = switch (order.status) {
      'pending' => 'in-progress',
      'in-progress' => 'ready',
      _ => 'delivered',
    };
    final buttonLabel = switch (order.status) {
      'pending' => 'Iniciar',
      'in-progress' => 'Marcar listo',
      _ => 'Entregado',
    };
    final lines = order.lines.where((line) => line.destination == destination);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: order.status == 'pending'
                ? Colors.orange.shade100
                : Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      order.tableLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Chip(label: Text(order.status)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: lines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${line.quantity} × ${line.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () => state.updateOrderStatus(order, nextStatus),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
