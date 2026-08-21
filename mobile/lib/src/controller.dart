import 'dart:async';

import 'package:flutter/foundation.dart';

import 'adapters.dart';
import 'composition.dart';
import 'domain.dart';
import 'persistence.dart';
import 'ports.dart';

class AppController extends ChangeNotifier {
  AppController({required this.dependencies})
    : legacyStore = dependencies.store,
      fixturePort = dependencies.fixturePort,
      cameraPort = dependencies.cameraPort,
      reviewQueuePort = dependencies.reviewQueuePort,
      settingsPort = dependencies.settingsPort,
      imageIntakePort = dependencies.imageIntakePort,
      selectedFixture = dependencies.fixturePort.byId('FX-01-CLEAN') {
    if (legacyStore case final store?) {
      // Fixture/demo composition is explicit and never used for user storage.
      for (final fixture in fixturePort.scenarios.take(3)) {
        store.save(fixture);
      }
      _receipts = List<ReceiptFixture>.of(store.receipts);
    } else {
      homeState = HomeState.loading;
      unawaited(bootstrap());
    }
  }

  final AppDependencies dependencies;
  final LegacyReceiptRepository? legacyStore;
  final FixtureScenarioPort fixturePort;
  final CameraCapturePort cameraPort;
  final ReviewQueuePort reviewQueuePort;
  final SettingsPort settingsPort;
  final ReceiptImageIntakePort imageIntakePort;
  final ProcessReceiptUseCase processUseCase = ProcessReceiptUseCase();
  late final SaveReceiptUseCase saveUseCase = SaveReceiptUseCase(legacyStore!);
  late final CaptureReceiptUseCase captureUseCase = CaptureReceiptUseCase(
    cameraPort,
  );
  late final ReviewQueueUseCase reviewQueueUseCase = ReviewQueueUseCase(
    reviewQueuePort,
  );
  late final SettingsUseCase settingsUseCase = SettingsUseCase(settingsPort);

  ReceiptRepository? _repository;
  List<ReceiptFixture> _receipts = const [];
  var _disposed = false;
  ReceiptFixture selectedFixture;
  HomeState homeState = HomeState.normal;
  DemoState resultState = DemoState.normal;
  DemoState processingDemoState = DemoState.normal;
  DemoState reviewState = DemoState.normal;
  DemoState historyState = DemoState.normal;
  ProcessingState processingState = ProcessingState.idle;
  bool saved = false;
  ReceiptImageIntakeState imageIntakeState = ReceiptImageIntakeState.idle;
  ReceiptImageDraft? imageDraft;
  ReceiptImageFailure? imageFailure;

  List<ReceiptFixture> get receipts => List.unmodifiable(_receipts);
  int get reviewCount => reviewQueueUseCase.pending(receipts).length;
  StorageMode get storageMode => settingsUseCase.mode;
  bool get isPersistent => dependencies.repositoryLoader != null;

  Future<void> bootstrap() async {
    final loader = dependencies.repositoryLoader;
    if (loader == null || _disposed) {
      await recoverLostImageData();
      return;
    }

    _setPersistentState(HomeState.loading);
    final previous = _repository;
    _repository = null;
    if (previous != null && !await _closeSafely(previous)) {
      _setPersistentState(HomeState.error);
      return;
    }
    ReceiptRepository? repository;
    try {
      repository = await loader();
      final aggregates = await repository.load();
      if (_disposed) {
        await _closeSafely(repository);
        return;
      }
      _repository = repository;
      _receipts = aggregates.map(fixtureFromAggregate).toList(growable: false);
      _setPersistentState(
        _receipts.isEmpty ? HomeState.empty : HomeState.normal,
      );
      await recoverLostImageData();
    } catch (_) {
      if (repository != null) {
        await _closeSafely(repository);
      }
      if (_disposed) return;
      // Details can contain storage paths or implementation data; UI only sees
      // the safe state category.
      _receipts = const [];
      _setPersistentState(HomeState.error);
    }
  }

  Future<void> selectReceiptImage() async {
    if (_disposed) return;
    final previousDraft = imageDraft;
    imageIntakeState = ReceiptImageIntakeState.selecting;
    imageFailure = null;
    notifyListeners();
    final result = await imageIntakePort.selectFromGallery();
    await _applyImageIntakeResult(result, previousDraft: previousDraft);
  }

  Future<void> retryReceiptImage() => selectReceiptImage();

  Future<void> recoverLostImageData() async {
    if (_disposed) return;
    await imageIntakePort.clearStaleDrafts();
    final stored = await imageIntakePort.restoreStoredDraft();
    if (stored != null) await _applyImageIntakeResult(stored);
    final previousDraft = imageDraft;
    final result = await imageIntakePort.recoverLostData();
    if (result != null) {
      await _applyImageIntakeResult(result, previousDraft: previousDraft);
    }
  }

  Future<void> _applyImageIntakeResult(
    ReceiptImageIntakeResult result, {
    ReceiptImageDraft? previousDraft,
  }) async {
    if (_disposed) return;
    switch (result) {
      case ReceiptImageReady(:final draft):
        if (previousDraft != null && previousDraft.id != draft.id) {
          await imageIntakePort.discard(previousDraft);
        }
        imageDraft = draft;
        imageFailure = null;
        imageIntakeState = ReceiptImageIntakeState.ready;
      case ReceiptImageCancelled():
        imageFailure = null;
        imageIntakeState = previousDraft == null
            ? ReceiptImageIntakeState.cancelled
            : ReceiptImageIntakeState.ready;
      case ReceiptImageFailed(:final failure):
        imageDraft = previousDraft;
        imageFailure = failure;
        imageIntakeState = ReceiptImageIntakeState.error;
    }
    notifyListeners();
  }

  Future<bool> _closeSafely(ReceiptRepository repository) async {
    try {
      await repository.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setPersistentState(HomeState state) {
    if (_disposed) return;
    homeState = state;
    reviewState = switch (state) {
      HomeState.loading => DemoState.loading,
      HomeState.empty => DemoState.empty,
      HomeState.error => DemoState.error,
      HomeState.normal || HomeState.offline => DemoState.normal,
    };
    historyState = reviewState;
    notifyListeners();
  }

  Future<void> retryLocalStorage() async {
    if (!isPersistent) {
      setHomeState(HomeState.normal);
      return;
    }
    await bootstrap();
  }

  void selectFixture(ReceiptFixture fixture) {
    final previousDraft = imageDraft;
    imageDraft = null;
    imageFailure = null;
    imageIntakeState = ReceiptImageIntakeState.idle;
    if (previousDraft != null)
      unawaited(imageIntakePort.discard(previousDraft));
    selectedFixture = fixture;
    saved = false;
    processingState = ProcessingState.idle;
    notifyListeners();
  }

  void beginProcessing() {
    final captured = captureUseCase.capture(selectedFixture);
    selectedFixture = processUseCase.process(captured.fixture);
    processingState = ProcessingState.queued;
    notifyListeners();
  }

  void advanceProcessing() {
    processingState = switch (processingState) {
      ProcessingState.queued => ProcessingState.recognizing,
      ProcessingState.recognizing => ProcessingState.parsing,
      ProcessingState.parsing => ProcessingState.localComplete,
      _ => ProcessingState.localComplete,
    };
    notifyListeners();
  }

  void failProcessing() {
    processingState = ProcessingState.failed;
    notifyListeners();
  }

  Future<void> save() async {
    final repository = _repository;
    if (isPersistent) {
      if (repository == null) {
        homeState = HomeState.error;
        notifyListeners();
        return;
      }
      try {
        await repository.save(aggregateFromFixture(selectedFixture));
        _receipts = [selectedFixture, ..._receipts];
        _setPersistentState(HomeState.normal);
      } on ReceiptStorageException {
        saved = false;
        homeState = HomeState.error;
        notifyListeners();
        return;
      }
    } else {
      saveUseCase.save(selectedFixture);
      _receipts = List<ReceiptFixture>.of(legacyStore!.receipts);
    }
    saved = true;
    notifyListeners();
  }

  void setHomeState(HomeState state) {
    homeState = state;
    notifyListeners();
  }

  void setResultState(DemoState state) {
    resultState = state;
    notifyListeners();
  }

  void setProcessingDemoState(DemoState state) {
    processingDemoState = state;
    notifyListeners();
  }

  void setReviewState(DemoState state) {
    reviewState = state;
    notifyListeners();
  }

  void setHistoryState(DemoState state) {
    historyState = state;
    notifyListeners();
  }

  void setStorageMode(StorageMode mode) {
    settingsUseCase.setMode(mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final repository = _repository;
    if (repository != null) {
      unawaited(repository.close());
    }
    super.dispose();
  }
}
