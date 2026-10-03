import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class BarScreen extends StatefulWidget {
  const BarScreen({super.key});

  @override
  State<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends State<BarScreen> {
  final Map<MenuProduct, int> cart = {};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final products = state.products
        .where((product) => product.destination == 'barra' && product.active)
        .toList();
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    final total = cart.entries.fold(
      0,
      (sum, entry) => sum + entry.key.price * entry.value,
    );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final catalog = Card(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final quantity = cart[product] ?? 0;
                return ListTile(
                  enabled: product.stock > 0,
                  title: Text(product.name),
                  subtitle: Text(
                    '${money.format(product.price)} · ${product.stock} uds',
                  ),
                  trailing: quantity == 0
                      ? IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () => setState(() => cart[product] = 1),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => setState(() {
                                if (quantity == 1) {
                                  cart.remove(product);
                                } else {
                                  cart[product] = quantity - 1;
                                }
                              }),
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: quantity >= product.stock
                                  ? null
                                  : () => setState(
                                      () => cart[product] = quantity + 1,
                                    ),
                            ),
                          ],
                        ),
                );
              },
            ),
          );
          final checkout = Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Venta rápida',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text('Carrito vacío'))
                        : ListView(
                            children: cart.entries
                                .map(
                                  (entry) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(entry.key.name),
                                    trailing: Text(
                                      '${entry.value} × ${money.format(entry.key.price)}',
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const Divider(),
                  Text(
                    'Total ${money.format(total)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: cart.isEmpty
                        ? null
                        : () async {
                            await state.quickBarSale(cart);
                            if (mounted) setState(cart.clear);
                          },
                    icon: const Icon(Icons.payments),
                    label: const Text('Cobrar en efectivo'),
                  ),
                ],
              ),
            ),
          );
          if (constraints.maxWidth < 780) {
            return Column(
              children: [
                Expanded(flex: 3, child: catalog),
                const SizedBox(height: 12),
                Expanded(flex: 2, child: checkout),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: catalog),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: checkout),
            ],
          );
        },
      ),
    );
  }
}
