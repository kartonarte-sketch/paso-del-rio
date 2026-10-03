import 'dart:typed_data';

import 'package:flutter/services.dart';

const _channel = MethodChannel('paso_del_rio/ticket_share');

Future<String> shareTicketImage({
  required Uint8List bytes,
  required String fileName,
  required String phone,
  required String message,
}) async {
  try {
    final result = await _channel.invokeMethod<String>('shareTicketImage', {
      'bytes': bytes,
      'fileName': fileName,
      'phone': phone,
      'message': message,
    });
    return result ?? 'WhatsApp abierto con el pase listo para enviar.';
  } on MissingPluginException {
    return 'Imagen generada. Esta plataforma todavía no tiene integración nativa con WhatsApp.';
  } on PlatformException catch (error) {
    return error.message ?? 'No se pudo abrir WhatsApp con la imagen.';
  }
}
