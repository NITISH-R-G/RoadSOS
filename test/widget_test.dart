import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  testWidgets('RoadSOS smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: 'SUPABASE_URL=foo\nSUPABASE_ANON_KEY=bar');
    SharedPreferences.setMockInitialValues({
      // Consent + onboarding flags so app reaches Dashboard in tests.
      'dpdp_consent_accepted_at_iso8601': DateTime.now().toUtc().toIso8601String(),
      'permissions_onboarding_v1_done': true,
    });
    await tester.pumpWidget(const ProviderScope(child: RoadSOSApp()));
    // Allow async preference reads + first frame scheduling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Smoke: SOS button label should be visible somewhere in the home surface.
    expect(find.text('SOS'), findsWidgets);
  });
}
