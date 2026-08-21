import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:receipt_scanner_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline Quick UX completes without network dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(const ReceiptScannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сканувати чек'));
    await tester.pumpAndSettle();
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
    await tester.scrollUntilVisible(find.text('Зберегти локально'), 300);
    await tester.tap(find.text('Зберегти локально'));
    await tester.pumpAndSettle();

    expect(find.text('Головна'), findsWidgets);
  });
}
