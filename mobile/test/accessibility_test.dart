import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:receipt_scanner_mobile/main.dart';

void main() {
  testWidgets('primary actions have semantic labels and touch-safe size', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const ReceiptScannerApp());
    final scan = find.text('Сканувати чек');
    expect(scan, findsOneWidget);
    final buttonFinder = find.ancestor(
      of: scan,
      matching: find.byType(FilledButton),
    );
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNotNull);
    expect(tester.getSize(buttonFinder).height, greaterThanOrEqualTo(48));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('offline state exposes an explicit semantic announcement', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = AppController(dependencies: AppDependencies.create())
      ..setHomeState(HomeState.offline);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: RoutePage(route: AppRoute.home, controller: controller),
      ),
    );

    final banner = find.byType(InfoCard);
    expect(banner, findsOneWidget);
    expect(tester.getSemantics(banner).label, contains('Офлайн'));
    semantics.dispose();
  });
}
