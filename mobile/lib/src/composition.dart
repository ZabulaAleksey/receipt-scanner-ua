import 'adapters.dart';
import 'persistence.dart';
import 'domain.dart';
import 'ports.dart';

class AppDependencies {
  AppDependencies({
    required this.fixturePort,
    required this.cameraPort,
    required this.reviewQueuePort,
    required this.settingsPort,
    required this.store,
    this.repositoryLoader,
  });

  factory AppDependencies.create() => AppDependencies(
    fixturePort: const FixtureScenarioAdapter(),
    cameraPort: const DeterministicCameraCaptureAdapter(),
    reviewQueuePort: const InMemoryReviewQueueAdapter(),
    settingsPort: InMemorySettingsAdapter(),
    store: InMemoryReceiptStore(),
  );

  /// Production composition has no fixture seed and opens only local storage.
  factory AppDependencies.createPersistent({
    Future<ReceiptRepository> Function()? repositoryLoader,
  }) => AppDependencies(
    fixturePort: const FixtureScenarioAdapter(),
    cameraPort: const DeterministicCameraCaptureAdapter(),
    reviewQueuePort: const InMemoryReviewQueueAdapter(),
    settingsPort: InMemorySettingsAdapter(),
    store: null,
    repositoryLoader:
        repositoryLoader ?? SqliteReceiptRepository.openInAppStorage,
  );

  final FixtureScenarioPort fixturePort;
  final CameraCapturePort cameraPort;
  final ReviewQueuePort reviewQueuePort;
  final SettingsPort settingsPort;
  final LegacyReceiptRepository? store;
  final Future<ReceiptRepository> Function()? repositoryLoader;
}
