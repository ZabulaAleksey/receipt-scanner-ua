import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:receipt_scanner_mobile/src/domain.dart';
import 'package:receipt_scanner_mobile/src/persistence.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'SQLite repository preserves aggregate after close and reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp('receipt-r04-');
      final path = '${directory.path}${Platform.pathSeparator}receipts.db';
      final first = await SqliteReceiptRepository.open(path);
      const aggregate = ReceiptAggregate(
        id: 'R04-1',
        merchant: 'Test merchant',
        date: '2026-08-21',
        total: Money(12345, currency: 'UAH'),
        items: <LineItem>[],
        rawMerchantAddress: 'Address',
      );
      await first.save(aggregate);
      await first.close();

      final reopened = await SqliteReceiptRepository.open(path);
      final loaded = await reopened.load();
      expect(loaded.single.id, aggregate.id);
      expect(loaded.single.total.minor, 12345);
      expect(loaded.single.rawMerchantAddress, 'Address');
      await reopened.close();
      await directory.delete(recursive: true);
    },
  );

  test('duplicate stable id is a typed safe error', () async {
    final directory = await Directory.systemTemp.createTemp('receipt-r04-');
    final path = '${directory.path}${Platform.pathSeparator}receipts.db';
    final repository = await SqliteReceiptRepository.open(path);
    const aggregate = ReceiptAggregate(
      id: 'R04-duplicate',
      merchant: 'Test merchant',
      date: '2026-08-21',
      total: Money(1),
      items: <LineItem>[],
    );
    await repository.save(aggregate);
    await expectLater(
      repository.save(aggregate),
      throwsA(isA<ReceiptStorageException>()),
    );
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('corrupted local payload fails closed without fixture fallback', () async {
    final directory = await Directory.systemTemp.createTemp('receipt-r04-');
    final path = '${directory.path}${Platform.pathSeparator}receipts.db';
    final repository = await SqliteReceiptRepository.open(path);
    await repository.close();
    final database = await openDatabase(path);
    await database.insert(SqliteReceiptRepository.table, {
      'id': 'R04-corrupt',
      'schema_version': SqliteReceiptRepository.schemaVersion,
      'merchant': 'Tampered',
      'date': '2026-08-21',
      'total_minor': 1,
      'currency': 'UAH',
      'payload': '{invalid json',
    });
    await database.close();

    final reopened = await SqliteReceiptRepository.open(path);
    await expectLater(reopened.load(), throwsA(isA<ReceiptPayloadException>()));
    await reopened.close();
    await directory.delete(recursive: true);
  });

  test('payload that conflicts with indexed fields fails closed', () async {
    final directory = await Directory.systemTemp.createTemp('receipt-r04-');
    final path = '${directory.path}${Platform.pathSeparator}receipts.db';
    final repository = await SqliteReceiptRepository.open(path);
    const aggregate = ReceiptAggregate(
      id: 'R04-indexed',
      merchant: 'Original merchant',
      date: '2026-08-21',
      total: Money(10),
      items: <LineItem>[],
    );
    await repository.save(aggregate);
    await repository.close();
    final database = await openDatabase(path);
    await database.update(
      SqliteReceiptRepository.table,
      {'merchant': 'Tampered merchant'},
      where: 'id = ?',
      whereArgs: [aggregate.id],
    );
    await database.close();

    final reopened = await SqliteReceiptRepository.open(path);
    await expectLater(reopened.load(), throwsA(isA<ReceiptPayloadException>()));
    await reopened.close();
    await directory.delete(recursive: true);
  });

  test('oversized stored payload fails before JSON decoding', () async {
    final directory = await Directory.systemTemp.createTemp('receipt-r04-');
    final path = '${directory.path}${Platform.pathSeparator}receipts.db';
    final repository = await SqliteReceiptRepository.open(path);
    await repository.close();
    final database = await openDatabase(path);
    await database.insert(SqliteReceiptRepository.table, {
      'id': 'R04-large',
      'schema_version': SqliteReceiptRepository.schemaVersion,
      'merchant': 'Large',
      'date': '2026-08-21',
      'total_minor': 1,
      'currency': 'UAH',
      'payload': 'x' * (SqliteReceiptRepository.maxPayloadBytes + 1),
    });
    await database.close();

    final reopened = await SqliteReceiptRepository.open(path);
    await expectLater(reopened.load(), throwsA(isA<ReceiptPayloadException>()));
    await reopened.close();
    await directory.delete(recursive: true);
  });
}
