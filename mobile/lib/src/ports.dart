import 'domain.dart';

/// Stable boundary between UI and synthetic fixture data.
abstract interface class FixtureScenarioPort {
  List<ReceiptFixture> get scenarios;
  ReceiptFixture byId(String id);
  List<String> validate();
}

abstract interface class CameraCapturePort {
  CapturedDraft capture(ReceiptFixture fixture);
}

/// Application boundary for a single photo-library import.
abstract interface class ReceiptImageIntakePort {
  Future<ReceiptImageIntakeResult> selectFromGallery();
  Future<ReceiptImageIntakeResult?> recoverLostData();
  Future<ReceiptImageIntakeResult?> restoreStoredDraft();
  Future<void> discard(ReceiptImageDraft draft);
  Future<void> clearStaleDrafts();
}

class CapturedDraft {
  const CapturedDraft({required this.fixture, required this.sourceLabel});

  final ReceiptFixture fixture;
  final String sourceLabel;
}

abstract interface class ReviewQueuePort {
  List<ReceiptFixture> pending(List<ReceiptFixture> receipts);
}

abstract interface class SettingsPort {
  StorageMode get storageMode;
  void setStorageMode(StorageMode mode);
}
