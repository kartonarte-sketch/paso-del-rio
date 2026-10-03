import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';
import '../../core/theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _PackagesTab(money: money),
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

class _PackagesTab extends StatelessWidget {
  const _PackagesTab({required this.money});

  final NumberFormat money;

  Future<void> _openPackageForm(BuildContext context, [ServicePackage? initial]) async {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final colorController = TextEditingController(text: initial?.color ?? 'Naranja');
    final adultPriceController = TextEditingController(
      text: initial != null ? initial.priceAdult.toString() : '20000',
    );
    final minorPriceController = TextEditingController(
      text: initial != null ? initial.priceMinor.toString() : '10000',
    );
    final includesController = TextEditingController(text: initial?.includes ?? '');
    int lunchVouchers = initial?.lunchVouchers ?? 0;

    final formKey = GlobalKey<FormState>();

    final predefinedColors = [
      {'name': 'Naranja', 'color': const Color(0xFFE65100)},
      {'name': 'Verde', 'color': const Color(0xFF2E7D32)},
      {'name': 'Azul', 'color': const Color(0xFF1565C0)},
      {'name': 'Dorado', 'color': const Color(0xFFC59B27)},
      {'name': 'Amarillo', 'color': const Color(0xFFF57F17)},
      {'name': 'Rojo', 'color': const Color(0xFFC62828)},
      {'name': 'Morado', 'color': const Color(0xFF6A1B9A)},
      {'name': 'Negro', 'color': const Color(0xFF212121)},
    ];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final currentColor = packageColorToColor(colorController.text);
            final currentTextColor = getContrastTextColor(currentColor);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_activity_rounded, color: currentColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    initial == null ? 'Crear Nuevo Paquete' : 'Modificar Paquete',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: currentColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.style_rounded, color: currentTextColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VISTA PREVIA DE MANILLA: COLOR ${colorController.text.toUpperCase()}',
                                      style: TextStyle(
                                        color: currentTextColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      nameController.text.isEmpty
                                          ? 'Nombre del paquete'
                                          : nameController.text,
                                      style: TextStyle(
                                        color: currentTextColor.withValues(alpha: 0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Paquete *',
                            hintText: 'Ej. Paquete Naranja, Paquete Preferencial...',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Ingrese el nombre del paquete' : null,
                          onChanged: (_) => setStateModal(() {}),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Color asignado para la manilla de control:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: predefinedColors.map((item) {
                            final cName = item['name'] as String;
                            final cColor = item['color'] as Color;
                            final isSelected =
                                colorController.text.trim().toLowerCase() == cName.toLowerCase();
                            return ChoiceChip(
                              avatar: CircleAvatar(backgroundColor: cColor, radius: 7),
                              label: Text(cName),
                              selected: isSelected,
                              selectedColor: cColor.withValues(alpha: 0.2),
                              onSelected: (val) {
                                if (val) {
                                  colorController.text = cName;
                                  setStateModal(() {});
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre o código del color *',
                            hintText: 'Naranja, Verde, Azul, Dorado o #HEX',
                            prefixIcon: Icon(Icons.color_lens_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Indique un color para el control de manillas' : null,
                          onChanged: (_) => setStateModal(() {}),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: adultPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Tarifa Adulto (\$)',
                                  hintText: 'Ej. 20000 (0 = por definir)',
                                  prefixIcon: Icon(Icons.person_outline),
                                  helperText: '0 para tarifa por definir',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingrese un valor';
                                  if (int.tryParse(v.trim()) == null) return 'Número inválido';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: minorPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Tarifa Menor (\$)',
                                  hintText: 'Ej. 15000 (0 = por definir)',
                                  prefixIcon: Icon(Icons.child_care_outlined),
                                  helperText: '0 si no aplica',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingrese un valor';
                                  if (int.tryParse(v.trim()) == null) return 'Número inválido';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: includesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Detalle e inclusiones del paquete *',
                            hintText: 'Ej. El cliente lleva la comida / Solo ingreso / Preferencial / Eventos...',
                            prefixIcon: Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Indique el detalle o beneficios del paquete' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.restaurant_outlined, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Almuerzos / vales incluidos:',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: lunchVouchers > 0
                                  ? () => setStateModal(() => lunchVouchers--)
                                  : null,
                            ),
                            Text(
                              '$lunchVouchers',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setStateModal(() => lunchVouchers++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Paquete'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final state = context.read<AppState>();
                    final newId = initial?.id ??
                        'paquete-${colorController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}';

                    final pkg = ServicePackage(
                      id: newId,
                      name: nameController.text.trim(),
                      color: colorController.text.trim(),
                      priceAdult: int.parse(adultPriceController.text.trim()),
                      priceMinor: int.parse(minorPriceController.text.trim()),
                      includes: includesController.text.trim(),
                      lunchVouchers: lunchVouchers,
                    );

                    await state.savePackage(pkg);
                    if (!dialogCtx.mounted) return;
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Paquete "${pkg.name}" guardado correctamente.'),
                        backgroundColor: AppColors.forest,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, ServicePackage package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar paquete?'),
        content: Text('¿Desea eliminar el paquete "${package.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AppState>().deletePackage(package.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paquete "${package.name}" eliminado.')),
        );
      }
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer paquetes base'),
        content: const Text(
          'Se cargarán los paquetes oficiales:\n\n'
          '• Paquete Naranja (\$20.000, el cliente lleva la comida)\n'
          '• Paquete Verde (\$15.000, solo ingreso)\n'
          '• Paquete Azul (por definir, Preferencial)\n'
          '• Paquete Dorado (por definir, Eventos)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AppState>().resetDefaultPackages();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paquetes base restablecidos exitosamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.loyalty_outlined, color: AppColors.forest, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión y Tarifas de Paquetes (Manillas)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'El administrador puede definir, crear y modificar paquetes asignando color, valor y detalle. El color se refleja directamente en la captura de ingresos en Recepción para control sin errores.',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.forest,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo Paquete'),
                            onPressed: () => _openPackageForm(context),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.restart_alt, size: 18),
                            label: const Text('Restablecer paquetes base'),
                            onPressed: () => _confirmReset(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (state.packages.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No hay paquetes configurados'),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
                      onPressed: () => _confirmReset(context),
                      child: const Text('Cargar Paquetes Base'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.packages.map((item) {
            final pkgColor = item.displayColor;
            final isDarkText = getContrastTextColor(pkgColor) == const Color(0xFF1A1A1A);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: pkgColor.withValues(alpha: 0.35), width: 1.5),
              ),
              elevation: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 14,
                        color: pkgColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: pkgColor,
                                    radius: 18,
                                    child: Icon(
                                      Icons.local_activity_rounded,
                                      color: item.onDisplayColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pkgColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: pkgColor.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            'MANILLA: ${item.color.toUpperCase()}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: isDarkText ? const Color(0xFF1A1A1A) : pkgColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    tooltip: 'Editar paquete',
                                    onPressed: () => _openPackageForm(context, item),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton.outlined(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                    tooltip: 'Eliminar paquete',
                                    onPressed: () => _confirmDelete(context, item),
                                  ),
                                ],
                              ),
                              const Divider(height: 22),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.leaf),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.includes,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  Chip(
                                    avatar: const Icon(Icons.person, size: 16),
                                    label: Text(
                                      item.priceAdult > 0
                                          ? 'Adulto: ${money.format(item.priceAdult)}'
                                          : 'Adulto: Por definir',
                                      style: TextStyle(
                                        fontWeight: item.priceAdult > 0 ? FontWeight.bold : FontWeight.w600,
                                        color: item.priceAdult > 0 ? AppColors.forest : Colors.amber.shade900,
                                      ),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Chip(
                                    avatar: const Icon(Icons.child_care, size: 16),
                                    label: Text(
                                      item.priceMinor > 0
                                          ? 'Menor: ${money.format(item.priceMinor)}'
                                          : 'Menor: Por definir',
                                      style: TextStyle(
                                        fontWeight: item.priceMinor > 0 ? FontWeight.bold : FontWeight.w600,
                                      ),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  if (item.lunchVouchers > 0)
                                    Chip(
                                      avatar: const Icon(Icons.restaurant, size: 16),
                                      label: Text('${item.lunchVouchers} almuerzo(s) incluido(s)'),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: Colors.amber.shade50,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
