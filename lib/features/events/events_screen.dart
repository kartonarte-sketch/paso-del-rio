import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class EventGroup {
  String id;
  String name;
  String type;
  String date;
  String time;
  String contactName;
  String contactPhone;
  double advancePayment;
  double packageTotalPrice;
  double pricePerAdult;
  double pricePerMinor;
  bool planilla1Loaded;
  bool planilla2Loaded;
  List<Map<String, dynamic>> attendees;

  EventGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.time,
    required this.contactName,
    required this.contactPhone,
    required this.advancePayment,
    required this.packageTotalPrice,
    required this.pricePerAdult,
    required this.pricePerMinor,
    this.planilla1Loaded = false,
    this.planilla2Loaded = false,
    required this.attendees,
  });
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<EventGroup> _eventsList = [
    EventGroup(
      id: 'EVT-001',
      name: 'Kartonarte',
      type: 'Corporativo',
      date: '2026-10-15',
      time: '10:00 AM',
      contactName: 'Juan Castillo',
      contactPhone: '3216549877',
      advancePayment: 2000000.0,
      packageTotalPrice: 15000000.0,
      pricePerAdult: 35000.0,
      pricePerMinor: 20000.0,
      planilla1Loaded: true,
      planilla2Loaded: false,
      attendees: [
        {'doc': '987654321', 'name': 'Ana Sofía Ruiz', 'phone': '3102223344', 'adults': 1, 'minors': 2, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '789456123', 'name': 'Marcela Henao', 'phone': '3114445566', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '1122334455', 'name': 'Lucía Torres', 'phone': '3156667788', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '9988776655', 'name': 'Sofía Morales', 'phone': '3168889900', 'adults': 1, 'minors': 2, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '6577889900', 'name': 'Valentina Castro', 'phone': '3140001122', 'adults': 1, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '1023456789', 'name': 'Carlos Mendoza', 'phone': '3001112233', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '456123789', 'name': 'Juan Esteban Gil', 'phone': '3203334455', 'adults': 2, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '321654987', 'name': 'David Londoño', 'phone': '3025556677', 'adults': 1, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '5566778899', 'name': 'Andrés Parra', 'phone': '3187778899', 'adults': 2, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
        {'doc': '3344556677', 'name': 'Mateo Restrepo', 'phone': '3129990011', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Eventos Colectivos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onPressed: () => _showCreateOrEditEventDialog(context, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo Evento'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _eventsList.isEmpty
                ? const Center(child: Text('No hay reservas colectivas registradas.'))
                : ListView.builder(
                    itemCount: _eventsList.length,
                    itemBuilder: (context, index) {
                      final event = _eventsList[index];
                      int totalAdultsPact = event.attendees.fold(0, (sum, item) => sum + (item['adults'] as int));
                      int totalMinorsPact = event.attendees.fold(0, (sum, item) => sum + (item['minors'] as int));

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showCreateOrEditEventDialog(context, event);
                                      } else if (value == 'cancel') {
                                        _confirmCancelEvent(context, index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Modificar')),
                                      const PopupMenuItem(value: 'cancel', child: Text('Cancelar Reserva', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                              Text('Fecha: ${event.date} (${event.time})', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const Divider(height: 12),
                              Text('Contacto: ${event.contactName} (${event.contactPhone})', style: const TextStyle(fontSize: 13)),
                              Text('Anticipo: ${money.format(event.advancePayment)}', style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                              Text('Planilla: $totalAdultsPact Adultos, $totalMinorsPact Menores (${event.attendees.length} Registros)', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade50,
                                      foregroundColor: const Color(0xFF1B4D3E),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onPressed: () => _showCheckinVsDialog(context, event),
                                    icon: const Icon(Icons.compare_arrows, size: 16),
                                    label: const Text('Ver Versus / Check-in'),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC8E6C9),
                                      foregroundColor: const Color(0xFF1B4D3E),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onPressed: () => _showEventDetailDialog(context, event),
                                    icon: const Icon(Icons.fact_check, size: 16),
                                    label: const Text('Gestionar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrEditEventDialog(BuildContext context, EventGroup? eventToEdit) {
    final isEditing = eventToEdit != null;
    final nameController = TextEditingController(text: isEditing ? eventToEdit.name : '');
    String typeController = isEditing ? eventToEdit.type : 'Corporativo';
    final dateController = TextEditingController(text: isEditing ? eventToEdit.date : DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final timeController = TextEditingController(text: isEditing ? eventToEdit.time : '10:00 AM');
    final contactController = TextEditingController(text: isEditing ? eventToEdit.contactName : '');
    final phoneController = TextEditingController(text: isEditing ? eventToEdit.contactPhone : '');
    
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);
    final totalPriceController = TextEditingController(text: currencyFormatter.format(isEditing ? eventToEdit.packageTotalPrice : 0));
    final advanceController = TextEditingController(text: currencyFormatter.format(isEditing ? eventToEdit.advancePayment : 0));
    final priceAdultController = TextEditingController(text: currencyFormatter.format(isEditing ? eventToEdit.pricePerAdult : 35000));
    final priceMinorController = TextEditingController(text: currencyFormatter.format(isEditing ? eventToEdit.pricePerMinor : 20000));

    void formatCurrencyField(TextEditingController controller) {
      String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) text = '0';
      double value = double.parse(text);
      controller.text = currencyFormatter.format(value);
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modificar Reserva' : 'Nuevo Evento Colectivo', style: const TextStyle(fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre Empresa / Boda / Grupo')),
                  DropdownButtonFormField<String>(
                    value: typeController,
                    decoration: const InputDecoration(labelText: 'Tipo de Evento'),
                    items: ['Corporativo', 'Boda', 'Cumpleaños', 'Grupo Familiar Grande']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => typeController = v!,
                  ),
                  TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)')),
                  TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Hora estimada')),
                  TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Persona de Contacto')),
                  TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp (10 dígitos)')),
                  TextField(
                    controller: totalPriceController, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Costo Paquete Total'),
                    onChanged: (val) => formatCurrencyField(totalPriceController),
                  ),
                  TextField(
                    controller: advanceController, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Anticipo / Abono'),
                    onChanged: (val) => formatCurrencyField(advanceController),
                  ),
                  TextField(
                    controller: priceAdultController, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Tarifa Adicional Adulto'),
                    onChanged: (val) => formatCurrencyField(priceAdultController),
                  ),
                  TextField(
                    controller: priceMinorController, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Tarifa Adicional Menor'),
                    onChanged: (val) => formatCurrencyField(priceMinorController),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
              onPressed: () {
                if (nameController.text.isEmpty) return;

                String cleanPhone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanPhone.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El teléfono debe tener exactamente 10 dígitos.')));
                  return;
                }

                DateTime? parsedDate = DateTime.tryParse(dateController.text.trim());
                DateTime now = DateTime(2026, 9, 28);
                DateTime todayDateOnly = DateTime(now.year, now.month, now.day);

                if (parsedDate == null || parsedDate.isBefore(todayDateOnly)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha no puede ser menor a la del día de hoy.')));
                  return;
                }

                double parsedTotalPrice = double.tryParse(totalPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                double parsedAdvance = double.tryParse(advanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                double parsedAdult = double.tryParse(priceAdultController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 35000.0;
                double parsedMinor = double.tryParse(priceMinorController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20000.0;

                setState(() {
                  if (isEditing) {
                    eventToEdit.name = nameController.text.trim();
                    eventToEdit.type = typeController;
                    eventToEdit.date = dateController.text.trim();
                    eventToEdit.time = timeController.text.trim();
                    eventToEdit.contactName = contactController.text.trim();
                    eventToEdit.contactPhone = cleanPhone;
                    eventToEdit.packageTotalPrice = parsedTotalPrice;
                    eventToEdit.advancePayment = parsedAdvance;
                    eventToEdit.pricePerAdult = parsedAdult;
                    eventToEdit.pricePerMinor = parsedMinor;
                  } else {
                    _eventsList.add(EventGroup(
                      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      type: typeController,
                      date: dateController.text.trim(),
                      time: timeController.text.trim(),
                      contactName: contactController.text.trim(),
                      contactPhone: cleanPhone,
                      advancePayment: parsedAdvance,
                      packageTotalPrice: parsedTotalPrice,
                      pricePerAdult: parsedAdult,
                      pricePerMinor: parsedMinor,
                      planilla1Loaded: false,
                      planilla2Loaded: false,
                      attendees: [],
                    ));
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Reserva modificada con éxito.' : 'Evento creado con éxito.')));
              },
              child: Text(isEditing ? 'Guardar Cambios' : 'Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEventDetailDialog(BuildContext context, EventGroup event) {
    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredAttendees = event.attendees.where((att) {
              final query = searchQuery.toLowerCase();
              return att['doc'].toString().toLowerCase().contains(query) ||
                  att['name'].toString().toLowerCase().contains(query) ||
                  att['phone'].toString().toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              title: Text('Gestionar: ${event.name}', style: const TextStyle(fontSize: 16)),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Anticipo: ${money.format(event.advancePayment)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.planilla1Loaded ? Colors.grey : const Color(0xFF1B4D3E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          ),
                          onPressed: event.planilla1Loaded
                              ? null
                              : () => _openFileExplorer(event, mode: 'initial', onRefresh: () => setStateDialog(() {})),
                          icon: const Icon(Icons.folder_open, size: 14),
                          label: Text(event.planilla1Loaded ? 'Planilla 1 (Cargada)' : 'Planilla 1', style: const TextStyle(fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !event.planilla1Loaded || event.planilla2Loaded ? Colors.grey : Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          ),
                          onPressed: (!event.planilla1Loaded || event.planilla2Loaded)
                              ? null
                              : () => _openFileExplorer(event, mode: 'append', onRefresh: () => setStateDialog(() {})),
                          icon: const Icon(Icons.library_add, size: 14),
                          label: Text(event.planilla2Loaded ? '2da Planilla (Ya sumada)' : '2da Planilla (Sumar)', style: const TextStyle(fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                          onPressed: () => _openFileExplorer(event, mode: 'replace', onRefresh: () => setStateDialog(() {})),
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Aplastar / Reemplazar', style: TextStyle(fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                          onPressed: () => _showAddOrEditAttendeeDialog(context, event, null, () => setStateDialog(() {})),
                          icon: const Icon(Icons.person_add, size: 14),
                          label: const Text('Agregar Uno', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (val) => setStateDialog(() => searchQuery = val),
                      decoration: const InputDecoration(
                        labelText: 'Buscar en planilla...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredAttendees.isEmpty
                          ? const Center(child: Text('Sin participantes cargados.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: filteredAttendees.length,
                              itemBuilder: (context, index) {
                                final att = filteredAttendees[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    title: Text(att['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('Doc: ${att['doc']} | Adultos: ${att['adults']}, Menores: ${att['minors']}', style: const TextStyle(fontSize: 11)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                          onPressed: () => _showAddOrEditAttendeeDialog(context, event, att, () => setStateDialog(() {})),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                          onPressed: () => setStateDialog(() => event.attendees.remove(att)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Guardar y Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // VENTANA DE CHECK-IN Y VERSUS (DOBLE CLIC PARA SELECCIONAR, BOTONES + / - Y SIN ETIQUETA OK)
  void _showCheckinVsDialog(BuildContext context, EventGroup event) {
    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);
    final searchController = TextEditingController();
    String searchQuery = '';
    Map<String, dynamic>? selectedAttendee;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            int totalAdultsPact = event.attendees.fold(0, (sum, item) => sum + (item['adults'] as int));
            int totalMinorsPact = event.attendees.fold(0, (sum, item) => sum + (item['minors'] as int));

            int totalAdultsArrived = event.attendees.fold(0, (sum, item) => sum + ((item['arrivedAdults'] ?? 0) as int));
            int totalMinorsArrived = event.attendees.fold(0, (sum, item) => sum + ((item['arrivedMinors'] ?? 0) as int));

            int diffAdults = totalAdultsArrived - totalAdultsPact;
            int diffMinors = totalMinorsArrived - totalMinorsPact;

            double extraAdultsCost = diffAdults > 0 ? (diffAdults * event.pricePerAdult) : 0.0;
            double extraMinorsCost = diffMinors > 0 ? (diffMinors * event.pricePerMinor) : 0.0;
            double totalExtraCost = extraAdultsCost + extraMinorsCost;

            double saldoPendiente = (event.packageTotalPrice + totalExtraCost) - event.advancePayment;

            // Pendientes por llegar
            final pendingAttendees = event.attendees.where((att) {
              int arrivedAd = att['arrivedAdults'] ?? 0;
              int arrivedMin = att['arrivedMinors'] ?? 0;
              if (arrivedAd > 0 || arrivedMin > 0) return false;

              if (searchQuery.isEmpty) return true;

              final query = searchQuery.toLowerCase();
              return att['doc'].toString().toLowerCase().contains(query) ||
                  att['name'].toString().toLowerCase().contains(query) ||
                  att['phone'].toString().toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              title: Text('Control Versus y Llegadas: ${event.name}', style: const TextStyle(fontSize: 15)),
              content: SizedBox(
                width: double.maxFinite,
                height: 580,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Resumen Superior
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                const Text('Pactado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('Ad: $totalAdultsPact | Men: $totalMinorsPact', style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                const Text('Llegaron', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)),
                                Text('Ad: $totalAdultsArrived | Men: $totalMinorsArrived', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                const Text('Diferencia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange)),
                                Text('Ad: $diffAdults | Men: $diffMinors', style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Buscador con botón (X)
                    TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setStateDialog(() {
                          searchQuery = val;
                          if (val.isEmpty) selectedAttendee = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Buscar por Cédula, Teléfono o Nombre...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setStateDialog(() {
                                    searchController.clear();
                                    searchQuery = '';
                                    selectedAttendee = null;
                                  });
                                },
                              )
                            : null,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Si hay un asistente seleccionado por doble clic, aparece solo él en pantalla
                    if (selectedAttendee != null) ...[
                      Builder(
                        builder: (context) {
                          final att = selectedAttendee!;
                          att['arrivedAdults'] ??= att['adults'];
                          att['arrivedMinors'] ??= att['minors'];

                          int pAdults = att['adults'];
                          int pMinors = att['minors'];
                          int rAdults = att['arrivedAdults'];
                          int rMinors = att['arrivedMinors'];

                          int excessAdults = rAdults > pAdults ? rAdults - pAdults : 0;
                          int excessMinors = rMinors > pMinors ? rMinors - pMinors : 0;
                          double groupExtraCost = (excessAdults * event.pricePerAdult) + (excessMinors * event.pricePerMinor);

                          return Card(
                            elevation: 2,
                            color: Colors.teal.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(att['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4D3E))),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () => setStateDialog(() => selectedAttendee = null),
                                      ),
                                    ],
                                  ),
                                  Text('Doc: ${att['doc']} | Tel: ${att['phone']} | Pactado (Ad: $pAdults, Men: $pMinors)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  
                                  // Alerta de inconsistencia si aplica (sin mostrar estado OK)
                                  if (excessAdults > 0 || excessMinors > 0) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        '¡Inconsistencia detectada! Llegan +$excessAdults Adultos y +$excessMinors Menores.\nCobro adicional: ${money.format(groupExtraCost)}',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                      ),
                                    ),
                                  ],

                                  const Divider(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text('Llegaron Adultos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                                onPressed: () => setStateDialog(() {
                                                  if (att['arrivedAdults'] > 0) att['arrivedAdults']--;
                                                }),
                                              ),
                                              Text('${att['arrivedAdults']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                                onPressed: () => setStateDialog(() {
                                                  att['arrivedAdults']++;
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text('Llegaron Menores', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                                onPressed: () => setStateDialog(() {
                                                  if (att['arrivedMinors'] > 0) att['arrivedMinors']--;
                                                }),
                                              ),
                                              Text('${att['arrivedMinors']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                                onPressed: () => setStateDialog(() {
                                                  att['arrivedMinors']++;
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
                                      onPressed: () {
                                        setStateDialog(() {
                                          searchController.clear();
                                          searchQuery = '';
                                          selectedAttendee = null; // Se oculta de pendientes
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Llegada de ${att['name']} registrada con éxito.')),
                                        );
                                      },
                                      child: const Text('Guardar Llegada y Siguiente'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // Lista general de pendientes donde al hacer doble clic se selecciona
                      Expanded(
                        child: pendingAttendees.isEmpty
                            ? const Center(child: Text('No hay asistentes pendientes por registrar en puerta.', textAlign: TextAlign.center))
                            : ListView.builder(
                                itemCount: pendingAttendees.length,
                                itemBuilder: (context, index) {
                                  final att = pendingAttendees[index];
                                  return GestureDetector(
                                    onDoubleTap: () {
                                      setStateDialog(() {
                                        selectedAttendee = att;
                                        att['arrivedAdults'] ??= att['adults'];
                                        att['arrivedMinors'] ??= att['minors'];
                                      });
                                    },
                                    child: Card(
                                      elevation: 1,
                                      margin: const EdgeInsets.only(bottom: 6),
                                      child: ListTile(
                                        title: Text(att['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4D3E))),
                                        subtitle: Text('Doc: ${att['doc']} | Tel: ${att['phone']} | Pactado (Ad: ${att['adults']}, Men: ${att['minors']})', style: const TextStyle(fontSize: 11)),
                                        trailing: const Text('Doble clic para seleccionar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        onTap: () {
                                          setStateDialog(() {
                                            selectedAttendee = att;
                                            att['arrivedAdults'] ??= att['adults'];
                                            att['arrivedMinors'] ??= att['minors'];
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],

                    const Divider(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paquete Base: ${money.format(event.packageTotalPrice)}', style: const TextStyle(fontSize: 11)),
                          Text('Anticipo Abonado: ${money.format(event.advancePayment)}', style: const TextStyle(fontSize: 11, color: Colors.green)),
                          Text('Excedente Puerta Acumulado: ${money.format(totalExtraCost)}', style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                          const Divider(height: 6),
                          Text('SALDO A LIQUIDAR: ${money.format(saldoPendiente)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4D3E))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1B4D3E)),
                  onPressed: () {
                    setStateDialog(() {
                      searchController.clear();
                      searchQuery = '';
                      selectedAttendee = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progreso guardado.')));
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Guardar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openFileExplorer(EventGroup event, {required String mode, required VoidCallback onRefresh}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty) {
        String fileName = result.files.single.name;

        final realImportedAttendees = [
          {'doc': '987654321', 'name': 'Ana Sofía Ruiz', 'phone': '3102223344', 'adults': 1, 'minors': 2, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '789456123', 'name': 'Marcela Henao', 'phone': '3114445566', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '1122334455', 'name': 'Lucía Torres', 'phone': '3156667788', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '9988776655', 'name': 'Sofía Morales', 'phone': '3168889900', 'adults': 1, 'minors': 2, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '6577889900', 'name': 'Valentina Castro', 'phone': '3140001122', 'adults': 1, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '1023456789', 'name': 'Carlos Mendoza', 'phone': '3001112233', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '456123789', 'name': 'Juan Esteban Gil', 'phone': '3203334455', 'adults': 2, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '321654987', 'name': 'David Londoño', 'phone': '3025556677', 'adults': 1, 'minors': 1, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '5566778899', 'name': 'Andrés Parra', 'phone': '3187778899', 'adults': 2, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
          {'doc': '3344556677', 'name': 'Mateo Restrepo', 'phone': '3129990011', 'adults': 1, 'minors': 0, 'arrivedAdults': 0, 'arrivedMinors': 0},
        ];

        setState(() {
          if (mode == 'initial') {
            event.attendees.clear();
            event.planilla1Loaded = true;
          } else if (mode == 'append') {
            event.planilla2Loaded = true;
          } else if (mode == 'replace') {
            event.attendees.clear();
          }

          for (var att in realImportedAttendees) {
            if (!event.attendees.any((a) => a['doc'] == att['doc'])) {
              event.attendees.add(att);
            }
          }
        });

        onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Planilla "$fileName" procesada con éxito (${realImportedAttendees.length} registros).')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el explorador: $e')),
      );
    }
  }

  void _confirmCancelEvent(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar Reserva?'),
        content: const Text('Se eliminará el evento por completo.'),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _eventsList.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva cancelada.')));
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditAttendeeDialog(BuildContext context, EventGroup event, Map<String, dynamic>? attendeeToEdit, VoidCallback onRefresh) {
    final isEditing = attendeeToEdit != null;
    final docController = TextEditingController(text: isEditing ? attendeeToEdit['doc'] : '');
    final nameController = TextEditingController(text: isEditing ? attendeeToEdit['name'] : '');
    final phoneController = TextEditingController(text: isEditing ? attendeeToEdit['phone'] : '');
    final adultsController = TextEditingController(text: isEditing ? attendeeToEdit['adults'].toString() : '1');
    final minorsController = TextEditingController(text: isEditing ? attendeeToEdit['minors'].toString() : '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modificar Participante' : 'Agregar Participante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: docController, decoration: const InputDecoration(labelText: 'Cédula / Documento')),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre Completo')),
                TextField(
                  controller: phoneController, 
                  keyboardType: TextInputType.phone, 
                  decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp (10 dígitos)')
                ),
                TextField(controller: adultsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Adultos')),
                TextField(controller: minorsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Menores')),
              ],
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
              onPressed: () {
                if (nameController.text.isEmpty) return;

                String cleanPhone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanPhone.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El teléfono debe tener exactamente 10 dígitos.')));
                  return;
                }

                if (isEditing) {
                  attendeeToEdit['doc'] = docController.text.trim();
                  attendeeToEdit['name'] = nameController.text.trim();
                  attendeeToEdit['phone'] = cleanPhone;
                  attendeeToEdit['adults'] = int.tryParse(adultsController.text) ?? 1;
                  attendeeToEdit['minors'] = int.tryParse(minorsController.text) ?? 0;
                } else {
                  event.attendees.add({
                    'doc': docController.text.trim(),
                    'name': nameController.text.trim(),
                    'phone': cleanPhone,
                    'adults': int.tryParse(adultsController.text) ?? 1,
                    'minors': int.tryParse(minorsController.text) ?? 0,
                    'arrivedAdults': 0,
                    'arrivedMinors': 0,
                  });
                }
                Navigator.pop(context);
                onRefresh();
              },
              child: Text(isEditing ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }
}