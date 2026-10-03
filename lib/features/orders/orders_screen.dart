import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _tableId;
  String? _category;
  final Map<MenuProduct, int> _cart = {};

  int get _total => _cart.entries.fold(
    0,
    (sum, entry) => sum + entry.key.price * entry.value,
  );

  Future<void> _send(AppState state) async {
    final table = state.tables.where((item) => item.id == _tableId).firstOrNull;
    if (table == null || _cart.isEmpty) return;
    await state.sendOrder(table: table, quantities: _cart);
    if (!mounted) return;
    setState(() => _cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comanda enviada a producción')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final occupied = state.tables
        .where((table) => table.status == 'occupied')
        .toList();
    if (_tableId != null && !occupied.any((table) => table.id == _tableId)) {
      _tableId = null;
    }
    _tableId ??= occupied.firstOrNull?.id;
    final categories = state.products
        .map((product) => product.category)
        .toSet()
        .toList();
    _category ??= categories.firstOrNull;
    final menu = state.products
        .where((product) => product.active && product.category == _category)
        .toList();
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    final menuPanel = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tableId,
              decoration: const InputDecoration(labelText: 'Mesa ocupada'),
              items: occupied
                  .map(
                    (table) => DropdownMenuItem(
                      value: table.id,
                      child: Text('M${table.number} · ${table.groupName}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _tableId = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  final product = menu[index];
                  final quantity = _cart[product] ?? 0;
                  return ListTile(
                    enabled: product.stock > 0,
                    contentPadding: EdgeInsets.zero,
                    title: Text(product.name),
                    subtitle: Text(
                      '${money.format(product.price)} · Stock ${product.stock}',
                    ),
                    trailing: quantity == 0
                        ? IconButton(
                            onPressed: () => setState(() => _cart[product] = 1),
                            icon: const Icon(Icons.add_circle),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => setState(() {
                                  if (quantity == 1) {
                                    _cart.remove(product);
                                  } else {
                                    _cart[product] = quantity - 1;
                                  }
                                }),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: quantity >= product.stock
                                    ? null
                                    : () => setState(
                                        () => _cart[product] = quantity + 1,
                                      ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    final cartPanel = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pedido', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Agrega productos de la carta.'))
                  : ListView(
                      children: _cart.entries
                          .map(
                            (entry) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(entry.key.name),
                              subtitle: Text(
                                '${entry.value} × ${money.format(entry.key.price)}',
                              ),
                              trailing: Text(
                                money.format(entry.key.price * entry.value),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${money.format(_total)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _tableId == null || _cart.isEmpty
                      ? null
                      : () => _send(state),
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 850) {
            return Column(
              children: [
                Expanded(flex: 3, child: menuPanel),
                const SizedBox(height: 12),
                Expanded(flex: 2, child: cartPanel),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: menuPanel),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: cartPanel),
            ],
          );
        },
      ),
    );
  }
}
