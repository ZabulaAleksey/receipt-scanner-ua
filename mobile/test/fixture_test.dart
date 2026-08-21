import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner_mobile/src/adapters.dart';
import 'package:receipt_scanner_mobile/src/composition.dart';
import 'package:receipt_scanner_mobile/src/controller.dart';
import 'package:receipt_scanner_mobile/src/domain.dart';
import 'package:receipt_scanner_mobile/src/fixtures.dart';
import 'package:receipt_scanner_mobile/src/ports.dart';

void main() {
  test('fixture adapter exposes stable ids and validates money precision', () {
    expect(FixtureRepository.validate(), isEmpty);
    final clean = FixtureRepository.byId('FX-01-CLEAN');
    expect(clean.items, hasLength(5));
    expect(
      clean.items.fold<int>(0, (sum, item) => sum + item.price.minor),
      clean.total.minor,
    );
    expect(clean.needsReview, isFalse);
    expect(
      FixtureRepository.byId('FX-02-LOW-CONFIDENCE')
          .items
          .single
          .parsed
          .confidence,
      lessThan(80),
    );
    expect(
      FixtureRepository.byId('FX-02-LOW-CONFIDENCE').items.single.candidates,
      hasLength(2),
    );
    expect(
      FixtureRepository.byId('FX-03-UNKNOWN-MERCHANT').unknownMerchant,
      isTrue,
    );
    expect(
      FixtureRepository.byId('FX-03-UNKNOWN-MERCHANT').rawMerchantAddress,
      isNotEmpty,
    );
    expect(const Money(4290).formatted, '42,90 UAH');
  });

  test('store and use cases preserve local receipt flow', () {
    final store = InMemoryReceiptStore();
    final fixture = FixtureRepository.byId('FX-09-OFFLINE');
    SaveReceiptUseCase(store).save(ProcessReceiptUseCase().process(fixture));
    expect(store.receipts.single.id, 'FX-09-OFFLINE');
    SaveReceiptUseCase(store).save(fixture);
    expect(store.receipts, hasLength(1));
  });

  test('controller consumes captured draft through processing before save', () {
    final replacement = FixtureRepository.byId('FX-09-OFFLINE');
    final store = InMemoryReceiptStore();
    final controller = AppController(
      dependencies: AppDependencies(
        fixturePort: const FixtureScenarioAdapter(),
        cameraPort: _ReplacingCameraCaptureAdapter(replacement),
        reviewQueuePort: const InMemoryReviewQueueAdapter(),
        settingsPort: InMemorySettingsAdapter(),
        store: store,
      ),
    );

    controller.selectFixture(FixtureRepository.byId('FX-01-CLEAN'));
    controller.beginProcessing();
    expect(controller.selectedFixture.id, 'FX-09-OFFLINE');
    controller.save();
    expect(store.receipts.first.id, 'FX-09-OFFLINE');
  });
}

class _ReplacingCameraCaptureAdapter implements CameraCapturePort {
  const _ReplacingCameraCaptureAdapter(this.replacement);

  final ReceiptFixture replacement;

  @override
  CapturedDraft capture(ReceiptFixture fixture) => CapturedDraft(
    fixture: replacement,
    sourceLabel: 'replacement for ${fixture.id}',
  );
}
