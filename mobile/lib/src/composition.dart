import 'adapters.dart';
import 'domain.dart';
import 'ports.dart';

class AppDependencies {
  AppDependencies({
    required this.fixturePort,
    required this.cameraPort,
    required this.reviewQueuePort,
    required this.settingsPort,
    required this.store,
  });

  factory AppDependencies.create() => AppDependencies(
    fixturePort: const FixtureScenarioAdapter(),
    cameraPort: const DeterministicCameraCaptureAdapter(),
    reviewQueuePort: const InMemoryReviewQueueAdapter(),
    settingsPort: InMemorySettingsAdapter(),
    store: InMemoryReceiptStore(),
  );

  final FixtureScenarioPort fixturePort;
  final CameraCapturePort cameraPort;
  final ReviewQueuePort reviewQueuePort;
  final SettingsPort settingsPort;
  final ReceiptRepository store;
}
