import 'package:flutter_test/flutter_test.dart';
import 'package:roadsos/services/india_emergency_routing.dart';

void main() {
  group('resolveIndiaEmergencyRoute', () {
    test('Bengaluru resolves to Karnataka', () {
      final r = resolveIndiaEmergencyRoute(12.9716, 77.5946);
      expect(r, isNotNull);
      expect(r!.stateCode, 'IN-KA');
      expect(r.ambulanceNumber, '108');
      expect(r.nationalNumber, '112');
    });

    test('outside India returns null', () {
      expect(resolveIndiaEmergencyRoute(40.7, -74.0), isNull);
    });
  });
}
