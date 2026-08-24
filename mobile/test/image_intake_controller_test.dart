import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner_mobile/main.dart';
import 'package:receipt_scanner_mobile/src/adapters.dart';
import 'package:receipt_scanner_mobile/src/image_intake.dart';
import 'package:receipt_scanner_mobile/src/ports.dart';

void main() {
  AppDependencies dependencies(ReceiptImageIntakePort port) => AppDependencies(
    fixturePort: const FixtureScenarioAdapter(),
    cameraPort: const DeterministicCameraCaptureAdapter(),
    reviewQueuePort: const InMemoryReviewQueueAdapter(),
    settingsPort: InMemorySettingsAdapter(),
    store: InMemoryReceiptStore(),
    imageIntakePort: port,
  );

  test(
    'selection publishes a safe ready draft without receipt persistence',
    () async {
      final draft = ReceiptImageDraft(
        id: 'generated-id',
        storageRef: 'receipt_images/generated-id.jpg',
        mimeType: 'image/jpeg',
        byteSize: 42,
        width: 2,
        height: 3,
        source: ReceiptImageSource.gallery,
      );
      final controller = AppController(
        dependencies: dependencies(
          DeterministicReceiptImageIntakeAdapter(
            selection: ReceiptImageReady(draft),
          ),
        ),
      );

      await controller.selectReceiptImage();

      expect(controller.imageIntakeState, ReceiptImageIntakeState.ready);
      expect(
        controller.imageDraft?.storageRef,
        'receipt_images/generated-id.jpg',
      );
      expect(controller.receipts, hasLength(3));
    },
  );

  test('cancel is not an error and operational failure is retryable', () async {
    final cancelled = AppController(
      dependencies: dependencies(
        const DeterministicReceiptImageIntakeAdapter(),
      ),
    );
    await cancelled.selectReceiptImage();
    expect(cancelled.imageIntakeState, ReceiptImageIntakeState.cancelled);
    expect(cancelled.imageFailure, isNull);

    final failed = AppController(
      dependencies: dependencies(
        const DeterministicReceiptImageIntakeAdapter(
          selection: ReceiptImageFailed(
            ReceiptImageFailure(
              ReceiptImageFailureKind.localImportError,
              retryable: true,
            ),
          ),
        ),
      ),
    );
    await failed.selectReceiptImage();
    expect(failed.imageIntakeState, ReceiptImageIntakeState.error);
    expect(failed.imageFailure?.retryable, isTrue);
  });

  test('lost data follows the same result pipeline', () async {
    final controller = AppController(
      dependencies: dependencies(
        DeterministicReceiptImageIntakeAdapter(
          recovered: ReceiptImageReady(
            ReceiptImageDraft(
              id: 'recovered',
              storageRef: 'receipt_images/recovered.png',
              mimeType: 'image/png',
              byteSize: 24,
              width: 1,
              height: 1,
              source: ReceiptImageSource.recoveredGallery,
            ),
          ),
        ),
      ),
    );

    await controller.recoverLostImageData();
    expect(controller.imageIntakeState, ReceiptImageIntakeState.ready);
    expect(controller.imageDraft?.source, ReceiptImageSource.recoveredGallery);
  });

  test('stored draft is restored before the next picker interaction', () async {
    final controller = AppController(
      dependencies: dependencies(
        DeterministicReceiptImageIntakeAdapter(
          stored: ReceiptImageReady(
            ReceiptImageDraft(
              id: 'stored',
              storageRef: 'receipt_images/stored.jpg',
              mimeType: 'image/jpeg',
              byteSize: 12,
              width: 2,
              height: 3,
              source: ReceiptImageSource.gallery,
            ),
          ),
        ),
      ),
    );

    await controller.recoverLostImageData();

    expect(controller.imageIntakeState, ReceiptImageIntakeState.ready);
    expect(controller.imageDraft?.id, 'stored');
  });

  test(
    'selecting a synthetic fixture clears a prior local image draft',
    () async {
      final controller = AppController(
        dependencies: dependencies(
          DeterministicReceiptImageIntakeAdapter(
            selection: ReceiptImageReady(
              ReceiptImageDraft(
                id: 'prior',
                storageRef: 'receipt_images/prior.jpg',
                mimeType: 'image/jpeg',
                byteSize: 1,
                width: 1,
                height: 1,
                source: ReceiptImageSource.gallery,
              ),
            ),
          ),
        ),
      );
      await controller.selectReceiptImage();

      controller.selectFixture(
        controller.fixturePort.byId('FX-02-LOW-CONFIDENCE'),
      );

      expect(controller.imageDraft, isNull);
      expect(controller.imageIntakeState, ReceiptImageIntakeState.idle);
    },
  );
}
