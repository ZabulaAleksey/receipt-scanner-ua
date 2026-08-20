import 'domain.dart';
import 'fixtures.dart';
import 'ports.dart';

class FixtureScenarioAdapter implements FixtureScenarioPort {
  const FixtureScenarioAdapter();

  @override
  List<ReceiptFixture> get scenarios => FixtureRepository.all;

  @override
  ReceiptFixture byId(String id) => FixtureRepository.byId(id);

  @override
  List<String> validate() => FixtureRepository.validate();
}

class DeterministicCameraCaptureAdapter implements CameraCapturePort {
  const DeterministicCameraCaptureAdapter();

  @override
  CapturedDraft capture(ReceiptFixture fixture) => CapturedDraft(
    fixture: fixture,
    sourceLabel: 'synthetic capture ${fixture.id}',
  );
}

class InMemoryReviewQueueAdapter implements ReviewQueuePort {
  const InMemoryReviewQueueAdapter();

  @override
  List<ReceiptFixture> pending(List<ReceiptFixture> receipts) =>
      receipts.where((receipt) => receipt.needsReview).toList(growable: false);
}

class InMemorySettingsAdapter implements SettingsPort {
  StorageMode _mode = StorageMode.localOnly;

  @override
  StorageMode get storageMode => _mode;

  @override
  void setStorageMode(StorageMode mode) => _mode = mode;
}

class CaptureReceiptUseCase {
  const CaptureReceiptUseCase(this.port);

  final CameraCapturePort port;

  CapturedDraft capture(ReceiptFixture fixture) => port.capture(fixture);
}

class ReviewQueueUseCase {
  const ReviewQueueUseCase(this.port);

  final ReviewQueuePort port;

  List<ReceiptFixture> pending(List<ReceiptFixture> receipts) =>
      port.pending(receipts);
}

class SettingsUseCase {
  const SettingsUseCase(this.port);

  final SettingsPort port;

  StorageMode get mode => port.storageMode;
  void setMode(StorageMode mode) => port.setStorageMode(mode);
}
