import 'package:flutter/foundation.dart';

import 'adapters.dart';
import 'composition.dart';
import 'domain.dart';
import 'ports.dart';

class AppController extends ChangeNotifier {
  AppController({required this.dependencies})
    : store = dependencies.store,
      fixturePort = dependencies.fixturePort,
      cameraPort = dependencies.cameraPort,
      reviewQueuePort = dependencies.reviewQueuePort,
      settingsPort = dependencies.settingsPort,
      selectedFixture = dependencies.fixturePort.byId('FX-01-CLEAN') {
    for (final fixture in fixturePort.scenarios.take(3)) {
      store.save(fixture);
    }
  }

  final AppDependencies dependencies;
  final ReceiptRepository store;
  final FixtureScenarioPort fixturePort;
  final CameraCapturePort cameraPort;
  final ReviewQueuePort reviewQueuePort;
  final SettingsPort settingsPort;
  final ProcessReceiptUseCase processUseCase = ProcessReceiptUseCase();
  late final SaveReceiptUseCase saveUseCase = SaveReceiptUseCase(store);
  late final CaptureReceiptUseCase captureUseCase = CaptureReceiptUseCase(
    cameraPort,
  );
  late final ReviewQueueUseCase reviewQueueUseCase = ReviewQueueUseCase(
    reviewQueuePort,
  );
  late final SettingsUseCase settingsUseCase = SettingsUseCase(settingsPort);
  ReceiptFixture selectedFixture;
  HomeState homeState = HomeState.normal;
  DemoState resultState = DemoState.normal;
  DemoState processingDemoState = DemoState.normal;
  DemoState reviewState = DemoState.normal;
  DemoState historyState = DemoState.normal;
  ProcessingState processingState = ProcessingState.idle;
  bool saved = false;

  int get reviewCount => reviewQueueUseCase.pending(store.receipts).length;
  StorageMode get storageMode => settingsUseCase.mode;

  void selectFixture(ReceiptFixture fixture) {
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

  void save() {
    saveUseCase.save(selectedFixture);
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
}
