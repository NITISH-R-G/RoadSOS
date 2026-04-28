import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos/main.dart';
import 'package:roadsos/ui/dashboard.dart';

void main() {
  testWidgets('RoadSOS smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RoadSOSApp()));
    await tester.pumpAndSettle();

    final BuildContext ctx = tester.element(find.byType(DashboardScreen));
    final l10n = AppLocalizations.of(ctx)!;
    expect(find.text(l10n.sosButton), findsOneWidget);
  });
}
