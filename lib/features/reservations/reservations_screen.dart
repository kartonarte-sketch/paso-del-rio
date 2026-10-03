import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final state = context.read<AppState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final party = TextEditingController(text: '4');
    var date = DateTime.now().add(const Duration(days: 1));
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva reserva'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Responsable'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'WhatsApp'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: party,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Personas'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black26),
                  ),
                  title: const Text('Fecha y hora'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(date)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: date,
                    );
                    if (pickedDate == null || !context.mounted) return;
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(date),
                    );
                    if (pickedTime == null) return;
                    setDialogState(
                      () => date = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && name.text.trim().isNotEmpty) {
      await state.createReservation(
        name: name.text.trim(),
        whatsapp: phone.text.trim(),
        partySize: int.tryParse(party.text) ?? 1,
        scheduledAt: date,
      );
    }
    name.dispose();
    phone.dispose();
    party.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: const Text('Nueva reserva'),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.reservations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No hay reservas registradas.')),
                  )
                : Column(
                    children: state.reservations
                        .map(
                          (reservation) => ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.event_seat),
                            ),
                            title: Text(reservation.name),
                            subtitle: Text(
                              '${reservation.partySize} personas · ${reservation.whatsapp}',
                            ),
                            trailing: Text(
                              DateFormat('dd/MM\nHH:mm')
                                  .format(reservation.scheduledAt.toLocal()),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
