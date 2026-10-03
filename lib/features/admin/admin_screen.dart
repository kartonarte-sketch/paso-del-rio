import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Carta e inventario'),
              Tab(text: 'Paquetes'),
              Tab(text: 'Sistema y sincronización'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _InventoryTab(money: money),
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: state.packages
                      .map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.confirmation_number_outlined),
                            ),
                            title: Text(item.name),
                            subtitle: Text(item.includes),
                            trailing: Text(
                              '${money.format(item.priceAdult)} adulto\n${money.format(item.priceMinor)} menor',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _InfoCard(
                      icon: Icons.dns_outlined,
                      title: 'Servidor local Windows',
                      text: 'Activo en el puerto 8787. Los teléfonos funcionan en la misma red Wi-Fi aunque el proveedor de Internet esté caído.',
                    ),
                    const SizedBox(height: 12),
                    const _InfoCard(
                      icon: Icons.storage_outlined,
                      title: 'Base local SQLite',
                      text: 'Cada operación se confirma primero en el equipo. La cola de salida evita perder ventas, comandas o pagos.',
                    ),
                    const SizedBox(height: 12),
                    const _InfoCard(
                      icon: Icons.cloud_outlined,
                      title: 'Firebase / Firestore',
                      text: 'La estructura, reglas y sincronizador están preparados. Falta vincular el ID y las credenciales del proyecto Firebase del propietario.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab({required this.money});

  final NumberFormat money;

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  final _searchController = TextEditingController();
  String _category = 'Todas';
  String _destination = 'Todos';
  bool _showInactive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _adjustStock(MenuProduct product, int delta) async {
    final nextStock = (product.stock + delta).clamp(0, 999999).toInt();
    await context.read<AppState>().saveProduct(
      product.copyWith(stock: nextStock),
    );
  }

  Future<void> _toggleActive(MenuProduct product) async {
    await context.read<AppState>().saveProduct(
      product.copyWith(active: !product.active),
    );
  }

  Future<void> _openProductDialog([MenuProduct? product]) async {
    final state = context.read<AppState>();
    final saved = await showDialog<MenuProduct>(
      context: context,
      builder: (_) => _ProductDialog(
        product: product,
        categories: state.products
            .map((item) => item.category)
            .toSet()
            .toList()
          ..sort(),
        destinations: state.products
            .map((item) => item.destination)
            .toSet()
            .toList()
          ..sort(),
      ),
    );
    if (saved == null) return;

    final nextProduct = product == null
        ? MenuProduct(
            id: state.repository.nextId(),
            name: saved.name,
            category: saved.category,
            destination: saved.destination,
            price: saved.price,
            cost: saved.cost,
            stock: saved.stock,
            active: saved.active,
          )
        : saved;
    await state.saveProduct(nextProduct);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product == null ? 'Producto creado' : 'Producto actualizado',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;
    final categories = ['Todas', ...products.map((item) => item.category).toSet()]
      ..sort((a, b) {
        if (a == 'Todas') return -1;
        if (b == 'Todas') return 1;
        return a.compareTo(b);
      });
    final destinations = [
      'Todos',
      ...products.map((item) => item.destination).toSet(),
    ]..sort((a, b) {
      if (a == 'Todos') return -1;
      if (b == 'Todos') return 1;
      return a.compareTo(b);
    });
    if (!categories.contains(_category)) _category = 'Todas';
    if (!destinations.contains(_destination)) _destination = 'Todos';

    final query = _searchController.text.trim().toLowerCase();
    final filtered = products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.destination.toLowerCase().contains(query);
      final matchesCategory =
          _category == 'Todas' || product.category == _category;
      final matchesDestination =
          _destination == 'Todos' || product.destination == _destination;
      final matchesActive = _showInactive || product.active;
      return matchesSearch &&
          matchesCategory &&
          matchesDestination &&
          matchesActive;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));

    final activeProducts = products.where((product) => product.active).length;
    final lowStock = products
        .where((product) => product.active && product.stock <= 5)
        .length;
    final inventoryCost = products.fold(
      0,
      (sum, product) => sum + product.cost * product.stock,
    );
    final inventorySale = products.fold(
      0,
      (sum, product) => sum + product.price * product.stock,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricCard(
                icon: Icons.inventory_2_outlined,
                label: 'Activos',
                value: '$activeProducts productos',
              ),
              _MetricCard(
                icon: Icons.warning_amber_outlined,
                label: 'Bajo stock',
                value: '$lowStock productos',
              ),
              _MetricCard(
                icon: Icons.payments_outlined,
                label: 'Costo inventario',
                value: widget.money.format(inventoryCost),
              ),
              _MetricCard(
                icon: Icons.sell_outlined,
                label: 'Valor venta',
                value: widget.money.format(inventorySale),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar producto',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _category = value ?? 'Todas'),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _destination,
                      decoration: const InputDecoration(labelText: 'Destino'),
                      items: destinations
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _destination = value ?? 'Todos'),
                    ),
                  ),
                  FilterChip(
                    label: const Text('Ver inactivos'),
                    selected: _showInactive,
                    onSelected: (value) => setState(() => _showInactive = value),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo producto'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No hay productos con esos filtros.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _ProductTile(
                        product: product,
                        money: widget.money,
                        onEdit: () => _openProductDialog(product),
                        onToggleActive: () => _toggleActive(product),
                        onDecrement: () => _adjustStock(product, -1),
                        onIncrement: () => _adjustStock(product, 1),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.money,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDecrement,
    required this.onIncrement,
  });

  final MenuProduct product;
  final NumberFormat money;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stock <= 5 && product.active;
    final profit = product.price - product.cost;
    return Card(
      child: ListTile(
        enabled: product.active,
        leading: CircleAvatar(
          backgroundColor: lowStock
              ? Theme.of(context).colorScheme.errorContainer
              : null,
          child: Icon(
            product.destination == 'barra'
                ? Icons.local_bar_outlined
                : Icons.restaurant_menu_outlined,
          ),
        ),
        title: Text(product.name),
        subtitle: Text(
          '${product.category} · ${product.destination} · Costo ${money.format(product.cost)} · Margen ${money.format(profit)}',
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'Restar stock',
              onPressed: product.stock <= 0 ? null : onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 80,
              child: Text(
                'Stock\n${product.stock}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lowStock ? Theme.of(context).colorScheme.error : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sumar stock',
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
            ),
            SizedBox(
              width: 100,
              child: Text(
                money.format(product.price),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: product.active ? 'Desactivar' : 'Activar',
              onPressed: onToggleActive,
              icon: Icon(
                product.active
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({
    required this.product,
    required this.categories,
    required this.destinations,
  });

  final MenuProduct? product;
  final List<String> categories;
  final List<String> destinations;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _destinationController;
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  late final TextEditingController _stockController;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _destinationController = TextEditingController(
      text: product?.destination ?? 'cocina',
    );
    _priceController = TextEditingController(text: '${product?.price ?? 0}');
    _costController = TextEditingController(text: '${product?.cost ?? 0}');
    _stockController = TextEditingController(text: '${product?.stock ?? 0}');
    _active = product?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  String? _requiredNumber(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) return 'Ingresa un número válido';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      MenuProduct(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        destination: _destinationController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        cost: int.parse(_costController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        active: _active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Nuevo producto' : 'Editar producto'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    suffixIcon: PopupMenuButton<String>(
                      tooltip: 'Usar categoría existente',
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (value) => _categoryController.text = value,
                      itemBuilder: (context) => widget.categories
                          .map(
                            (item) => PopupMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    suffixIcon: PopupMenuButton<String>(
                      tooltip: 'Usar destino existente',
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (value) =>
                          _destinationController.text = value,
                      itemBuilder: (context) => widget.destinations
                          .map(
                            (item) => PopupMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        validator: _requiredNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(labelText: 'Costo'),
                        keyboardType: TextInputType.number,
                        validator: _requiredNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: _requiredNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Producto activo'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
