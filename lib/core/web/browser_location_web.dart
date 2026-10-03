import 'dart:html' as html;

String readAppHash() {
  var hash = html.window.location.hash;
  if (hash.startsWith('#')) hash = hash.substring(1);
  if (hash.startsWith('/')) hash = hash.substring(1);
  return hash.split('?').first.trim();
}

void writeAppHash(String slug) {
  final next = slug.isEmpty ? '#/' : '#/$slug';
  if (html.window.location.hash == next) return;
  html.window.history.replaceState(null, '', next);
}

void listenAppHash(void Function(String slug) onChange) {
  html.window.onHashChange.listen((_) => onChange(readAppHash()));
}
