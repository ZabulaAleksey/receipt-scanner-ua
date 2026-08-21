enum AppRoute {
  home('/home'),
  scan('/scan'),
  preview('/preview'),
  processing('/processing'),
  result('/result'),
  review('/review'),
  correction('/correction'),
  merchant('/merchant'),
  detail('/detail'),
  history('/history'),
  priceHistory('/price-history'),
  insights('/insights'),
  settings('/settings'),
  backup('/backup'),
  business('/business');

  const AppRoute(this.path);
  final String path;

  static AppRoute fromPath(String? path) => AppRoute.values.firstWhere(
    (route) => route.path == path,
    orElse: () => AppRoute.home,
  );
}

class Money {
  const Money(this.minor, {this.currency = 'UAH'});

  final int minor;
  final String currency;

  String get formatted =>
      '${minor ~/ 100},${(minor % 100).abs().toString().padLeft(2, '0')} $currency';
}

class RawEvidence {
  const RawEvidence({required this.text, required this.source});

  final String text;
  final String source;
}

class ParsedCandidate {
  const ParsedCandidate({required this.text, required this.confidence});

  final String text;
  final int confidence;
}

class NormalizedProduct {
  const NormalizedProduct({required this.name, required this.category});

  final String name;
  final String category;
}

class Correction {
  const Correction({required this.value, required this.reason});

  final String value;
  final String reason;
}

class LineItem {
  const LineItem({
    required this.raw,
    required this.parsed,
    this.normalized,
    this.correction,
    this.candidates = const [],
    required this.price,
  });

  final RawEvidence raw;
  final ParsedCandidate parsed;
  final NormalizedProduct? normalized;
  final Correction? correction;
  final List<String> candidates;
  final Money price;

  bool get needsReview => parsed.confidence < 80 || normalized == null;
}

class ReceiptFixture {
  const ReceiptFixture({
    required this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.items,
    this.unknownMerchant = false,
    this.duplicate = false,
    this.offline = false,
    this.totalMismatch = false,
    this.rawMerchantAddress,
  });

  final String id;
  final String merchant;
  final String date;
  final Money total;
  final List<LineItem> items;
  final bool unknownMerchant;
  final bool duplicate;
  final bool offline;
  final bool totalMismatch;
  final String? rawMerchantAddress;

  bool get needsReview =>
      unknownMerchant ||
      duplicate ||
      totalMismatch ||
      items.any((item) => item.needsReview);
}

enum ProcessingState {
  idle,
  queued,
  recognizing,
  parsing,
  localComplete,
  failed,
}

enum HomeState { normal, loading, empty, error, offline }

enum DemoState { normal, loading, empty, error, offline }

enum StorageMode { localOnly, syncTeaser }

class ReceiptAggregate {
  const ReceiptAggregate({
    required this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.items,
    this.unknownMerchant = false,
    this.duplicate = false,
    this.offline = false,
    this.totalMismatch = false,
    this.rawMerchantAddress,
  });
  final String id;
  final String merchant;
  final String date;
  final Money total;
  final List<LineItem> items;
  final bool unknownMerchant;
  final bool duplicate;
  final bool offline;
  final bool totalMismatch;
  final String? rawMerchantAddress;
}

abstract interface class LegacyReceiptRepository {
  List<ReceiptFixture> get receipts;
  void save(ReceiptFixture receipt);
}

abstract interface class ReceiptRepository {
  Future<List<ReceiptAggregate>> load();
  Future<void> save(ReceiptAggregate receipt);
  Future<void> close();
}

/// Synchronous fixture/demo helper retained for the accepted UX tests.
class InMemoryReceiptStore implements LegacyReceiptRepository {
  InMemoryReceiptStore([List<ReceiptFixture>? initial])
    : _receipts = [...?initial];

  final List<ReceiptFixture> _receipts;

  @override
  List<ReceiptFixture> get receipts => List.unmodifiable(_receipts);

  @override
  void save(ReceiptFixture receipt) {
    if (!_receipts.any((item) => item.id == receipt.id)) {
      _receipts.insert(0, receipt);
    }
  }
}

class ProcessReceiptUseCase {
  ReceiptFixture process(ReceiptFixture fixture) => fixture;
}

class SaveReceiptUseCase {
  SaveReceiptUseCase(this.repository);

  final LegacyReceiptRepository repository;

  void save(ReceiptFixture fixture) {
    repository.save(fixture);
  }
}
