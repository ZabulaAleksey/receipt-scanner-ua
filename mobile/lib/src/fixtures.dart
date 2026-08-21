import 'domain.dart';

class FixtureRepository {
  static final List<ReceiptFixture> all = [
    ReceiptFixture(
      id: 'FX-01-CLEAN',
      merchant: 'Свіжий кошик',
      date: '20 серпня 2026',
      total: const Money(34550),
      items: const [
        LineItem(
          raw: RawEvidence(text: 'Молоко 2.5%', source: 'synthetic crop A'),
          parsed: ParsedCandidate(text: 'Молоко 2.5%', confidence: 96),
          normalized: NormalizedProduct(
            name: 'Молоко 2.5%',
            category: 'Продукти',
          ),
          price: Money(4290),
        ),
        LineItem(
          raw: RawEvidence(text: 'Хліб житній', source: 'synthetic crop B'),
          parsed: ParsedCandidate(text: 'Хліб житній', confidence: 94),
          normalized: NormalizedProduct(
            name: 'Хліб житній',
            category: 'Продукти',
          ),
          price: Money(2990),
        ),
        LineItem(
          raw: RawEvidence(
            text: 'Яйця курячі 10 шт',
            source: 'synthetic crop C',
          ),
          parsed: ParsedCandidate(text: 'Яйця курячі 10 шт', confidence: 95),
          normalized: NormalizedProduct(
            name: 'Яйця курячі 10 шт',
            category: 'Продукти',
          ),
          price: Money(5290),
        ),
        LineItem(
          raw: RawEvidence(text: 'Сир твердий', source: 'synthetic crop D'),
          parsed: ParsedCandidate(text: 'Сир твердий', confidence: 93),
          normalized: NormalizedProduct(
            name: 'Сир твердий',
            category: 'Продукти',
          ),
          price: Money(8990),
        ),
        LineItem(
          raw: RawEvidence(text: 'Кава мелена', source: 'synthetic crop E'),
          parsed: ParsedCandidate(text: 'Кава мелена', confidence: 92),
          normalized: NormalizedProduct(
            name: 'Кава мелена',
            category: 'Продукти',
          ),
          price: Money(12990),
        ),
      ],
    ),
    ReceiptFixture(
      id: 'FX-02-LOW-CONFIDENCE',
      merchant: 'Свіжий кошик',
      date: '19 серпня 2026',
      total: const Money(9240),
      items: const [
        LineItem(
          raw: RawEvidence(text: 'Йогурт ???', source: 'synthetic crop C'),
          parsed: ParsedCandidate(text: 'Йогурт натуральний', confidence: 54),
          normalized: NormalizedProduct(name: 'Йогурт', category: 'Продукти'),
          candidates: ['Йогурт натуральний', 'Йогурт без цукру'],
          price: Money(9240),
        ),
      ],
    ),
    ReceiptFixture(
      id: 'FX-03-UNKNOWN-MERCHANT',
      merchant: 'ФОП Крамар (невідомий)',
      date: '18 серпня 2026',
      total: const Money(63500),
      unknownMerchant: true,
      rawMerchantAddress: 'Синтетична адреса, тестовий рядок 3',
      items: const [
        LineItem(
          raw: RawEvidence(text: 'Кава мелена', source: 'synthetic crop D'),
          parsed: ParsedCandidate(text: 'Кава мелена', confidence: 89),
          price: Money(63500),
        ),
      ],
    ),
    ReceiptFixture(
      id: 'FX-09-OFFLINE',
      merchant: 'Свіжий кошик',
      date: '17 серпня 2026',
      total: const Money(12900),
      offline: true,
      items: const [
        LineItem(
          raw: RawEvidence(text: 'Яблука', source: 'synthetic offline crop'),
          parsed: ParsedCandidate(text: 'Яблука', confidence: 91),
          normalized: NormalizedProduct(name: 'Яблука', category: 'Продукти'),
          price: Money(12900),
        ),
      ],
    ),
    ReceiptFixture(
      id: 'FX-06-TOTAL-MISMATCH',
      merchant: 'Свіжий кошик',
      date: '16 серпня 2026',
      total: const Money(19900),
      totalMismatch: true,
      items: const [
        LineItem(
          raw: RawEvidence(text: 'Овочі', source: 'synthetic mismatch crop'),
          parsed: ParsedCandidate(text: 'Овочі', confidence: 82),
          normalized: NormalizedProduct(name: 'Овочі', category: 'Продукти'),
          price: Money(24900),
        ),
      ],
    ),
  ];

  static ReceiptFixture byId(String id) =>
      all.firstWhere((fixture) => fixture.id == id);

  static List<String> validate() {
    final errors = <String>[];
    final ids = <String>{};
    for (final fixture in all) {
      if (!ids.add(fixture.id)) {
        errors.add('duplicate id ${fixture.id}');
      }
      if (fixture.total.minor < 0) {
        errors.add('negative total ${fixture.id}');
      }
      if (fixture.total.currency != 'UAH') {
        errors.add('unsupported currency ${fixture.id}');
      }
      final itemTotal = fixture.items.fold<int>(
        0,
        (sum, item) => sum + item.price.minor,
      );
      if (!fixture.totalMismatch && itemTotal != fixture.total.minor) {
        errors.add('unexplained total mismatch ${fixture.id}');
      }
      for (final item in fixture.items) {
        if (item.price.minor < 0) {
          errors.add('negative item ${fixture.id}');
        }
        if (item.parsed.confidence < 0 || item.parsed.confidence > 100) {
          errors.add('invalid confidence ${fixture.id}');
        }
      }
    }
    final clean = byId('FX-01-CLEAN');
    if (clean.items.length != 5 || clean.needsReview) {
      errors.add('FX-01-CLEAN contract mismatch');
    }
    final lowConfidence = byId('FX-02-LOW-CONFIDENCE');
    if (lowConfidence.items.single.candidates.length != 2) {
      errors.add('FX-02-LOW-CONFIDENCE candidates mismatch');
    }
    final unknownMerchant = byId('FX-03-UNKNOWN-MERCHANT');
    if (unknownMerchant.rawMerchantAddress == null) {
      errors.add('FX-03-UNKNOWN-MERCHANT address missing');
    }
    return errors;
  }
}
