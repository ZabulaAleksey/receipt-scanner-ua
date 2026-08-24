import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'domain.dart';

class ReceiptStorageException implements Exception {
  const ReceiptStorageException(this.code);
  final String code;
  @override
  String toString() => 'ReceiptStorageException($code)';
}

class ReceiptPayloadException extends ReceiptStorageException {
  const ReceiptPayloadException() : super('invalid_local_payload');
}

ReceiptAggregate aggregateFromFixture(ReceiptFixture f) => ReceiptAggregate(
  id: f.id,
  merchant: f.merchant,
  date: f.date,
  total: f.total,
  items: f.items,
  unknownMerchant: f.unknownMerchant,
  duplicate: f.duplicate,
  offline: f.offline,
  totalMismatch: f.totalMismatch,
  rawMerchantAddress: f.rawMerchantAddress,
);

ReceiptFixture fixtureFromAggregate(ReceiptAggregate value) => ReceiptFixture(
  id: value.id,
  merchant: value.merchant,
  date: value.date,
  total: value.total,
  items: value.items,
  unknownMerchant: value.unknownMerchant,
  duplicate: value.duplicate,
  offline: value.offline,
  totalMismatch: value.totalMismatch,
  rawMerchantAddress: value.rawMerchantAddress,
);

class SqliteReceiptRepository implements ReceiptRepository {
  SqliteReceiptRepository(this._database);
  final Database _database;

  static const schemaVersion = 1;
  static const table = 'receipts';
  static const maxRows = 1000;
  static const maxPayloadBytes = 1024 * 1024;
  static const maxTotalPayloadBytes = 8 * 1024 * 1024;
  static const _protectionChannel = MethodChannel(
    'ua.receipt-scanner/local-storage',
  );

  static Future<SqliteReceiptRepository> open(String path) async {
    Database? database;
    try {
      database = await openDatabase(
        path,
        version: schemaVersion,
        onCreate: (db, _) async {
          await db.execute('''CREATE TABLE receipts (
            id TEXT PRIMARY KEY,
            schema_version INTEGER NOT NULL,
            merchant TEXT NOT NULL,
            date TEXT NOT NULL,
            total_minor INTEGER NOT NULL,
            currency TEXT NOT NULL,
            payload TEXT NOT NULL
          )''');
        },
      );
      await _excludeFromIosBackup(path);
      return SqliteReceiptRepository(database);
    } catch (_) {
      if (database != null) {
        try {
          await database.close();
        } catch (_) {}
      }
      throw const ReceiptStorageException('local_open_failed');
    }
  }

  static Future<SqliteReceiptRepository> openInAppStorage() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final directory = Directory(
      path.join(supportDirectory.path, 'receipt_scanner_storage'),
    );
    await directory.create(recursive: true);
    await _excludeFromIosBackup(directory.path);
    return open(path.join(directory.path, 'receipt_scanner_v1.db'));
  }

  static Future<void> _excludeFromIosBackup(String databasePath) async {
    if (!Platform.isIOS) return;
    try {
      await _protectionChannel.invokeMethod<void>('excludeFromBackup', {
        'path': databasePath,
      });
    } on PlatformException {
      throw const ReceiptStorageException('local_protection_failed');
    }
  }

  @override
  Future<List<ReceiptAggregate>> load() async {
    try {
      final metadata = await _database.rawQuery(
        'SELECT id, schema_version, merchant, date, total_minor, currency, '
        'length(payload) AS payload_bytes FROM $table '
        'ORDER BY rowid DESC LIMIT ?',
        [maxRows + 1],
      );
      if (metadata.length > maxRows) throw const ReceiptPayloadException();

      var totalBytes = 0;
      final rows = <Map<String, Object?>>[];
      for (final entry in metadata) {
        final id = entry['id'];
        final bytes = entry['payload_bytes'];
        if (id is! String || bytes is! int || bytes < 0 || bytes > maxPayloadBytes) {
          throw const ReceiptPayloadException();
        }
        totalBytes += bytes;
        if (totalBytes > maxTotalPayloadBytes) {
          throw const ReceiptPayloadException();
        }
        final payloadRow = await _database.query(
          table,
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (payloadRow.length != 1) throw const ReceiptPayloadException();
        rows.add(payloadRow.single);
      }
      return rows.map(_decode).toList(growable: false);
    } on ReceiptStorageException {
      rethrow;
    } catch (_) {
      throw const ReceiptStorageException('local_read_failed');
    }
  }

  @override
  Future<void> save(ReceiptAggregate receipt) async {
    final payload = jsonEncode(_encode(receipt));
    if (utf8.encode(payload).length > maxPayloadBytes) {
      throw const ReceiptPayloadException();
    }
    try {
      await _database.insert(table, {
        'id': receipt.id,
        'schema_version': schemaVersion,
        'merchant': receipt.merchant,
        'date': receipt.date,
        'total_minor': receipt.total.minor,
        'currency': receipt.total.currency,
        'payload': payload,
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const ReceiptStorageException('duplicate_id');
      }
      throw const ReceiptStorageException('local_write_failed');
    } catch (_) {
      throw const ReceiptStorageException('local_write_failed');
    }
  }

  @override
  Future<void> close() => _database.close();

  ReceiptAggregate _decode(Map<String, Object?> row) {
    if (row['schema_version'] != schemaVersion || row['payload'] is! String) {
      throw const ReceiptPayloadException();
    }
    try {
      final payload = row['payload']! as String;
      if (utf8.encode(payload).length > maxPayloadBytes) {
        throw const ReceiptPayloadException();
      }
      final value = jsonDecode(payload);
      if (value is! Map<String, dynamic>) throw const ReceiptPayloadException();
      final aggregate = _aggregate(value);
      if (row['id'] != aggregate.id ||
          row['merchant'] != aggregate.merchant ||
          row['date'] != aggregate.date ||
          row['total_minor'] != aggregate.total.minor ||
          row['currency'] != aggregate.total.currency) {
        throw const ReceiptPayloadException();
      }
      return aggregate;
    } catch (e) {
      if (e is ReceiptPayloadException) rethrow;
      throw const ReceiptPayloadException();
    }
  }
}

Map<String, dynamic> _encode(ReceiptAggregate r) => {
  'schema_version': 1,
  'id': r.id,
  'merchant': r.merchant,
  'date': r.date,
  'total_minor': r.total.minor,
  'currency': r.total.currency,
  'unknown_merchant': r.unknownMerchant,
  'duplicate': r.duplicate,
  'offline': r.offline,
  'total_mismatch': r.totalMismatch,
  'raw_merchant_address': r.rawMerchantAddress,
  'items': r.items
      .map(
        (i) => {
          'raw_text': i.raw.text,
          'raw_source': i.raw.source,
          'parsed_text': i.parsed.text,
          'confidence': i.parsed.confidence,
          'normalized_name': i.normalized?.name,
          'normalized_category': i.normalized?.category,
          'correction_value': i.correction?.value,
          'correction_reason': i.correction?.reason,
          'candidates': i.candidates,
          'price_minor': i.price.minor,
          'price_currency': i.price.currency,
        },
      )
      .toList(),
};

ReceiptAggregate _aggregate(Map<String, dynamic> v) {
  String text(String key) {
    final value = v[key];
    if (value is! String || value.isEmpty || value.length > 10000) {
      throw const ReceiptPayloadException();
    }
    return value;
  }

  final id = text('id');
  if (v['schema_version'] != SqliteReceiptRepository.schemaVersion) {
    throw const ReceiptPayloadException();
  }
  final rawItems = v['items'];
  if (rawItems is! List || rawItems.length > 1000)
    throw const ReceiptPayloadException();
  final totalMinor = v['total_minor'];
  if (totalMinor is! int) throw const ReceiptPayloadException();
  final items = rawItems
      .map((raw) {
        if (raw is! Map<String, dynamic>) throw const ReceiptPayloadException();
        final confidence = raw['confidence'];
        final priceMinor = raw['price_minor'];
        if (confidence is! int ||
            confidence < 0 ||
            confidence > 100 ||
            priceMinor is! int) {
          throw const ReceiptPayloadException();
        }
        return LineItem(
          raw: RawEvidence(
            text: textValue(raw, 'raw_text'),
            source: textValue(raw, 'raw_source'),
          ),
          parsed: ParsedCandidate(
            text: textValue(raw, 'parsed_text'),
            confidence: confidence,
          ),
          normalized: raw['normalized_name'] == null
              ? null
              : NormalizedProduct(
                  name: textValue(raw, 'normalized_name'),
                  category: textValue(raw, 'normalized_category'),
                ),
          correction: raw['correction_value'] == null
              ? null
              : Correction(
                  value: textValue(raw, 'correction_value'),
                  reason: textValue(raw, 'correction_reason'),
                ),
          candidates: _candidates(raw['candidates']),
          price: Money(priceMinor, currency: textValue(raw, 'price_currency')),
        );
      })
      .toList(growable: false);
  return ReceiptAggregate(
    id: id,
    merchant: text('merchant'),
    date: text('date'),
    total: Money(totalMinor, currency: text('currency')),
    items: items,
    unknownMerchant: _boolean(v, 'unknown_merchant'),
    duplicate: _boolean(v, 'duplicate'),
    offline: _boolean(v, 'offline'),
    totalMismatch: _boolean(v, 'total_mismatch'),
    rawMerchantAddress: _optionalText(v['raw_merchant_address']),
  );
}

bool _boolean(Map<String, dynamic> value, String key) {
  final candidate = value[key];
  if (candidate is! bool) throw const ReceiptPayloadException();
  return candidate;
}

List<String> _candidates(Object? value) {
  if (value is! List || value.length > 100)
    throw const ReceiptPayloadException();
  return value
      .map((candidate) {
        if (candidate is! String || candidate.length > 10000) {
          throw const ReceiptPayloadException();
        }
        return candidate;
      })
      .toList(growable: false);
}

String? _optionalText(Object? value) {
  if (value == null) return null;
  if (value is! String || value.length > 10000) {
    throw const ReceiptPayloadException();
  }
  return value;
}

String textValue(Map<String, dynamic> v, String key) {
  final value = v[key];
  if (value is! String || value.length > 10000)
    throw const ReceiptPayloadException();
  return value;
}
