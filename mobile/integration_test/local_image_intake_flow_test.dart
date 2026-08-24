import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:receipt_scanner_mobile/main.dart';
import 'package:receipt_scanner_mobile/src/adapters.dart';
import 'package:receipt_scanner_mobile/src/image_intake.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('local image draft reaches Preview without creating a receipt', (
    tester,
  ) async {
    const draft = ReceiptImageDraft(
      id: 'image-r05-integration',
      storageRef: 'receipt_images/image-r05-integration.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024,
      width: 1200,
      height: 1600,
      source: ReceiptImageSource.gallery,
    );
    final dependencies = AppDependencies(
      fixturePort: const FixtureScenarioAdapter(),
      cameraPort: const DeterministicCameraCaptureAdapter(),
      reviewQueuePort: const InMemoryReviewQueueAdapter(),
      settingsPort: InMemorySettingsAdapter(),
      imageIntakePort: const DeterministicReceiptImageIntakeAdapter(
        selection: ReceiptImageReady(draft),
      ),
      store: InMemoryReceiptStore(),
    );

    await tester.pumpWidget(ReceiptScannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сканувати чек'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вибрати фото чека'));
    await tester.pumpAndSettle();

    expect(find.text('Фото чека збережено локально'), findsOneWidget);
    expect(
      find.text('OCR ще не запущено. Фото не додано до бази чеків.'),
      findsOneWidget,
    );
    expect(find.text('1200 × 1600 px'), findsOneWidget);
    expect(find.text('1024 bytes · image/jpeg'), findsOneWidget);
  });
}
