import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:roadsos/main.dart';

void main() {
  testWidgets('RoadSOS smoke test', (WidgetTester tester) async {
    // Set surface size to prevent RenderFlex overflow in Dashboard
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RoadSOSApp()));
    await tester.pump();

    // Verify that the SOS button is present.
    expect(find.text('SOS'), findsOneWidget);

    // Reset back
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
