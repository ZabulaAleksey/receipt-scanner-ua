import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner_mobile/main.dart';

void main() {
  Future<AppController> pumpRoute(WidgetTester tester, AppRoute route) async {
    final dependencies = AppDependencies.create();
    final controller = AppController(dependencies: dependencies);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: RoutePage(route: route, controller: controller),
      ),
    );
    await tester.pump();
    return controller;
  }

  testWidgets('Home renders loading, empty, error and offline states', (
    tester,
  ) async {
    final controller = await pumpRoute(tester, AppRoute.home);
    controller.setHomeState(HomeState.loading);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.setHomeState(HomeState.empty);
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);
    controller.setHomeState(HomeState.error);
    await tester.pump();
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Повторити'), findsOneWidget);
    await tester.tap(find.text('Повторити'));
    await tester.pump();
    expect(find.byType(ErrorState), findsNothing);
    controller.setHomeState(HomeState.offline);
    await tester.pump();
    expect(find.text('Офлайн режим'), findsOneWidget);
  });

  for (final route in [
    AppRoute.processing,
    AppRoute.result,
    AppRoute.review,
    AppRoute.history,
  ]) {
    testWidgets('${route.name} renders deterministic non-happy states', (
      tester,
    ) async {
      final controller = await pumpRoute(tester, route);
      Finder? currentDataFinder() => switch (route) {
        AppRoute.result => find.byType(ReceiptSummary),
        AppRoute.review || AppRoute.history => find.byType(ReceiptCard),
        _ => null,
      };

      void setState(DemoState state) {
        switch (route) {
          case AppRoute.processing:
            controller.setProcessingDemoState(state);
          case AppRoute.result:
            controller.setResultState(state);
          case AppRoute.review:
            controller.setReviewState(state);
          case AppRoute.history:
            controller.setHistoryState(state);
          default:
            throw StateError('Unsupported route: $route');
        }
      }

      setState(DemoState.loading);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      if (currentDataFinder() case final finder?) {
        expect(finder, findsNothing);
      }
      setState(DemoState.empty);
      await tester.pump();
      expect(find.byType(EmptyState), findsWidgets);
      if (currentDataFinder() case final finder?) {
        expect(finder, findsNothing);
      }
      setState(DemoState.offline);
      await tester.pump();
      expect(
        route == AppRoute.processing
            ? find.byType(InfoCard)
            : find.byType(OfflineBanner),
        findsWidgets,
      );
      if (currentDataFinder() case final finder?) {
        expect(finder, findsWidgets);
      }
      setState(DemoState.error);
      await tester.pump();
      expect(find.byType(ErrorState), findsWidgets);
      expect(find.text('Повторити'), findsOneWidget);
      if (currentDataFinder() case final finder?) {
        expect(finder, findsNothing);
      }
      if (route == AppRoute.result) {
        expect(find.text('Зберегти локально'), findsNothing);
      }
      if (route == AppRoute.processing) {
        expect(find.text('Наступний етап'), findsNothing);
      }
      await tester.tap(find.text('Повторити'));
      await tester.pump();
      expect(find.byType(ErrorState), findsNothing);
    });
  }
}
