import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';
import '../../core/theme/app_theme.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final money = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera institucional del Módulo de Paquetes
            Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.forest.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.loyalty_rounded,
                            color: AppColors.forest,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Módulo de Paquetes y Manillas',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.forest,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'El administrador define, crea y modifica los paquetes asignando color de manilla, tarifa y detalle. El color se visualiza de forma destacada en la captura de ingresos en Recepción para un control estricto y sin errores.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.add_circle, size: 20),
                          label: const Text(
                            'Crear Nuevo Paquete',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: () => _openPackageModal(context),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.restore_page_outlined, size: 18),
                          label: const Text('Restablecer 4 paquetes oficiales'),
                          onPressed: () => _confirmReset(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Resumen de colores oficiales activos
            if (state.packages.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined, size: 18, color: AppColors.forest),
                    const SizedBox(width: 8),
                    Text(
                      'Paquetes Configurados (${state.packages.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.packages.map((pkg) {
                  final c = pkg.displayColor;
                  final tc = pkg.onDisplayColor;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _openPackageModal(context, pkg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_activity, size: 14, color: tc),
                          const SizedBox(width: 6),
                          Text(
                            '${pkg.color}: ${pkg.name}',
                            style: TextStyle(
                              color: tc,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pkg.priceAdult > 0 ? money.format(pkg.priceAdult) : '(Por definir)',
                            style: TextStyle(
                              color: tc.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // Lista detallada de paquetes
            if (state.packages.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay paquetes configurados actualmente.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Cargar Paquetes Oficiales'),
                          onPressed: () => context.read<AppState>().resetDefaultPackages(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...state.packages.map((pkg) => _PackageCard(
                    package: pkg,
                    money: money,
                    onEdit: () => _openPackageModal(context, pkg),
                    onDelete: () => _confirmDelete(context, pkg),
                  )),
          ],
        ),
      ),
    );
  }

  static Future<void> _openPackageModal(BuildContext context, [ServicePackage? initial]) async {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final colorController = TextEditingController(text: initial?.color ?? 'Naranja');
    final adultPriceController = TextEditingController(
      text: initial != null ? initial.priceAdult.toString() : '20000',
    );
    final minorPriceController = TextEditingController(
      text: initial != null ? initial.priceMinor.toString() : '15000',
    );
    final includesController = TextEditingController(
      text: initial?.includes ?? 'Acceso a instalaciones, piscinas y zonas verdes',
    );
    int lunchVouchers = initial?.lunchVouchers ?? 0;

    final formKey = GlobalKey<FormState>();

    final quickColors = [
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
          builder: (context, setModalState) {
            final currentColor = packageColorToColor(colorController.text);
            final currentTextColor = getContrastTextColor(currentColor);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: currentColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_activity_rounded, color: currentColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      initial == null ? 'Crear Nuevo Paquete' : 'Modificar Paquete: ${initial.name}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner en vivo de la manilla
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: currentColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.style_rounded, color: currentTextColor, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VISTA PREVIA DE MANILLA: ${colorController.text.toUpperCase()}',
                                      style: TextStyle(
                                        color: currentTextColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      nameController.text.trim().isEmpty
                                          ? 'Nombre del Paquete'
                                          : nameController.text.trim(),
                                      style: TextStyle(
                                        color: currentTextColor.withValues(alpha: 0.95),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      includesController.text.trim().isEmpty
                                          ? 'Detalle e inclusiones...'
                                          : includesController.text.trim(),
                                      style: TextStyle(
                                        color: currentTextColor.withValues(alpha: 0.85),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                            hintText: 'Ej. Paquete Naranja, Paquete Verde, Preferencial...',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'El nombre del paquete es obligatorio' : null,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Color de la Manilla (Control de Acceso): *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: quickColors.map((item) {
                            final cName = item['name'] as String;
                            final cColor = item['color'] as Color;
                            final isSelected =
                                colorController.text.trim().toLowerCase() == cName.toLowerCase();
                            return FilterChip(
                              avatar: CircleAvatar(backgroundColor: cColor, radius: 8),
                              label: Text(cName),
                              selected: isSelected,
                              selectedColor: cColor.withValues(alpha: 0.25),
                              checkmarkColor: cColor,
                              onSelected: (val) {
                                if (val) {
                                  colorController.text = cName;
                                  setModalState(() {});
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre o código del color *',
                            hintText: 'Naranja, Verde, Azul, Dorado o código #HEX',
                            prefixIcon: Icon(Icons.color_lens_outlined),
                            border: OutlineInputBorder(),
                            helperText: 'Este color se verá en grande en Recepción al emitir el tiquet.',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Indique un color para el control de manillas' : null,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: adultPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Tarifa Adulto (\$) *',
                                  hintText: 'Ej. 20000 (0 = Por definir)',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                  helperText: '0 para precio por definir',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingrese tarifa';
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
                                  hintText: 'Ej. 15000 (0 = Exento)',
                                  prefixIcon: Icon(Icons.child_care_outlined),
                                  border: OutlineInputBorder(),
                                  helperText: '0 si no aplica cobro',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingrese tarifa';
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
                            labelText: 'Detalle e Inclusiones *',
                            hintText: 'Ej. El cliente lleva la comida / Solo ingreso / Preferencial / Eventos...',
                            prefixIcon: Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Indique el detalle o condiciones del paquete' : null,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant_outlined, color: AppColors.forest),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Almuerzos ejecutivos / vales incluidos:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: lunchVouchers > 0
                                    ? () => setModalState(() => lunchVouchers--)
                                    : null,
                              ),
                              Text(
                                '$lunchVouchers',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setModalState(() => lunchVouchers++),
                              ),
                            ],
                          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(initial == null ? 'Crear Paquete' : 'Guardar Cambios'),
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
                        content: Text('Paquete "${pkg.name}" guardado exitosamente.'),
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
        content: Text('¿Desea eliminar el paquete "${package.name}" (Color ${package.color})? Esta acción no se puede deshacer.'),
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
        title: const Text('Restablecer los 4 paquetes base'),
        content: const Text(
          'Se cargarán los siguientes paquetes oficiales:\n\n'
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
          const SnackBar(content: Text('Paquetes oficiales restablecidos con éxito.')),
        );
      }
    }
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.money,
    required this.onEdit,
    required this.onDelete,
  });

  final ServicePackage package;
  final NumberFormat money;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pkgColor = package.displayColor;
    final isDarkText = getContrastTextColor(pkgColor) == const Color(0xFF1A1A1A);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: pkgColor.withValues(alpha: 0.4), width: 1.5),
      ),
      elevation: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra lateral del color de manilla
              Container(width: 14, color: pkgColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 620;
                      final actionButtons = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: pkgColor.withValues(alpha: 0.15),
                              foregroundColor: isDarkText ? const Color(0xFF1A1A1A) : pkgColor,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Modificar', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            tooltip: 'Eliminar paquete',
                            onPressed: onDelete,
                          ),
                        ],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: pkgColor,
                                radius: 20,
                                child: Icon(
                                  Icons.local_activity_rounded,
                                  color: package.onDisplayColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          package.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: pkgColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'MANILLA: ${package.color.toUpperCase()}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                              color: package.onDisplayColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      package.includes,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isNarrow) ...[
                                const SizedBox(width: 12),
                                actionButtons,
                              ],
                            ],
                          ),
                          if (isNarrow) ...[
                            const SizedBox(height: 12),
                            actionButtons,
                          ],
                      const Divider(height: 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.person, size: 16),
                            label: Text(
                              package.priceAdult > 0
                                  ? 'Adulto: ${money.format(package.priceAdult)}'
                                  : 'Adulto: Por definir',
                              style: TextStyle(
                                fontWeight: package.priceAdult > 0 ? FontWeight.bold : FontWeight.w700,
                                color: package.priceAdult > 0 ? AppColors.forest : Colors.amber.shade900,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            avatar: const Icon(Icons.child_care, size: 16),
                            label: Text(
                              package.priceMinor > 0
                                  ? 'Menor: ${money.format(package.priceMinor)}'
                                  : 'Menor: Por definir',
                              style: TextStyle(
                                fontWeight: package.priceMinor > 0 ? FontWeight.bold : FontWeight.w700,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (package.lunchVouchers > 0)
                            Chip(
                              avatar: const Icon(Icons.restaurant, size: 16),
                              label: Text('${package.lunchVouchers} almuerzo(s) incluido(s)'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.amber.shade50,
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: const Text(
                              'Visible en Recepción',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4D3E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
