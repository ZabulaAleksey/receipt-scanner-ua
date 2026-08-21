# R05 — Local receipt image intake

Статус: `PLANNED`. Тип: Functional MVP implementation slice.

## Goal

Позволить пользователю выбрать одну фотографию чека из photo library, безопасно сохранить её локально в app-controlled storage и увидеть Preview без подключения camera capture, OCR, parser, backend или sync.

## Context

R04 завершил async local receipt persistence и Windows platform integration. Текущий Scan flow — fixture-driven, а Preview показывает placeholder. R05 вводит отдельную image-intake boundary, чтобы real user input не зависел от synthetic fixtures и не протекал напрямую в UI/SQLite.

Канонический контракт: [`specs/features/local-receipt-image-intake.spec.md`](../specs/features/local-receipt-image-intake.spec.md). Связанные границы: [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md), [`docs/DESIGN.md`](../docs/DESIGN.md), [`docs/SECURITY.md`](../docs/SECURITY.md), [`docs/PRIVACY.md`](../docs/PRIVACY.md), ADR-006 в [`docs/DECISIONS.md`](../docs/DECISIONS.md).

## Current state / evidence

- R04 Windows persistence integration passed: `flutter test --no-pub integration_test/local_persistence_flow_test.dart -d windows`.
- `CameraCapturePort` and `DeterministicCameraCaptureAdapter` accept only `ReceiptFixture`; they are demo/test behaviour.
- Production `ReceiptRepository` persists structured aggregates only. No raw image is stored in SQLite.
- Android/iOS remain product targets; their native runtime is still `UNVERIFIED` on this host.

## Scope

- Add `ReceiptImageIntakePort`, safe image-draft metadata and typed intake failures.
- Use endorsed Flutter `image_picker` only for a single `ImageSource.gallery` acquisition behind the port; use a pure-Dart decoder only to validate image type/dimensions before acceptance.
- Copy accepted file to a fixed app-controlled local directory with generated id and storage-relative reference.
- Support picker lost-data recovery, loading/cancel/error/retry UX and Preview metadata.
- Add the iOS photo-library usage description required by the plugin. Android uses the platform picker/scoped storage; do not add broad storage permissions.
- Add focused new tests and a deterministic Windows integration scenario where possible.

## Non-goals

- `ImageSource.camera`, camera permission, video, multi-select, image preprocessing/transforms, OCR, parser, normalization, review, receipt creation from image, raw-image SQLite persistence, backend/sync/backup/export/delete UI.
- Editing accepted fixtures/goldens/tests or converting Windows into a product target.

## Requirements

Implement all requirements and acceptance criteria in the linked SPEC. In particular:

- enforce byte, dimension and pixel limits before accepting or copying input;
- never expose/persist user-selected absolute paths or raw image content;
- distinguish cancel from a failure; provide retry only for explicit operational errors;
- use the same validation/copy pipeline for normal picker and recovered lost data;
- preserve current fixture flow for accepted R03 tests without using it as fallback for image intake.

## Architecture constraints

- Ports/use cases own application contracts; adapters own picker, decoder and filesystem interaction; widgets do not call plugin APIs.
- Keep image asset storage separate from R04 SQLite aggregate schema. Do not invent a schema migration merely to persist a temporary image reference.
- `image_picker` is an implementation choice for photo-library import, not a domain type; `XFile` must not cross the application boundary.
- The adapter must be injectable so unit/widget tests run without a real picker or user image.

## Security & abuse constraints

- Treat every selected file and its metadata as untrusted. Validate MIME/header/decode, byte size, width/height and pixel count before acceptance.
- Use generated names and fixed app directories only; no user filename/path may control a destination.
- Do not log raw bytes, absolute path, EXIF or receipt text. Do not make network calls or add cloud fallbacks.
- On Android, recover picker lost data on startup/re-entry; do not repeat an operation when its side effect is unknown.

## Fallback / failure behavior

```text
gallery picker + controlled local copy
→ user-initiated retry for transient picker/storage error
→ explicit local-import-error
→ fail closed
```

Cancel, permission denial, invalid/oversized/unsupported image and corruption are non-retryable unless the user explicitly starts a fresh selection. No fixture, camera, cloud or partial-file fallback.

## Compatibility / migration

Add packages through `pubspec.lock` and generated plugin registrants. R04 SQLite v1 and accepted test artifacts remain unchanged. iOS runtime check is unavailable without macOS/Xcode; Android runtime requires Android SDK/device evidence.

## Testing & validation

- Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- Run `flutter analyze --no-pub` and `flutter test --no-pub test`.
- Add unit/negative tests for MIME/header, byte/dimension/pixel bounds, generated destination, partial-copy cleanup and lost-data recovery.
- Add controller/widget tests for selecting, cancel, invalid/error, retry and ready Preview state.
- Preserve existing R03/R04 tests, fixtures and goldens without edits.
- Run a Windows deterministic integration path if compatible; do not call it Android/iOS product E2E.

## Acceptance criteria

All AC-IMG-001 through AC-IMG-006 in the linked SPEC are met. Evidence must distinguish local unit/widget validation, Windows runner validation and unverified Android/iOS runtime.

## Definition of Done

- Code conforms to the R05 SPEC and ADR-006.
- Security negative tests and ordinary relevant tests pass.
- Documentation/status records verified facts, including unavailable native checks.
- Work is committed on a non-protected branch. Push/merge occur only with explicit user approval.

## Out-of-scope follow-ups

R06 camera capture and permissions; R07 preprocessing/crop; R08 OCR adapter; later parser/review/image retention management each need an independent SPEC/prompt.
