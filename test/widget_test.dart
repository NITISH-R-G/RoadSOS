import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos/main.dart';

void main() {
  testWidgets('RoadSOS smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RoadSOSApp()));

    // Verify that the SOS button is present.
    expect(find.text('SOS'), findsOneWidget);
  });
}
