import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';
import 'ticket_share.dart';

// ==========================================
// 1. WIDGET DE TIQUET FORMATO 9:16 (ECO HOTEL)
// ==========================================
class EcoHotelTicketWidget extends StatelessWidget {
  final String responsibleName;
  final String responsiblePhone;
  final String dateTime;
  final String cars;
  final String motorcycles;
  final int totalAdults;
  final int totalMinors;
  final int pets;
  final String totalPriceFormatted;

  const EcoHotelTicketWidget({
    super.key,
    required this.responsibleName,
    required this.responsiblePhone,
    required this.dateTime,
    required this.cars,
    required this.motorcycles,
    required this.totalAdults,
    required this.totalMinors,
    required this.pets,
    required this.totalPriceFormatted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 640,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Logo 02.jpg',
                  height: 65,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco,
                    size: 50,
                    color: Color(0xFF1B4D3E),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'PASO DEL RÍO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Color(0xFF1B4D3E),
                  ),
                ),
                const Text(
                  'ECO HOTEL & RESTAURANTE',
                  style: TextStyle(fontSize: 9, color: Colors.grey, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4D3E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PASE OFICIAL DE INGRESO Y PARQUEADERO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Responsable:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Flexible(child: Text(responsibleName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WhatsApp:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(responsiblePhone, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fecha de Emisión:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(dateTime, style: const TextStyle(fontSize: 11)),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          const Text(
            'CONTROL DE PARQUEADERO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
          ),
          const SizedBox(height: 6),
          Text('• Carros: $cars', style: const TextStyle(fontSize: 12)),
          Text('• Motos: $motorcycles', style: const TextStyle(fontSize: 12)),
          const Divider(height: 20, thickness: 1),
          const Text(
            'DETALLE DE AFORO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
          ),
          const SizedBox(height: 6),
          Text('• Manillas Entregadas: ${totalAdults + totalMinors} (Adultos: $totalAdults, Menores: $totalMinors)', style: const TextStyle(fontSize: 12)),
          Text('• Mascotas a bordo: $pets', style: const TextStyle(fontSize: 12)),
          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VALOR TOTAL PAGADO:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4D3E)),
              ),
              Text(
                totalPriceFormatted,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4D3E)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, size: 16, color: Color(0xFF1B4D3E)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cobertura de póliza activa. Disfrute de nuestra zona de piscinas y áreas verdes con total tranquilidad.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF1B4D3E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. GESTOR DE PINES Y FORMATEADORES
// ==========================================
class AdminPinManager {
  static final Map<String, _PinSession> _activePins = {};

  static String generatePin(String adminName) {
    final random = Random();
    final pin = (1000 + random.nextInt(9000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    _activePins[adminName] = _PinSession(
      pin: pin,
      expiresAt: expiresAt,
    );

    return pin;
  }

  static bool validateAndConsumePin(String adminName, String inputPin) {
    final session = _activePins[adminName];
    if (session == null) return false;
    if (session.isUsed) return false;
    if (session.isExpired) return false;

    if (session.pin == inputPin.trim()) {
      session.isUsed = true;
      return true;
    }
    return false;
  }
}

class _PinSession {
  final String pin;
  final DateTime expiresAt;
  bool isUsed;

  _PinSession({required this.pin, required this.expiresAt, this.isUsed = false});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'es_CO');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final parsedValue = int.parse(cleanText);
    final formatted = _formatter.format(parsedValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class OtherTransportItem {
  String type = 'A pie';
}

// ==========================================
// 3. PANTALLA PRINCIPAL DE RECEPCIÓN
// ==========================================
class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key});

  @override
  State<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leader = TextEditingController();
  final _whatsapp = TextEditingController();
  final _adults = TextEditingController(text: '1');
  final _minors = TextEditingController(text: '0');
  final _pets = TextEditingController(text: '0');
  
  String? _packageId;
  bool _saving = false;
  bool _transportAttempted = false;

  final List<TextEditingController> _cars = [];
  final List<TextEditingController> _motorcycles = [];
  final List<OtherTransportItem> _others = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _leader.dispose();
    _whatsapp.dispose();
    _adults.dispose();
    _minors.dispose();
    _pets.dispose();
    for (var c in _cars) c.dispose();
    for (var m in _motorcycles) m.dispose();
    super.dispose();
  }

  void _increment(TextEditingController controller, {int min = 0}) {
    final current = int.tryParse(controller.text) ?? min;
    controller.text = (current + 1).toString();
    setState(() {});
  }

  void _decrement(TextEditingController controller, {int min = 0}) {
    final current = int.tryParse(controller.text) ?? min;
    if (current > min) {
      controller.text = (current - 1).toString();
      setState(() {});
    }
  }

  bool _hasAtLeastOneTransport() {
    final hasCar = _cars.any((c) => c.text.trim().isNotEmpty);
    final hasMoto = _motorcycles.any((m) => m.text.trim().isNotEmpty);
    final hasOther = _others.isNotEmpty;
    return hasCar || hasMoto || hasOther;
  }

  // Muestra el tiquet con proporción vertical 9:16 listo para enviar a WhatsApp.
  void _showTicketPreviewDialog({
    required String phone,
    required String leaderName,
    required int adults,
    required int minors,
    required int pets,
    required String totalPaidFormatted,
    required String transportInfo,
  }) {
    final ticketKey = GlobalKey();
    final generatedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.chat, color: Colors.green),
            SizedBox(width: 8),
            Text('Pase de Ingreso Generado', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 380,
          height: 560,
          child: Center(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: ticketKey,
                child: EcoHotelTicketWidget(
                  responsibleName: leaderName,
                  responsiblePhone: phone,
                  dateTime: generatedAt,
                  cars: transportInfo,
                  motorcycles: 'Ninguno',
                  totalAdults: adults,
                  totalMinors: minors,
                  pets: pets,
                  totalPriceFormatted: totalPaidFormatted,
                ),
              ),
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E)),
            onPressed: () async {
              try {
                await WidgetsBinding.instance.endOfFrame;
                final boundary = ticketKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                if (boundary == null) {
                  throw StateError('No se pudo preparar la imagen del tiquet.');
                }

                final image = await boundary.toImage(pixelRatio: 3);
                final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                if (byteData == null) {
                  throw StateError('No se pudo convertir el tiquet a PNG.');
                }

                final snackBarMessage = await shareTicketImage(
                  bytes: byteData.buffer.asUint8List(),
                  fileName: 'pase-paso-del-rio-${DateTime.now().millisecondsSinceEpoch}.png',
                  phone: phone,
                  message: '',
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackBarMessage)));
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se pudo enviar la imagen del tiquet: $error')),
                );
              }
            },
            icon: const Icon(Icons.image, size: 16),
            label: const Text('Enviar imagen por WhatsApp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    _packageId ??= state.packages.first.id;
    final selected = state.packages.firstWhere((item) => item.id == _packageId);

    final adultsCount = int.tryParse(_adults.text) ?? 0;
    final minorsCount = int.tryParse(_minors.text) ?? 0;
    final petsCount = int.tryParse(_pets.text) ?? 0;
    
    final totalManillas = adultsCount + minorsCount;

    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);

    final showTransportError = _transportAttempted && !_hasAtLeastOneTransport();

    final formCard = Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_add_alt_1, color: Color(0xFF1B4D3E)),
                  SizedBox(width: 8),
                  Text('Registro de Ingreso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              TextFormField(
                controller: _leader,
                decoration: const InputDecoration(labelText: 'Nombre y Apellido del responsable', hintText: 'Ej. Juan Pérez', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'El nombre y apellido son obligatorios';
                  final parts = value.trim().split(RegExp(r'\s+'));
                  if (parts.length < 2) return 'Por favor ingrese al menos un nombre y un apellido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                decoration: const InputDecoration(labelText: 'WhatsApp', hintText: '3001234567', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'El WhatsApp es obligatorio';
                  if (value.trim().length != 10) return 'Debe tener exactamente 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                initialValue: _packageId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Paquete de Servicio', border: OutlineInputBorder()),
                items: state.packages.map((item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    '${item.name} (Ad: \$${item.priceAdult} / Men: \$${item.priceMinor})',
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (value) => setState(() => _packageId = value),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_activity, size: 18, color: Color(0xFFB78103)),
                    const SizedBox(width: 8),
                    Text(
                      'Manillas asignadas: Color ${selected.color}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF795548)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _counterField(_adults, 'Adultos', min: 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _counterField(_minors, 'Menores', min: 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _counterField(_pets, 'Mascotas', min: 0)),
                ],
              ),
              const Divider(height: 24),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showTransportError ? Colors.red.shade700 : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.directions_car, size: 18, color: Color(0xFF1B4D3E)),
                                  SizedBox(width: 4),
                                  Text('Carros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ..._cars.asMap().entries.map((entry) {
                                final index = entry.key;
                                final controller = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          textCapitalization: TextCapitalization.characters,
                                          onChanged: (_) => setState(() {}),
                                          decoration: InputDecoration(labelText: 'Placa #${index + 1}', border: const OutlineInputBorder(), isDense: true),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => setState(() => _cars.removeAt(index)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () => setState(() => _cars.add(TextEditingController())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Agregar carro', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.two_wheeler, size: 18, color: Color(0xFF1B4D3E)),
                                  SizedBox(width: 4),
                                  Text('Motos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ..._motorcycles.asMap().entries.map((entry) {
                                final index = entry.key;
                                final controller = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          textCapitalization: TextCapitalization.characters,
                                          onChanged: (_) => setState(() {}),
                                          decoration: InputDecoration(labelText: 'Placa #${index + 1}', border: const OutlineInputBorder(), isDense: true),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => setState(() => _motorcycles.removeAt(index)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () => setState(() => _motorcycles.add(TextEditingController())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Agregar moto', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.directions_walk, size: 18, color: Color(0xFF1B4D3E)),
                                  SizedBox(width: 4),
                                  Text('Otros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ..._others.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: item.type,
                                          isDense: true,
                                          isExpanded: true,
                                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10)),
                                          items: ['A pie', 'Bicicleta', 'Patineta', 'Otros']
                                              .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12))))
                                              .toList(),
                                          onChanged: (v) => setState(() => item.type = v!),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => setState(() => _others.removeAt(index)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () => setState(() => _others.add(OtherTransportItem())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Agregar otro', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (showTransportError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          'Debe registrar obligatoriamente al menos un medio de transporte',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: () {
                  setState(() => _transportAttempted = true);
                  if (!_formKey.currentState!.validate()) return;
                  if (!_hasAtLeastOneTransport()) return;

                  _showPaymentDialog(context, state, selected, adultsCount, minorsCount, petsCount);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.payment, size: 22),
                label: const Text('Proceder al Pago y Tiquete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );

    final totalVehiclesCount = _cars.where((c) => c.text.isNotEmpty).length +
        _motorcycles.where((m) => m.text.isNotEmpty).length +
        _others.length;

    final rightPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estadísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                  children: [
                    _statBox('Adultos', '$adultsCount', Icons.person),
                    _statBox('Menores', '$minorsCount', Icons.child_care),
                    _statBox('Mascotas', '$petsCount', Icons.pets),
                    _statBox('Transportes', '$totalVehiclesCount', Icons.directions_car),
                    _statBox('Manillas', '$totalManillas', Icons.local_activity),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingresos Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (state.groups.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Sin ingresos')))
                else
                  ...state.groups.take(5).map(
                        (g) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(g.leader, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${g.adults} Adultos · ${g.packageColor}'),
                          trailing: Text(money.format(g.totalPaid), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 950) {
            return Column(children: [formCard, const SizedBox(height: 20), rightPanel]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: formCard),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: rightPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _counterField(TextEditingController controller, String label, {int min = 0}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final number = int.tryParse(value ?? '');
                return number == null || number < min ? 'Inv.' : null;
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_drop_up, size: 20),
                  onPressed: () => _increment(controller, min: min),
                ),
              ),
              SizedBox(
                width: 24,
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  onPressed: () => _decrement(controller, min: min),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    AppState state,
    dynamic selectedPackage,
    int adults,
    int minors,
    int pets,
  ) {
    final discountController = TextEditingController(text: '0');
    final pinController = TextEditingController();
    final cashController = TextEditingController();
    final phoneController = TextEditingController();
    String discountType = 'Fijo';
    String paymentMethod = 'Efectivo';
    bool noChargeMinors = false;
    String? authorizedBy;
    bool isDiscountUnlocked = false;

    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ', decimalDigits: 0);

    final transportList = [
      ..._cars.where((c) => c.text.trim().isNotEmpty).map((c) => 'Carro: ${c.text.trim().toUpperCase()}'),
      ..._motorcycles.where((m) => m.text.trim().isNotEmpty).map((m) => 'Moto: ${m.text.trim().toUpperCase()}'),
      ..._others.map((o) => o.type),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final minorsSubtotal = noChargeMinors ? 0 : (minors * selectedPackage.priceMinor);
            final subtotal = (adults * selectedPackage.priceAdult) + minorsSubtotal;

            final discountInput = double.tryParse(discountController.text.replaceAll('.', '')) ?? 0.0;
            final cashInput = double.tryParse(cashController.text.replaceAll('.', '')) ?? 0.0;

            double discountVal = 0.0;
            if (discountType == 'Porcentaje') {
              discountVal = subtotal * (discountInput / 100);
            } else {
              discountVal = discountInput;
            }

            final totalPaid = (subtotal - discountVal).clamp(0.0, double.infinity);
            final change = (cashInput - totalPaid).clamp(0.0, double.infinity);

            return AlertDialog(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              title: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Color(0xFF1B4D3E), size: 26),
                  const SizedBox(width: 10),
                  const Text('Pasarela de Pago y Tiquete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              content: SizedBox(
                width: 650,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vista previa del tiquet vertical estilo 9:16
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: EcoHotelTicketWidget(
                                responsibleName: _leader.text.isEmpty ? 'Responsable' : _leader.text,
                                responsiblePhone: _whatsapp.text.isEmpty ? '3000000000' : _whatsapp.text,
                                dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                cars: transportList.isEmpty ? 'A pie' : transportList.join(', '),
                                motorcycles: 'Ninguno',
                                totalAdults: adults,
                                totalMinors: minors,
                                pets: pets,
                                totalPriceFormatted: money.format(totalPaid),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        height: 38,
                        child: CheckboxListTile(
                          title: const Text('No cobrar tarifa a menores (Exención)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: noChargeMinors,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          onChanged: (val) => setStateDialog(() => noChargeMinors = val ?? false),
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (authorizedBy != null) ...[
                        SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4D3E),
                              side: const BorderSide(color: Color(0xFF1B4D3E)),
                              backgroundColor: Colors.green.shade50,
                            ),
                            icon: const Icon(Icons.vpn_key, size: 16),
                            label: Text('Generar PIN temporal para $authorizedBy', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            onPressed: () {
                              final newPin = AdminPinManager.generatePin(authorizedBy!);
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('PIN Generado: $authorizedBy'),
                                  content: Text('El PIN temporal es: $newPin\nVálido por 10 minutos y de un solo uso.'),
                                  actions: [
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Entendido'),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const Text('Autorización de Descuento (PIN Temporal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 48,
                              child: TextFormField(
                                controller: pinController,
                                obscureText: true,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(labelText: 'PIN de 4 dígitos', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: DropdownButtonFormField<String>(
                                value: authorizedBy,
                                decoration: const InputDecoration(labelText: 'Administrador', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                                items: ['Diego', 'Paula']
                                    .map((name) => DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (v) => setStateDialog(() => authorizedBy = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 48,
                              child: FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), padding: EdgeInsets.zero),
                                onPressed: () {
                                  if (authorizedBy == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un administrador')));
                                    return;
                                  }
                                  bool isValid = AdminPinManager.validateAndConsumePin(authorizedBy!, pinController.text);
                                  if (isValid) {
                                    setStateDialog(() => isDiscountUnlocked = true);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN válido. Descuento desbloqueado.')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN incorrecto, expirado (>10 min) o ya usado')));
                                  }
                                },
                                child: const Text('Validar', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 48,
                              child: DropdownButtonFormField<String>(
                                value: discountType,
                                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                                items: ['Fijo', 'Porcentaje'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: isDiscountUnlocked ? (v) => setStateDialog(() => discountType = v!) : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: TextFormField(
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                enabled: isDiscountUnlocked,
                                style: const TextStyle(fontSize: 13),
                                inputFormatters: discountType == 'Fijo' ? [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()] : [],
                                onChanged: (_) => setStateDialog(() {}),
                                decoration: InputDecoration(
                                  labelText: isDiscountUnlocked ? 'Valor' : 'Valide PIN primero',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  prefixText: discountType == 'Fijo' ? '\$ ' : '',
                                  suffixText: discountType == 'Porcentaje' ? '%' : '',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(flex: 2, child: SizedBox.shrink()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Text('Método de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 48,
                              child: DropdownButtonFormField<String>(
                                value: paymentMethod,
                                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                                items: ['Efectivo', 'Nequi / Daviplata', 'Tarjeta', 'Transferencia']
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (v) => setStateDialog(() => paymentMethod = v!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 48,
                              child: paymentMethod == 'Efectivo'
                                  ? TextFormField(
                                      controller: cashController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13),
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                                      onChanged: (_) => setStateDialog(() {}),
                                      decoration: const InputDecoration(
                                        labelText: 'Efectivo Entregado',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                        prefixText: '\$ ',
                                      ),
                                    )
                                  : (paymentMethod == 'Nequi / Daviplata'
                                      ? TextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          decoration: const InputDecoration(
                                            labelText: 'Celular Origen Nequi/Daviplata',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                            prefixIcon: Icon(Icons.phone_android, size: 18, color: Color(0xFF6A1B9A)),
                                          ),
                                        )
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('Pago directo seleccionado', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        )),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(flex: 2, child: SizedBox.shrink()),
                        ],
                      ),

                      if (paymentMethod == 'Efectivo') ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade300, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CAMBIO / VUELTAS:',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                              ),
                              Text(
                                money.format(change),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D3E),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    if (discountInput > 0 && !isDiscountUnlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe validar el PIN primero para aplicar el descuento')));
                      return;
                    }
                    if (paymentMethod == 'Efectivo' && cashInput < totalPaid) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El efectivo entregado es menor al total')));
                      return;
                    }

                    final currentLeader = _leader.text.trim();
                    final currentPhone = _whatsapp.text.trim();
                    final formattedTotal = money.format(totalPaid);
                    final transportSummary = transportList.join(', ');

                    // 1. Cerrar pasarela
                    Navigator.pop(dialogContext);

                    // 2. Registrar en base de datos
                    await _executeRegistration(state, selectedPackage, adults, minors, pets, totalPaid, paymentMethod);

                    // 3. Mostrar diálogo con el tiquet en formato vertical (9:16)
                    if (!context.mounted) return;
                    _showTicketPreviewDialog(
                      phone: currentPhone,
                      leaderName: currentLeader,
                      adults: adults,
                      minors: minors,
                      pets: pets,
                      totalPaidFormatted: formattedTotal,
                      transportInfo: transportSummary.isEmpty ? 'A pie' : transportSummary,
                    );
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Confirmar y Registrar', style: TextStyle(fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeRegistration(
    AppState state,
    dynamic selected,
    int adults,
    int minors,
    int pets,
    double totalPaid,
    String paymentMethod,
  ) async {
    setState(() => _saving = true);

    final allVehicles = [
      ..._cars.map((c) => c.text.trim().toUpperCase()),
      ..._motorcycles.map((m) => m.text.trim().toUpperCase()),
      ..._others.map((o) => o.type),
    ].where((p) => p.isNotEmpty).toList();

    await state.registerGroup(
      leader: _leader.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      adults: adults,
      minors: minors,
      pets: pets,
      servicePackage: selected,
      paymentMethod: paymentMethod,
      vehicles: allVehicles,
    );

    if (!mounted) return;
    _formKey.currentState!.reset();
    _leader.clear();
    _whatsapp.clear();
    _adults.text = '1';
    _minors.text = '0';
    _pets.text = '0';
    
    setState(() {
      _cars.clear();
      _motorcycles.clear();
      _others.clear();
      _transportAttempted = false;
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Ingreso registrado y guardado con éxito!')),
    );
  }

  Widget _ticketRow(String label, String value, {bool isBold = false, double size = 12, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1B4D3E)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isHighlight ? Colors.green.shade800 : Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
