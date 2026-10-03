import 'dart:typed_data';

import 'ticket_share_stub.dart'
    if (dart.library.html) 'ticket_share_web.dart'
    if (dart.library.io) 'ticket_share_native.dart' as platform;

Future<String> shareTicketImage({
  required Uint8List bytes,
  required String fileName,
  required String phone,
  required String message,
}) {
  return platform.shareTicketImage(
    bytes: bytes,
    fileName: fileName,
    phone: phone,
    message: message,
  );
}
