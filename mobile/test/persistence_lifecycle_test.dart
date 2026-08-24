import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner_mobile/main.dart';
import 'package:receipt_scanner_mobile/src/adapters.dart';
import 'package:receipt_scanner_mobile/src/persistence.dart';

void main() {
  AppDependencies persistentDependencies(
    Future<ReceiptRepository> Function() loader,
  ) => AppDependencies(
    fixturePort: const FixtureScenarioAdapter(),
    cameraPort: const DeterministicCameraCaptureAdapter(),
    reviewQueuePort: const InMemoryReviewQueueAdapter(),
    settingsPort: InMemorySettingsAdapter(),
    store: null,
    repositoryLoader: loader,
  );

  testWidgets('persistent bootstrap renders true empty state', (tester) async {
    final ready = Completer<ReceiptRepository>();
    final controller = AppController(
      dependencies: persistentDependencies(() => ready.future),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RoutePage(route: AppRoute.home, controller: controller),
      ),
    );
    expect(controller.homeState, HomeState.loading);
    ready.complete(_TestRepository());
    await tester.pumpAndSettle();
    expect(controller.homeState, HomeState.empty);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('local read failure retries without fixture fallback', (
    tester,
  ) async {
    var attempts = 0;
    final repository = _TestRepository();
    final controller = AppController(
      dependencies: persistentDependencies(() async {
        attempts += 1;
        if (attempts == 1) {
          throw const ReceiptStorageException('local_open_failed');
        }
        return repository;
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RoutePage(route: AppRoute.home, controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.homeState, HomeState.error);
    expect(controller.receipts, isEmpty);
    expect(find.byType(ErrorState), findsOneWidget);

    await tester.tap(find.text('Повторити'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(controller.homeState, HomeState.empty);
    expect(controller.receipts, isEmpty);
  });

  testWidgets('History and Review show persistent loading and error states', (
    tester,
  ) async {
    final loading = Completer<ReceiptRepository>();
    final controller = AppController(
      dependencies: persistentDependencies(() => loading.future),
    );
    await tester.pumpWidget(
      MaterialApp(home: RoutePage(route: AppRoute.history, controller: controller)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    loading.completeError(const ReceiptStorageException('local_read_failed'));
    await tester.pumpAndSettle();
    expect(controller.historyState, DemoState.error);
    expect(find.byType(ErrorState), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: RoutePage(route: AppRoute.review, controller: controller)),
    );
    await tester.pump();
    expect(controller.reviewState, DemoState.error);
    expect(find.byType(ErrorState), findsOneWidget);
  });

  test(
    'persistent save awaits repository and prevents local duplicate',
    () async {
      final repository = _TestRepository();
      final controller = AppController(
        dependencies: persistentDependencies(() async => repository),
      );
      await controller.bootstrap();
      await controller.save();
      expect(controller.saved, isTrue);
      expect(controller.receipts, hasLength(1));
      expect(controller.homeState, HomeState.normal);
      await controller.save();
      expect(controller.saved, isFalse);
      expect(controller.receipts, hasLength(1));
      expect(repository.values, hasLength(1));
    },
  );

  test('dispose during bootstrap closes the late repository', () async {
    final ready = Completer<ReceiptRepository>();
    final repository = _TestRepository();
    final controller = AppController(
      dependencies: persistentDependencies(() => ready.future),
    );
    controller.dispose();
    ready.complete(repository);
    await Future<void>.delayed(Duration.zero);
    expect(repository.closed, isTrue);
  });

  test('close failure becomes a safe retryable error state', () async {
    final repository = _TestRepository(failClose: true);
    final controller = AppController(
      dependencies: persistentDependencies(() async => repository),
    );
    await controller.bootstrap();
    await controller.retryLocalStorage();
    expect(controller.homeState, HomeState.error);
  });
}

class _TestRepository implements ReceiptRepository {
  _TestRepository({this.failClose = false});

  final List<ReceiptAggregate> values = [];
  final bool failClose;
  var closed = false;

  @override
  Future<void> close() async {
    closed = true;
    if (failClose) throw StateError('close failed');
  }

  @override
  Future<List<ReceiptAggregate>> load() async => List.of(values);

  @override
  Future<void> save(ReceiptAggregate receipt) async {
    if (values.any((item) => item.id == receipt.id)) {
      throw const ReceiptStorageException('duplicate_id');
    }
    values.insert(0, receipt);
  }
}
