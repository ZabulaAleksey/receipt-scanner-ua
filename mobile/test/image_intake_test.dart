import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:receipt_scanner_mobile/src/domain.dart';
import 'package:receipt_scanner_mobile/src/image_intake.dart';

void main() {
  test('valid PNG produces safe metadata without a user path', () {
    final bytes = Uint8List.fromList(
      image.encodePng(image.Image(width: 2, height: 3)),
    );

    final result = ReceiptImageValidator.validate(bytes);

    expect(result, isNot(isA<ReceiptImageFailed>()));
  });

  test('unrecognised or truncated input fails closed', () {
    expect(
      ReceiptImageValidator.validate(Uint8List.fromList(<int>[1, 2, 3])),
      isA<ReceiptImageFailed>().having(
        (failure) => failure.failure.kind,
        'kind',
        ReceiptImageFailureKind.unsupportedImage,
      ),
    );
    expect(
      ReceiptImageValidator.validate(
        Uint8List.fromList(<int>[0xff, 0xd8, 0xff]),
      ),
      isA<ReceiptImageFailed>().having(
        (failure) => failure.failure.kind,
        'kind',
        ReceiptImageFailureKind.invalidImage,
      ),
    );
  });

  test('byte limit is rejected before decoder work', () {
    final bytes = Uint8List(ReceiptImageLimits.maxBytes + 1);

    final result = ReceiptImageValidator.validate(bytes);

    expect(
      result,
      isA<ReceiptImageFailed>().having(
        (failure) => failure.failure.kind,
        'kind',
        ReceiptImageFailureKind.byteLimitExceeded,
      ),
    );
  });

  test('oversized dimensions are rejected before full decode', () {
    final bytes = Uint8List.fromList(
      image.encodePng(image.Image(width: 6001, height: 1)),
    );

    final result = ReceiptImageValidator.validate(bytes);

    expect(
      result,
      isA<ReceiptImageFailed>().having(
        (failure) => failure.failure.kind,
        'kind',
        ReceiptImageFailureKind.dimensionsExceeded,
      ),
    );
  });

  test(
    'stale app-owned drafts are reconciled without touching user paths',
    () async {
      final root = await Directory.systemTemp.createTemp('receipt-r05-image-');
      final directory = Directory(
        '${root.path}${Platform.pathSeparator}receipt_images',
      );
      await directory.create();
      final stale = File('${directory.path}${Platform.pathSeparator}old.jpg');
      await stale.writeAsBytes(<int>[1]);
      final adapter = ImagePickerReceiptImageIntakeAdapter(
        appSupportDirectory: () async => root,
      );

      await adapter.clearStaleDrafts();

      expect(await stale.exists(), isFalse);
      await root.delete(recursive: true);
    },
  );

  test(
    'manifest-owned draft is restored and stale sibling is removed',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'receipt-r05-manifest-',
      );
      final directory = Directory(
        '${root.path}${Platform.pathSeparator}receipt_images',
      );
      await directory.create();
      final bytes = Uint8List.fromList(
        image.encodePng(image.Image(width: 2, height: 3)),
      );
      final active = File(
        '${directory.path}${Platform.pathSeparator}stored.png',
      );
      await active.writeAsBytes(bytes);
      final stale = File(
        '${directory.path}${Platform.pathSeparator}stale.partial',
      );
      await stale.writeAsBytes(<int>[1]);
      await File('${directory.path}${Platform.pathSeparator}active_draft.json')
          .writeAsString(
            jsonEncode(<String, Object>{
              'id': 'stored',
              'storageRef': 'receipt_images/stored.png',
              'mimeType': 'image/png',
              'byteSize': bytes.length,
              'width': 2,
              'height': 3,
              'source': ReceiptImageSource.gallery.index,
            }),
          );
      final adapter = ImagePickerReceiptImageIntakeAdapter(
        appSupportDirectory: () async => root,
      );

      await adapter.clearStaleDrafts();
      final restored = await adapter.restoreStoredDraft();

      expect(restored, isA<ReceiptImageReady>());
      expect((restored as ReceiptImageReady).draft.id, 'stored');
      expect(await stale.exists(), isFalse);
      await root.delete(recursive: true);
    },
  );
}
