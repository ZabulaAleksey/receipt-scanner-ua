import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner_mobile/main.dart';

void main() {
  testWidgets('Quick UX navigates offline from Home to Result and saves', (
    tester,
  ) async {
    await tester.pumpWidget(const ReceiptScannerApp());

    expect(find.text('Сканувати чек'), findsOneWidget);
    await tester.tap(find.text('Сканувати чек'));
    await tester.pumpAndSettle();
    expect(find.text('Симуляція сканування'), findsOneWidget);

    await tester.tap(find.textContaining('FX-01-CLEAN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Обробити приклад'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Почати демо'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Наступний етап'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Наступний етап'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Переглянути результат'));
    await tester.pumpAndSettle();

    expect(find.text('Результат'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Зберегти локально'), 300);
    expect(find.text('Зберегти локально'), findsOneWidget);
    await tester.tap(find.text('Зберегти локально'));
    await tester.pumpAndSettle();
    expect(find.text('Головна'), findsWidgets);
  });

  testWidgets('bottom navigation exposes the four primary contexts', (
    tester,
  ) async {
    await tester.pumpWidget(const ReceiptScannerApp());
    expect(find.text('Головна'), findsWidgets);
    expect(find.text('Перевірка'), findsOneWidget);
    expect(find.text('Історія'), findsOneWidget);
    expect(find.text('Налаштування'), findsOneWidget);

    await tester.tap(find.text('Налаштування'));
    await tester.pumpAndSettle();
    expect(find.text('Режим зберігання'), findsOneWidget);
  });

  testWidgets('all 15 typed routes render without component exceptions', (
    tester,
  ) async {
    final controller = AppController(dependencies: AppDependencies.create());
    for (final route in AppRoute.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: RoutePage(route: route, controller: controller),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: route.name);
    }
    expect(AppRoute.values, hasLength(15));
  });
}
