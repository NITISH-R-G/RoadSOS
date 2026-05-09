import 'dart:math';

String generateSecureUuid() {
  final r = Random.secure();
  String hex(int bytes) => List.generate(bytes, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  return '${hex(4)}-${hex(2)}-4${hex(2).substring(1)}-${['8','9','a','b'][r.nextInt(4)]}${hex(2).substring(1)}-${hex(6)}';
}

void main() {
  print(generateSecureUuid());
}
