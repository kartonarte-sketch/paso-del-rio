import 'dart:typed_data';

Future<String> shareTicketImage({
  required Uint8List bytes,
  required String fileName,
  required String phone,
  required String message,
}) async {
  final hasGeneratedImage = bytes.isNotEmpty && fileName.isNotEmpty;
  final hasDestination = phone.isNotEmpty || message.isNotEmpty;
  if (hasGeneratedImage && hasDestination) {
    return 'Imagen generada en memoria. En esta plataforma falta conectar el canal nativo para compartir archivos.';
  }
  return 'No se pudo preparar la imagen para compartir en esta plataforma.';
}
