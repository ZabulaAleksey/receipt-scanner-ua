import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:receipt_scanner_mobile/main.dart';
import 'package:receipt_scanner_mobile/src/adapters.dart';
import 'package:receipt_scanner_mobile/src/persistence.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('local receipt survives a repository reopen without network', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp('receipt-r04-e2e-');
    final path = '${directory.path}${Platform.pathSeparator}receipts.db';
    final first = await SqliteReceiptRepository.open(path);
    const receipt = ReceiptAggregate(
      id: 'R04-INTEGRATION',
      merchant: 'Offline local store',
      date: '2026-08-21',
      total: Money(3799),
      items: <LineItem>[],
    );
    await first.save(receipt);
    await first.close();

    final controller = AppController(
      dependencies: AppDependencies(
        fixturePort: const FixtureScenarioAdapter(),
        cameraPort: const DeterministicCameraCaptureAdapter(),
        reviewQueuePort: const InMemoryReviewQueueAdapter(),
        settingsPort: InMemorySettingsAdapter(),
        store: null,
        repositoryLoader: () => SqliteReceiptRepository.open(path),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: RoutePage(route: AppRoute.home, controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(controller.homeState, HomeState.normal);
    expect(find.text('Offline local store'), findsOneWidget);
    expect(find.text('37,99 UAH'), findsOneWidget);

    controller.dispose();
    await directory.delete(recursive: true);
  });
}
