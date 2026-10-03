import 'dart:html' as html;
import 'dart:typed_data';

Future<String> shareTicketImage({
  required Uint8List bytes,
  required String fileName,
  required String phone,
  required String message,
}) async {
  final blob = html.Blob([bytes], 'image/png');
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: objectUrl)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  Future<void>.delayed(const Duration(seconds: 30), () {
    html.Url.revokeObjectUrl(objectUrl);
  });

  _openWhatsAppChat(phone);
  return 'Tiquet generado y descargado. Se abrió la ventana de WhatsApp para enviar el soporte.';
}

void _openWhatsAppChat(String phone) {
  final whatsappPhone = _normalizeWhatsAppPhone(phone);
  final whatsappUrl = whatsappPhone.isEmpty
      ? Uri.parse('https://web.whatsapp.com/')
      : Uri.https('wa.me', '/$whatsappPhone');
  html.window.open(whatsappUrl.toString(), '_blank');
}

String _normalizeWhatsAppPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) return '57$digits';
  if (digits.startsWith('00')) return digits.substring(2);
  return digits;
}
