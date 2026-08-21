# Local receipt image intake specification

Статус: `IMPLEMENTED_LOCALLY`; Windows runner exit evidence and Android/iOS runtime pending
Версия: 0.1

## 1. Назначение

R05 даёт пользователю local-first путь выбрать **одну** фотографию чека из системной photo library, безопасно перенести её в app-controlled storage и увидеть честный Preview. Это создаёт входную границу для будущих preprocessing/OCR этапов, не имитируя их готовность.

## 2. Область

- Android/iOS photo-library selection через adapter за application port;
- app-controlled local copy, stable image id и ограниченный metadata contract: source, MIME, byte size, width, height и storage-relative reference;
- asynchronous Scan → Preview lifecycle: selecting, ready, cancelled, invalid-image, local-import-error и user-initiated retry;
- recovery выбранного файла после Android activity destruction, если plugin возвращает lost data;
- deterministic test adapter и Windows validation evidence без обращения к реальной user photo library.

## 3. Вне области

- camera capture, video, multi-select, crop, perspective correction, image transforms, OCR, parser, normalization и review;
- запись raw image или пути в SQLite `ReceiptAggregate`, автоматическое создание receipt, backend/sync/export/backup/restore;
- photo-library browsing UI, image deletion/reset UI и cloud upload;
- изменение accepted R03 fixtures, goldens или тестов.

## 4. Участники и предусловия

Пользователь запускает действие «Выбрать фото чека» на Scan. Локальное storage R04 доступно. Android/iOS являются product targets; Windows используется лишь для deterministic validation.

## 5. Функциональные требования

### FR-IMG-001 — отдельная image-intake boundary

UI и controller используют асинхронный `ReceiptImageIntakePort`; они не импортируют `image_picker`, `dart:io` или platform storage APIs. Fixture capture остаётся отдельным demo/test flow.

### FR-IMG-002 — local selection и controlled copy

После явного действия пользователя adapter запрашивает одну image из photo library. Успешный input валидируется и копируется в выделенный app-controlled local directory. В domain/UI не передаётся произвольный user path; хранится только storage-relative reference и metadata.

### FR-IMG-003 — validation и resource bounds

До принятия файла система допускает только decodable raster image с recognised MIME, размером не более 12 MiB, шириной/высотой не более 6 000 px и общим числом пикселей не более 20 000 000. Invalid, truncated, unsupported или over-limit input fail closed и не оставляет accepted image copy.

### FR-IMG-004 — lifecycle UX

Во время selection/copy/validation Scan или Preview показывает loading. Cancel возвращает к исходному ready state без error, persistence mutation или fixture fallback. Success показывает Preview с image metadata и честным сообщением, что OCR ещё не запущен. Retry доступен только для retryable selection/storage operational errors; invalid/security errors не повторяются автоматически.

### FR-IMG-005 — process interruption recovery

При следующем bootstrap/re-entry adapter один раз проверяет plugin lost-data recovery. Валидный recovered image проходит тот же validation/copy pipeline. Invalid/cancelled/unknown recovered result не создаёт receipt и отображается безопасным error/cancel state.

### FR-IMG-006 — local-only privacy

Ни raw bytes, ни user-selected absolute path, ни image content не попадают в SQLite aggregate, обычные logs, fixtures или Git. Import не делает network calls. iOS photo-library purpose string объясняет локальный выбор фотографии чека; camera/microphone permissions на этом этапе не запрашиваются.

## 6. Нефункциональные и security requirements

### NFR-IMG-001 — restart и ownership

Успешная copy переживает restart; временный plugin cache не является canonical storage. Копирование использует generated stable id и fixed directory, не строит путь из user filename и не допускает path traversal.

### SEC-IMG-001 — deny by default

Система принимает только input, прошедший MIME/header/decode и resource validation. Ошибки классифицируются безопасно, без user path, raw bytes или EXIF/receipt content.

### SEC-IMG-002 — no silent fallback

Permission denial, unsupported platform, corrupt input, quota/storage failure или lost-data error не заменяются fixture data, camera flow, cloud upload или частично принятой копией.

## 7. Основной сценарий

1. Пользователь выбирает photo-library action на Scan.
2. UI показывает selecting state, adapter открывает system picker.
3. Adapter получает single image, валидирует input и копирует его в local directory.
4. Controller публикует ready `ReceiptImageDraft`.
5. Preview показывает metadata и доступное дальнейшее действие без утверждения, что OCR уже выполнен.

## 8. Ошибки и fallback

```text
photo-library selection/copy
→ user-initiated retry only for transient operational failure
→ explicit local-import-error
→ fail closed
```

Cancel, permission denial, unsupported MIME/format, decoder failure, dimension/pixel/byte limit and integrity failures are non-retryable by default. No in-memory/fixture or cloud fallback is allowed.

## 9. Совместимость и migration

R05 не меняет SQLite v1 aggregate schema. New image files live outside the database in an app-controlled directory and are not considered an R04 migration. The existing deterministic fixture flow and its accepted contracts remain supported.

## 10. Критерии приёмки

- AC-IMG-001: imported valid image produces a stable local image reference and correct safe metadata; original temporary path is not persisted.
- AC-IMG-002: cancel, invalid/corrupt image, unsupported MIME, byte/dimension/pixel limits and copy failure leave no accepted image and have distinct safe UX states.
- AC-IMG-003: recovery input follows the same validation/copy policy and never creates a receipt implicitly.
- AC-IMG-004: no raw image, absolute user path or image content is written into SQLite payload/logs/fixtures.
- AC-IMG-005: existing accepted R03/R04 tests remain unchanged and pass; focused domain/controller/widget tests cover this SPEC.
- AC-IMG-006: `dart format`, `flutter analyze`, full `flutter test test` and available Windows validation path pass; Android/iOS runtime is recorded truthfully.

## 11. Связь с тестами

| Требование | Планируемое покрытие |
|---|---|
| FR-IMG-001/002 | intake port, controlled-copy and metadata unit tests |
| FR-IMG-003, SEC-IMG-001 | malformed/MIME/size/dimension/pixel/path negative tests |
| FR-IMG-004 | controller and Scan/Preview widget state tests |
| FR-IMG-005 | lost-data adapter/controller tests |
| FR-IMG-006, SEC-IMG-002 | privacy/no-fallback and permission/error tests |

## 12. Открытые вопросы

- Camera capture and image transforms require separate R06+ scope after R05 evidence.
- User-facing retention/delete semantics remain deferred to a later storage-management stage.

## 13. История изменений

- 2026-08-21: создана после verified R04 Windows persistence integration.
