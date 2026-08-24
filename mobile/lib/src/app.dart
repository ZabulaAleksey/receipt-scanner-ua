import 'package:flutter/material.dart';

import 'composition.dart';
import 'controller.dart';
import 'design_system.dart';
import 'domain.dart';

class ReceiptScannerApp extends StatefulWidget {
  const ReceiptScannerApp({
    this.dependencies,
    this.usePersistentStorage = false,
    super.key,
  });

  final AppDependencies? dependencies;
  final bool usePersistentStorage;

  @override
  State<ReceiptScannerApp> createState() => _ReceiptScannerAppState();
}

class _ReceiptScannerAppState extends State<ReceiptScannerApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(
      dependencies:
          widget.dependencies ??
          (widget.usePersistentStorage
              ? AppDependencies.createPersistent()
              : AppDependencies.create()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Receipt Scanner',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    initialRoute: AppRoute.home.path,
    onGenerateRoute: (settings) {
      final route = AppRoute.fromPath(settings.name);
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => RoutePage(route: route, controller: controller),
      );
    },
  );
}

class RoutePage extends StatelessWidget {
  const RoutePage({required this.route, required this.controller, super.key});

  final AppRoute route;
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => AppFrame(
      controller: controller,
      route: route,
      child: _screenFor(route, controller),
    ),
  );
}

Widget _screenFor(AppRoute route, AppController controller) => switch (route) {
  AppRoute.home => HomeScreen(controller: controller),
  AppRoute.scan => ScanScreen(controller: controller),
  AppRoute.preview => PreviewScreen(controller: controller),
  AppRoute.processing => ProcessingScreen(controller: controller),
  AppRoute.result => ResultScreen(controller: controller),
  AppRoute.review => ReviewScreen(controller: controller),
  AppRoute.correction => CorrectionScreen(controller: controller),
  AppRoute.merchant => MerchantScreen(controller: controller),
  AppRoute.detail => DetailScreen(controller: controller),
  AppRoute.history => HistoryScreen(controller: controller),
  AppRoute.priceHistory => PriceHistoryScreen(controller: controller),
  AppRoute.insights => InsightsScreen(controller: controller),
  AppRoute.settings => SettingsScreen(controller: controller),
  AppRoute.backup => BackupScreen(controller: controller),
  AppRoute.business => BusinessScreen(controller: controller),
};

class AppFrame extends StatelessWidget {
  const AppFrame({
    required this.controller,
    required this.route,
    required this.child,
    super.key,
  });

  final AppController controller;
  final AppRoute route;
  final Widget child;

  int get _tabIndex => switch (route) {
    AppRoute.review || AppRoute.correction || AppRoute.merchant => 1,
    AppRoute.history ||
    AppRoute.detail ||
    AppRoute.priceHistory ||
    AppRoute.insights => 2,
    AppRoute.settings || AppRoute.backup || AppRoute.business => 3,
    _ => 0,
  };

  void _selectTab(BuildContext context, int index) {
    final route = [
      AppRoute.home,
      AppRoute.review,
      AppRoute.history,
      AppRoute.settings,
    ][index];
    Navigator.of(context).pushNamedAndRemoveUntil(route.path, (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: route == AppRoute.home
        ? null
        : AppBar(
            title: Text(_title(route)),
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    tooltip: 'Назад',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
          ),
    body: SafeArea(child: child),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tabIndex,
      onDestinationSelected: (index) => _selectTab(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Головна',
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: 'Перевірка',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: 'Історія'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Налаштування',
        ),
      ],
    ),
  );
}

String _title(AppRoute route) => switch (route) {
  AppRoute.scan => 'Симуляція сканування',
  AppRoute.preview => 'Перевірка фото',
  AppRoute.processing => 'Обробка',
  AppRoute.result => 'Результат',
  AppRoute.review => 'Черга перевірки',
  AppRoute.correction => 'Виправлення рядка',
  AppRoute.merchant => 'Невідомий продавець',
  AppRoute.detail => 'Деталі чека',
  AppRoute.history => 'Історія покупок',
  AppRoute.priceHistory => 'Історія ціни',
  AppRoute.insights => 'Аналітика',
  AppRoute.settings => 'Сховище і синхронізація',
  AppRoute.backup => 'Резервна копія',
  AppRoute.business => 'Для бізнесу',
  AppRoute.home => 'Головна',
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final receipts = controller.receipts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        Text('Головна', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'Ваші покупки залишаються на пристрої.',
          style: TextStyle(color: Color(0xFF486581)),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoute.scan.path),
          icon: const Icon(Icons.document_scanner_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Сканувати чек'),
          ),
        ),
        const SizedBox(height: 16),
        if (controller.homeState == HomeState.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (controller.homeState == HomeState.empty)
          const EmptyState(
            title: 'Ще немає чеків',
            message: 'Перший чек можна додати за одну дію.',
          )
        else if (controller.homeState == HomeState.error)
          ErrorState(
            message: 'Локальне сховище тимчасово недоступне.',
            onRetry: controller.retryLocalStorage,
          )
        else if (controller.homeState == HomeState.offline)
          const InfoCard(
            icon: Icons.wifi_off,
            title: 'Офлайн режим',
            message:
                'Локальні чеки, scan simulation і review доступні без мережі.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: MetricCard(label: 'Чеків', value: '${receipts.length}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'До перевірки',
                  value: '${controller.reviewCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Останні чеки',
            action: 'Відкрити історію',
            onTap: () => Navigator.of(context).pushNamed(AppRoute.history.path),
          ),
          const SizedBox(height: 8),
          for (final receipt in receipts.take(3))
            ReceiptCard(
              receipt: receipt,
              onTap: () {
                controller.selectFixture(receipt);
                Navigator.of(context).pushNamed(AppRoute.detail.path);
              },
            ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoute.business.path),
          icon: const Icon(Icons.business_outlined),
          label: const Text('Для бізнесу — скоро'),
        ),
      ],
    );
  }
}

class ScanScreen extends StatelessWidget {
  const ScanScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const InfoCard(
        icon: Icons.wifi_off,
        title: 'Офлайн-симуляція',
        message:
            'Камера, OCR і мережа не підключені. Оберіть синтетичний приклад.',
      ),
      const SizedBox(height: 20),
      Text('Фото чека', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      _ImageIntakeStatus(controller: controller),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed:
            controller.imageIntakeState == ReceiptImageIntakeState.selecting
            ? null
            : () async {
                await controller.selectReceiptImage();
                if (context.mounted &&
                    controller.imageIntakeState ==
                        ReceiptImageIntakeState.ready) {
                  Navigator.of(context).pushNamed(AppRoute.preview.path);
                }
              },
        icon: const Icon(Icons.photo_library_outlined),
        label: Text(
          controller.imageIntakeState == ReceiptImageIntakeState.selecting
              ? 'Вибираємо фото…'
              : 'Вибрати фото чека',
        ),
      ),
      const SizedBox(height: 20),
      Text('Оберіть приклад', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      for (final fixture in controller.fixturePort.scenarios)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Semantics(
            button: true,
            label: '${fixture.id}: ${fixture.merchant}',
            child: Card(
              child: ListTile(
                title: Text('${fixture.id} · ${fixture.merchant}'),
                subtitle: Text(
                  '${fixture.items.length} позицій · ${fixture.total.formatted}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  controller.selectFixture(fixture);
                  Navigator.of(context).pushNamed(AppRoute.preview.path);
                },
              ),
            ),
          ),
        ),
      OutlinedButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Скасувати'),
      ),
    ],
  );
}

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final draft = controller.imageDraft;
    if (controller.imageIntakeState == ReceiptImageIntakeState.selecting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.imageIntakeState == ReceiptImageIntakeState.error) {
      return Center(
        child: ErrorState(
          message: 'Не вдалося локально імпортувати фото.',
          onRetry: controller.imageFailure?.retryable == true
              ? controller.retryReceiptImage
              : null,
        ),
      );
    }
    if (controller.imageIntakeState == ReceiptImageIntakeState.ready &&
        draft != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB8C7D9)),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 80,
                color: Color(0xFF486581),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const InfoCard(
            icon: Icons.photo_library_outlined,
            title: 'Фото чека збережено локально',
            message: 'OCR ще не запущено. Фото не додано до бази чеків.',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${draft.width} × ${draft.height} px'),
                  Text('${draft.byteSize} bytes · ${draft.mimeType}'),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoute.scan.path),
            child: const Text('Обрати інше фото'),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB8C7D9)),
          ),
          child: const Center(
            child: Icon(Icons.receipt_long, size: 80, color: Color(0xFF486581)),
          ),
        ),
        const SizedBox(height: 16),
        const InfoCard(
          icon: Icons.check_circle_outline,
          title: 'Область виглядає добре',
          message:
              'Це synthetic preview. Реальне фото буде підключено пізніше.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            controller.beginProcessing();
            Navigator.of(context).pushNamed(AppRoute.processing.path);
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Обробити приклад'),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoute.scan.path),
          child: const Text('Обрати інший приклад'),
        ),
      ],
    );
  }
}

class _ImageIntakeStatus extends StatelessWidget {
  const _ImageIntakeStatus({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) => switch (controller.imageIntakeState) {
    ReceiptImageIntakeState.selecting => const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: LinearProgressIndicator(),
    ),
    ReceiptImageIntakeState.ready => const InfoCard(
      icon: Icons.check_circle_outline,
      title: 'Фото готове до перегляду',
      message: 'Збережено локально; OCR ще не запускався.',
    ),
    ReceiptImageIntakeState.cancelled => const Text('Вибір фото скасовано.'),
    ReceiptImageIntakeState.error => ErrorState(
      message: 'Не вдалося локально імпортувати фото.',
      onRetry: controller.imageFailure?.retryable == true
          ? controller.retryReceiptImage
          : null,
    ),
    ReceiptImageIntakeState.idle => const Text(
      'Виберіть одну фотографію чека з бібліотеки пристрою.',
    ),
  };
}

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.processingState;
    final failed = state == ProcessingState.failed;
    final complete = state == ProcessingState.localComplete;
    final blockingState = _blockingDemoState(
      controller.processingDemoState,
      emptyTitle: 'Немає draft для обробки',
      emptyMessage: 'Оберіть synthetic capture, щоб почати.',
      errorMessage:
          'Локальна обробка не завершилася. Дані не видані як успішні.',
      onRetry: () => controller.setProcessingDemoState(DemoState.normal),
    );
    if (blockingState != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          blockingState,
          TextButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoute.home.path, (route) => false),
            child: const Text('Скасувати і на головну'),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.processingDemoState == DemoState.offline)
          const InfoCard(
            icon: Icons.wifi_off,
            title: 'Офлайн обробка',
            message: 'Локальний processing доступний без мережі.',
          )
        else if (failed)
          ErrorState(
            message:
                'Локальна обробка не завершилася. Дані не видані як успішні.',
            onRetry: controller.beginProcessing,
          )
        else ...[
          Center(
            child: complete
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16825D),
                    size: 64,
                  )
                : const CircularProgressIndicator(),
          ),
          const SizedBox(height: 18),
          Text(
            complete ? 'Готово до перевірки' : 'Обробляємо локально',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ProcessingStep(
            label: 'Підготовка',
            active: state.index >= ProcessingState.queued.index,
          ),
          _ProcessingStep(
            label: 'Розпізнавання (демо)',
            active: state.index >= ProcessingState.recognizing.index,
          ),
          _ProcessingStep(
            label: 'Розбір полів',
            active: state.index >= ProcessingState.parsing.index,
          ),
        ],
        const SizedBox(height: 24),
        if (!failed)
          FilledButton(
            onPressed: complete
                ? () => Navigator.of(context).pushNamed(AppRoute.result.path)
                : () => controller.advanceProcessing(),
            child: Text(
              complete
                  ? 'Переглянути результат'
                  : state == ProcessingState.queued
                  ? 'Почати демо'
                  : 'Наступний етап',
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoute.home.path, (route) => false),
          child: const Text('Скасувати і на головну'),
        ),
      ],
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final receipt = controller.selectedFixture;
    final blockingState = _blockingDemoState(
      controller.resultState,
      emptyTitle: 'Результат порожній',
      emptyMessage: 'Немає розпізнаних полів у цій demo state.',
      errorMessage: 'Результат недоступний через локальну помилку читання.',
      onRetry: () => controller.setResultState(DemoState.normal),
    );
    if (blockingState != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [blockingState],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.resultState == DemoState.offline || receipt.offline)
          const OfflineBanner(),
        ReceiptSummary(receipt: receipt),
        if (receipt.needsReview) ...[
          const SizedBox(height: 14),
          WarningCard(receipt: receipt),
        ],
        const SizedBox(height: 14),
        for (final item in receipt.items) ItemEvidenceCard(item: item),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            controller.save();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoute.home.path, (route) => false);
          },
          icon: const Icon(Icons.save_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Зберегти локально'),
          ),
        ),
        if (receipt.unknownMerchant)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoute.merchant.path),
            child: const Text('Розібрати продавця'),
          ),
        if (receipt.needsReview)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoute.review.path),
            child: const Text('Відкрити чергу перевірки'),
          ),
      ],
    );
  }
}

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final issues = controller.receipts
        .where((receipt) => receipt.needsReview)
        .toList();
    final blockingState = _blockingDemoState(
      controller.reviewState,
      emptyTitle: 'Черга порожня',
      emptyMessage: 'Чисті чеки не потрапляють сюди.',
      errorMessage: 'Черга перевірки недоступна через локальну помилку.',
      onRetry: controller.isPersistent
          ? controller.retryLocalStorage
          : () => controller.setReviewState(DemoState.normal),
    );
    if (blockingState != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [blockingState],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.reviewState == DemoState.offline) const OfflineBanner(),
        SectionTitle(
          title: 'Потрібна увага',
          action: '${issues.length} чеків',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        if (issues.isEmpty)
          const EmptyState(
            title: 'Черга порожня',
            message: 'Чисті чеки не потрапляють сюди.',
          ),
        for (final receipt in issues)
          ReceiptCard(
            receipt: receipt,
            onTap: () {
              controller.selectFixture(receipt);
              if (receipt.unknownMerchant) {
                Navigator.of(context).pushNamed(AppRoute.merchant.path);
              } else {
                Navigator.of(context).pushNamed(AppRoute.correction.path);
              }
            },
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Фільтр і сортування (демо)'),
        ),
      ],
    );
  }
}

class CorrectionScreen extends StatefulWidget {
  const CorrectionScreen({required this.controller, super.key});
  final AppController controller;

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  late final TextEditingController textController = TextEditingController(
    text: widget.controller.selectedFixture.items.first.parsed.text,
  );

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.controller.selectedFixture.items.first;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const InfoCard(
          icon: Icons.fact_check_outlined,
          title: 'Збережіть provenance',
          message:
              'Raw evidence не змінюється. Виправлення буде окремою подією.',
        ),
        const SizedBox(height: 18),
        EvidenceRow(label: 'Raw evidence', value: item.raw.text),
        EvidenceRow(label: 'Parsed candidate', value: item.parsed.text),
        EvidenceRow(
          label: 'Normalized entity',
          value: item.normalized?.name ?? 'Не визначено',
        ),
        if (item.candidates.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Кандидати', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final candidate in item.candidates)
                ActionChip(
                  label: Text(candidate),
                  onPressed: () => textController.text = candidate,
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Correction',
            helperText: 'Локальна демо-правка',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Застосувати correction'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Відкласти'),
        ),
      ],
    );
  }
}

class MerchantScreen extends StatelessWidget {
  const MerchantScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const InfoCard(
        icon: Icons.storefront_outlined,
        title: 'Невідомий продавець — це нормально',
        message: 'Ми не маємо каталогу або мережевого пошуку в MVP.',
      ),
      const SizedBox(height: 18),
      EvidenceRow(
        label: 'Raw merchant name',
        value: controller.selectedFixture.merchant,
      ),
      if (controller.selectedFixture.rawMerchantAddress case final address?)
        EvidenceRow(label: 'Raw merchant address', value: address),
      EvidenceRow(label: 'Normalized merchant', value: 'Не визначено'),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Залишити як невідомого'),
      ),
      OutlinedButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Відкласти'),
      ),
    ],
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final receipt = controller.selectedFixture;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ReceiptSummary(receipt: receipt),
        const SizedBox(height: 14),
        SectionTitle(
          title: 'Evidence і поля',
          action: 'Структуровано',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        for (final item in receipt.items) ItemEvidenceCard(item: item),
        const SizedBox(height: 14),
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoute.priceHistory.path),
          child: const Text('Історія ціни товару'),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoute.correction.path),
          child: const Text('Виправити рядок'),
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final blockingState = _blockingDemoState(
      controller.historyState,
      emptyTitle: 'Історія порожня',
      emptyMessage: 'Збережені чеки з’являться тут.',
      errorMessage: 'Історія недоступна через локальну помилку запиту.',
      onRetry: controller.isPersistent
          ? controller.retryLocalStorage
          : () => controller.setHistoryState(DemoState.normal),
    );
    if (blockingState != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [blockingState],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.historyState == DemoState.offline) const OfflineBanner(),
        SectionTitle(title: 'Усі покупки', action: 'Фільтри', onTap: () {}),
        const SizedBox(height: 12),
        if (controller.receipts.isEmpty)
          const EmptyState(
            title: 'Історія порожня',
            message: 'Збережені чеки з’являться тут.',
          ),
        for (final receipt in controller.receipts)
          ReceiptCard(
            receipt: receipt,
            onTap: () {
              controller.selectFixture(receipt);
              Navigator.of(context).pushNamed(AppRoute.detail.path);
            },
          ),
        const SizedBox(height: 14),
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoute.insights.path),
          child: const Text('Відкрити аналітику'),
        ),
      ],
    );
  }
}

class PriceHistoryScreen extends StatelessWidget {
  const PriceHistoryScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        controller.selectedFixture.items.first.normalized?.name ??
            'Невизначений товар',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      const Text(
        'Локальна історія synthetic fixture',
        style: TextStyle(color: Color(0xFF486581)),
      ),
      const SizedBox(height: 18),
      for (final entry in [
        '20 серпня · 42,90 UAH',
        '17 серпня · 39,90 UAH',
        '12 серпня · 41,50 UAH',
      ])
        Card(
          child: ListTile(
            leading: const Icon(Icons.show_chart),
            title: Text(entry),
            subtitle: const Text('Підтверджене локальне спостереження'),
          ),
        ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoute.correction.path),
        child: const Text('Уточнити товар'),
      ),
    ],
  );
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const InfoCard(
        icon: Icons.insights_outlined,
        title: 'Локальні підсумки',
        message:
            'Це описова аналітика з fixture-даних, не фінансова рекомендація.',
      ),
      const SizedBox(height: 16),
      MetricCard(
        label: 'Сума у вибірці',
        value:
            '${controller.receipts.fold<int>(0, (sum, item) => sum + item.total.minor) ~/ 100},00 UAH',
      ),
      const SizedBox(height: 10),
      const Card(
        child: ListTile(
          leading: Icon(Icons.category_outlined),
          title: Text('Найчастіша категорія'),
          subtitle: Text('Продукти · достатньо даних для демо'),
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.trending_up),
          title: Text('Зміна ціни'),
          subtitle: Text('Дивіться деталі товару для джерела'),
        ),
      ),
      const SizedBox(height: 14),
      OutlinedButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoute.history.path),
        child: const Text('Переглянути покупки'),
      ),
    ],
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Режим зберігання', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      RadioGroup<StorageMode>(
        groupValue: controller.storageMode,
        onChanged: (mode) {
          if (mode != null) controller.setStorageMode(mode);
        },
        child: RadioListTile<StorageMode>(
          value: StorageMode.localOnly,
          title: const Text('LOCAL_ONLY'),
          subtitle: const Text('Працює без облікового запису і мережі.'),
        ),
      ),
      RadioGroup<StorageMode>(
        groupValue: controller.storageMode,
        onChanged: (mode) {
          if (mode != null) controller.setStorageMode(mode);
        },
        child: RadioListTile<StorageMode>(
          value: StorageMode.syncTeaser,
          title: const Text('Sync — планується'),
          subtitle: const Text(
            'Інформаційний teaser, без мережевого side effect.',
          ),
        ),
      ),
      const SizedBox(height: 14),
      const InfoCard(
        icon: Icons.privacy_tip_outlined,
        title: 'Приватність',
        message: 'Дані цього демо synthetic. Реальні фото, PII та QR не використовуються.',
      ),
      const SizedBox(height: 12),
      FilledButton.tonal(
        onPressed: () => Navigator.of(context).pushNamed(AppRoute.backup.path),
        child: const Text('Backup / Restore — пояснення'),
      ),
      OutlinedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoute.business.path),
        child: const Text('Для бізнесу — скоро'),
      ),
    ],
  );
}

class BackupScreen extends StatelessWidget {
  const BackupScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const InfoCard(
        icon: Icons.cloud_off,
        title: 'Резервна копія ще недоступна',
        message: 'У MVP немає провайдера, передачі даних або fake progress.',
      ),
      const SizedBox(height: 18),
      const Card(
        child: ListTile(
          title: Text('Локальний export'),
          subtitle: Text(
            'Концепт: файл залишається під контролем користувача.',
          ),
        ),
      ),
      const Card(
        child: ListTile(
          title: Text('BYO storage / Drive'),
          subtitle: Text('Концепт: opt-in інтеграція в майбутній версії.'),
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Зрозуміло'),
      ),
    ],
  );
}

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const InfoCard(
        icon: Icons.business_center_outlined,
        title: 'Для бізнесу — скоро',
        message:
            'B2B workflow, команди та облікові записи не входять до UX MVP.',
      ),
      const SizedBox(height: 18),
      const Card(
        child: ListTile(
          title: Text('Що досліджуємо'),
          subtitle: Text(
            'Партнерські звіти, категоризація та контроль доступу — без активної форми lead.',
          ),
          isThreeLine: true,
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Повернутися'),
      ),
    ],
  );
}

Widget? _blockingDemoState(
  DemoState state, {
  required String emptyTitle,
  required String emptyMessage,
  required String errorMessage,
  required VoidCallback onRetry,
}) => switch (state) {
  DemoState.loading => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: CircularProgressIndicator(),
    ),
  ),
  DemoState.empty => EmptyState(title: emptyTitle, message: emptyMessage),
  DemoState.error => ErrorState(message: errorMessage, onRetry: onRetry),
  DemoState.normal || DemoState.offline => null,
};

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: 'Офлайн. Локальні функції доступні.',
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 20, color: Color(0xFF1264D9)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Офлайн · локальні функції доступні',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    ),
  );
}

class ReceiptCard extends StatelessWidget {
  const ReceiptCard({required this.receipt, required this.onTap, super.key});
  final ReceiptFixture receipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      title: Text(receipt.merchant),
      subtitle: Text(
        '${receipt.date} · ${receipt.id}${receipt.needsReview ? ' · Потрібна увага' : ''}',
      ),
      trailing: Text(
        receipt.total.formatted,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class ReceiptSummary extends StatelessWidget {
  const ReceiptSummary({required this.receipt, super.key});
  final ReceiptFixture receipt;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(receipt.merchant, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(receipt.date),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Разом'),
              Text(
                receipt.total.formatted,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class WarningCard extends StatelessWidget {
  const WarningCard({required this.receipt, super.key});
  final ReceiptFixture receipt;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFFFF5DB),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFF8A5A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              receipt.totalMismatch
                  ? 'Сума рядків не збігається з total.'
                  : receipt.unknownMerchant
                  ? 'Продавця не знайдено в локальному каталозі.'
                  : 'Є рядок із низькою впевненістю.',
            ),
          ),
        ],
      ),
    ),
  );
}

class ItemEvidenceCard extends StatelessWidget {
  const ItemEvidenceCard({required this.item, super.key});
  final LineItem item;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.normalized?.name ?? item.parsed.text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          EvidenceRow(label: 'Raw evidence', value: item.raw.text),
          EvidenceRow(
            label: 'Parsed candidate',
            value: '${item.parsed.text} · ${item.parsed.confidence}%',
          ),
          EvidenceRow(
            label: 'Normalized entity',
            value: item.normalized?.name ?? 'Не визначено',
          ),
          EvidenceRow(label: 'Price', value: item.price.formatted),
        ],
      ),
    ),
  );
}

class EvidenceRow extends StatelessWidget {
  const EvidenceRow({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Semantics(
      label: '$label: $value',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF627D98), fontSize: 12),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
    super.key,
  });
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      Flexible(
        child: TextButton(
          onPressed: onTap,
          child: Text(action, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
  );
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFF0F4F8),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1264D9)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, super.key});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 42, color: Color(0xFF627D98)),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, this.onRetry, super.key});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFFFEFEC),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFB42318)),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторити'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      active ? Icons.check_circle : Icons.radio_button_unchecked,
      color: active ? const Color(0xFF16825D) : const Color(0xFF9FB3C8),
    ),
    title: Text(label),
  );
}
