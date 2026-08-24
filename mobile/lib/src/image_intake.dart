import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'domain.dart';
import 'ports.dart';

class ReceiptImageLimits {
  const ReceiptImageLimits();
  static const maxBytes = 12 * 1024 * 1024;
  static const maxDimension = 6000;
  static const maxPixels = 20000000;
}

/// Production adapter: picker, decoder, and file system never leave this file.
class ImagePickerReceiptImageIntakeAdapter implements ReceiptImageIntakePort {
  ImagePickerReceiptImageIntakeAdapter({
    ImagePicker? picker,
    Future<Directory> Function()? appSupportDirectory,
    String Function()? idGenerator,
  }) : _picker = picker ?? ImagePicker(),
       _appSupportDirectory =
           appSupportDirectory ?? getApplicationSupportDirectory,
       _idGenerator = idGenerator ?? _defaultId;

  static const _storageChannel = MethodChannel(
    'ua.receipt-scanner/local-storage',
  );
  static const _directoryName = 'receipt_images';
  static const _manifestName = 'active_draft.json';
  final ImagePicker _picker;
  final Future<Directory> Function() _appSupportDirectory;
  final String Function() _idGenerator;

  @override
  Future<ReceiptImageIntakeResult> selectFromGallery() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return const ReceiptImageCancelled();
      return await _acceptFile(picked, ReceiptImageSource.gallery);
    } on PlatformException catch (error) {
      return ReceiptImageFailed(_pickerFailure(error));
    } on Exception {
      return ReceiptImageFailed(_operationalFailure);
    }
  }

  @override
  Future<ReceiptImageIntakeResult?> recoverLostData() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      if (response.exception case final PlatformException error) {
        return ReceiptImageFailed(_pickerFailure(error));
      }
      if (response.exception != null) {
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.localImportError,
            retryable: false,
          ),
        );
      }
      if (response.file == null) return const ReceiptImageCancelled();
      return await _acceptFile(
        response.file!,
        ReceiptImageSource.recoveredGallery,
      );
    } on PlatformException catch (error) {
      return ReceiptImageFailed(_pickerFailure(error));
    } on Exception {
      return ReceiptImageFailed(_operationalFailure);
    }
  }

  Future<ReceiptImageIntakeResult> _acceptFile(
    XFile source,
    ReceiptImageSource sourceType,
  ) async {
    try {
      final sourceLength = await source.length();
      if (sourceLength > ReceiptImageLimits.maxBytes) {
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.byteLimitExceeded,
            retryable: false,
          ),
        );
      }
      final bytes = await source.readAsBytes();
      final validation = ReceiptImageValidator.validate(bytes);
      if (validation is ReceiptImageFailed) return validation;
      final metadata = (validation as _ValidatedImage);
      final directory = await _storageDirectory();
      final id = _idGenerator();
      final storageRef = path.posix.join(
        _directoryName,
        '$id.${metadata.extension}',
      );
      final destination = File(
        path.join(directory.path, '$id.${metadata.extension}'),
      );
      final temporary = File('${destination.path}.partial');
      try {
        await temporary.writeAsBytes(bytes, flush: true);
        await temporary.rename(destination.path);
        final draft = ReceiptImageDraft(
          id: id,
          storageRef: storageRef,
          mimeType: metadata.mimeType,
          byteSize: bytes.length,
          width: metadata.width,
          height: metadata.height,
          source: sourceType,
        );
        final previous = await _readStoredDraft(directory);
        await _writeManifest(directory, draft);
        if (previous != null && previous.id != draft.id) {
          await _deleteDraftFile(directory, previous);
        }
        await _reconcile(directory, keep: draft);
        return ReceiptImageReady(draft);
      } catch (_) {
        if (await temporary.exists()) await temporary.delete();
        if (await destination.exists()) await destination.delete();
        return ReceiptImageFailed(_operationalFailure);
      }
    } on FileSystemException {
      return ReceiptImageFailed(_operationalFailure);
    } on Exception {
      return ReceiptImageFailed(_operationalFailure);
    }
  }

  @override
  Future<void> discard(ReceiptImageDraft draft) async {
    if (!_isSafeStorageRef(draft.storageRef, draft.id)) return;
    try {
      final directory = await _storageDirectory();
      await _deleteDraftFile(directory, draft);
      final stored = await _readStoredDraft(directory);
      if (stored?.id == draft.id) {
        final manifest = File(path.join(directory.path, _manifestName));
        if (await manifest.exists()) await manifest.delete();
      }
      await _reconcile(directory);
    } on FileSystemException {
      // This is only best-effort cleanup of an app-owned temporary draft.
    }
  }

  @override
  Future<void> clearStaleDrafts() async {
    try {
      final directory = await _storageDirectory();
      await _reconcile(directory, keep: await _readStoredDraft(directory));
    } on FileSystemException {
      // A later fresh selection will fail closed if its controlled copy fails.
    }
  }

  @override
  Future<ReceiptImageIntakeResult?> restoreStoredDraft() async {
    try {
      final directory = await _storageDirectory();
      final draft = await _readStoredDraft(directory);
      await _reconcile(directory, keep: draft);
      if (draft == null) return null;
      final file = File(
        path.join(directory.path, path.basename(draft.storageRef)),
      );
      if (!await file.exists()) {
        await discard(draft);
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.invalidImage,
            retryable: false,
          ),
        );
      }
      final fileLength = await file.length();
      if (fileLength != draft.byteSize ||
          fileLength > ReceiptImageLimits.maxBytes) {
        await discard(draft);
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.invalidImage,
            retryable: false,
          ),
        );
      }
      final validation = ReceiptImageValidator.validate(
        await file.readAsBytes(),
      );
      if (validation is ReceiptImageFailed) {
        await discard(draft);
        return validation;
      }
      final metadata = validation as _ValidatedImage;
      if (metadata.mimeType != draft.mimeType ||
          metadata.width != draft.width ||
          metadata.height != draft.height) {
        await discard(draft);
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.invalidImage,
            retryable: false,
          ),
        );
      }
      return ReceiptImageReady(draft);
    } on FileSystemException {
      return ReceiptImageFailed(_operationalFailure);
    } on PlatformException {
      return ReceiptImageFailed(_operationalFailure);
    }
  }

  Future<Directory> _storageDirectory() async {
    final root = await _appSupportDirectory();
    final directory = Directory(path.join(root.path, _directoryName));
    await directory.create(recursive: true);
    if (Platform.isIOS) {
      await _storageChannel.invokeMethod<void>('excludeFromBackup', {
        'path': directory.path,
      });
    }
    return directory;
  }

  static bool _isSafeStorageRef(String storageRef, String id) =>
      storageRef == path.posix.join(_directoryName, '$id.jpg') ||
      storageRef == path.posix.join(_directoryName, '$id.png');

  Future<ReceiptImageDraft?> _readStoredDraft(Directory directory) async {
    final manifest = File(path.join(directory.path, _manifestName));
    if (!await manifest.exists()) return null;
    try {
      final value = jsonDecode(await manifest.readAsString());
      if (value is! Map<String, Object?>) return null;
      final id = value['id'];
      final storageRef = value['storageRef'];
      final mimeType = value['mimeType'];
      final byteSize = value['byteSize'];
      final width = value['width'];
      final height = value['height'];
      final source = value['source'];
      if (id is! String ||
          storageRef is! String ||
          mimeType is! String ||
          byteSize is! int ||
          width is! int ||
          height is! int ||
          source is! int ||
          source < 0 ||
          source >= ReceiptImageSource.values.length ||
          !_isSafeStorageRef(storageRef, id)) {
        return null;
      }
      return ReceiptImageDraft(
        id: id,
        storageRef: storageRef,
        mimeType: mimeType,
        byteSize: byteSize,
        width: width,
        height: height,
        source: ReceiptImageSource.values[source],
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> _writeManifest(
    Directory directory,
    ReceiptImageDraft draft,
  ) async {
    final manifest = File(path.join(directory.path, _manifestName));
    final temporary = File('${manifest.path}.partial');
    await temporary.writeAsString(
      jsonEncode(<String, Object>{
        'id': draft.id,
        'storageRef': draft.storageRef,
        'mimeType': draft.mimeType,
        'byteSize': draft.byteSize,
        'width': draft.width,
        'height': draft.height,
        'source': draft.source.index,
      }),
      flush: true,
    );
    if (await manifest.exists()) await manifest.delete();
    await temporary.rename(manifest.path);
  }

  Future<void> _deleteDraftFile(
    Directory directory,
    ReceiptImageDraft draft,
  ) async {
    final file = File(
      path.join(directory.path, path.basename(draft.storageRef)),
    );
    if (await file.exists()) await file.delete();
  }

  Future<void> _reconcile(
    Directory directory, {
    ReceiptImageDraft? keep,
  }) async {
    final keepName = keep == null ? null : path.basename(keep.storageRef);
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! File) continue;
      final name = path.basename(entry.path);
      if (name == _manifestName || name == keepName) continue;
      await entry.delete();
    }
  }

  static const _operationalFailure = ReceiptImageFailure(
    ReceiptImageFailureKind.localImportError,
    retryable: true,
  );

  static ReceiptImageFailure _pickerFailure(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('permission') || code.contains('denied')) {
      return const ReceiptImageFailure(
        ReceiptImageFailureKind.permissionDenied,
        retryable: false,
      );
    }
    if (code.contains('unsupported')) {
      return const ReceiptImageFailure(
        ReceiptImageFailureKind.pickerUnavailable,
        retryable: false,
      );
    }
    return _operationalFailure;
  }

  static String _defaultId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${Random.secure().nextInt(1 << 32).toRadixString(36)}';
}

class ReceiptImageValidator {
  static Object validate(Uint8List bytes) {
    if (bytes.length > ReceiptImageLimits.maxBytes) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.byteLimitExceeded,
          retryable: false,
        ),
      );
    }
    final signature = _signature(bytes);
    if (signature == null) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.unsupportedImage,
          retryable: false,
        ),
      );
    }
    image.Decoder? decoder;
    image.DecodeInfo? decodeInfo;
    try {
      decoder = image.findDecoderForData(bytes);
      decodeInfo = decoder?.startDecode(bytes);
    } catch (_) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.invalidImage,
          retryable: false,
        ),
      );
    }
    if (decodeInfo == null) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.invalidImage,
          retryable: false,
        ),
      );
    }
    if (decodeInfo.width > ReceiptImageLimits.maxDimension ||
        decodeInfo.height > ReceiptImageLimits.maxDimension) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.dimensionsExceeded,
          retryable: false,
        ),
      );
    }
    if (decodeInfo.width * decodeInfo.height > ReceiptImageLimits.maxPixels) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.pixelLimitExceeded,
          retryable: false,
        ),
      );
    }
    if (decodeInfo.numFrames != 1) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.unsupportedImage,
          retryable: false,
        ),
      );
    }
    // Decode only after header bounds pass. This avoids allocating a bitmap
    // solely to discover a decompression-bomb dimension.
    try {
      if (decoder!.decode(bytes, frame: 0) == null) {
        return const ReceiptImageFailed(
          ReceiptImageFailure(
            ReceiptImageFailureKind.invalidImage,
            retryable: false,
          ),
        );
      }
    } catch (_) {
      return const ReceiptImageFailed(
        ReceiptImageFailure(
          ReceiptImageFailureKind.invalidImage,
          retryable: false,
        ),
      );
    }
    return _ValidatedImage(
      signature.$1,
      signature.$2,
      decodeInfo.width,
      decodeInfo.height,
    );
  }

  static (String, String)? _signature(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return ('image/jpeg', 'jpg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10) {
      return ('image/png', 'png');
    }
    return null;
  }
}

class _ValidatedImage {
  const _ValidatedImage(this.mimeType, this.extension, this.width, this.height);
  final String mimeType;
  final String extension;
  final int width;
  final int height;
}

class DeterministicReceiptImageIntakeAdapter implements ReceiptImageIntakePort {
  const DeterministicReceiptImageIntakeAdapter({
    this.selection,
    this.recovered,
    this.stored,
  });
  final ReceiptImageIntakeResult? selection;
  final ReceiptImageIntakeResult? recovered;
  final ReceiptImageIntakeResult? stored;
  @override
  Future<ReceiptImageIntakeResult> selectFromGallery() async =>
      selection ?? const ReceiptImageCancelled();
  @override
  Future<ReceiptImageIntakeResult?> recoverLostData() async => recovered;
  @override
  Future<ReceiptImageIntakeResult?> restoreStoredDraft() async => stored;
  @override
  Future<void> discard(ReceiptImageDraft draft) async {}
  @override
  Future<void> clearStaleDrafts() async {}
}
