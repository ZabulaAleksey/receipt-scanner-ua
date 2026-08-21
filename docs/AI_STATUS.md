# AI Status

## Текущий этап

R03 — fixture-driven native mobile shell завершён, локально проверен и слит в локальный `main` коммитом `9add92a`. Для первого Functional MVP slice подготовлены R04 SPEC, ADR и implementation prompt; реализация ещё не начата.

Позиция в активной последовательности: завершены этапы 1–4 из 6; для этапа 5 (`Functional MVP`) подготовлен первый implementation slice R04, но product-код этого этапа ещё не реализован. На уровне продуктовых фаз завершена первая из трёх: `UX MVP`.

## Выполнено

- R00–R02 завершили UX-first reconciliation, project overlay и UX MVP-контракт для 15 экранов и 14 synthetic fixture scenarios.
- ADR-004 выбрал Flutter для R03 prototype; KMP/Compose рассмотрен как альтернатива и оставлен fallback для отдельного пересмотра до Functional MVP native integrations.
- Создан `mobile/` Flutter package с Android/iOS product targets и Windows validation runner.
- Реализованы 15 typed routes, Quick и Power UX, deterministic synthetic fixtures, loading/empty/error/offline states и честные placeholders будущих capabilities.
- UI зависит от `FixtureScenarioPort`, `CameraCapturePort`, `ReceiptRepository`, `ReviewQueuePort`, `SettingsPort` и use cases; real camera/OCR/database/network/auth/billing/sync не подключены.
- Добавлены unit, widget/component, accessibility, state coverage, golden и offline integration tests.
- Сохранены R03 design concepts в `docs/design-concepts/` и golden главного экрана в `mobile/test/goldens/home.png`.

## Verification evidence

- Flutter `3.47.1`, Dart `3.13.1`.
- `dart format --output=none --set-exit-if-changed lib test integration_test` — passed.
- `flutter analyze --no-pub` — passed, no issues.
- `flutter test --no-pub test` — passed, 14 tests, включая smoke всех 15 routes.
- `flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows` — passed.
- `flutter build windows --release --no-pub` — passed.

## Известные ограничения

- Android build/runtime — `UNVERIFIED`: в текущей Windows-среде нет Android SDK.
- iOS build/runtime — `UNVERIFIED`: требуется macOS/Xcode.
- Windows runner служит только compile/visual/integration validation и не является product target.
- Prototype использует только synthetic fixtures и in-memory state; данные не сохраняются между запусками.
- Реальный путь `client → API/CLI → backend` отсутствует; product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

## Далее

1. Реализовать R04 строго по отдельному persistence SPEC/prompt: async local repository, SQLite schema v1, UI lifecycle и focused checks.
2. Не подключать одновременно camera, OCR и backend; после R04 отдельно выбрать следующий Functional MVP slice.
3. Не объявлять Android/iOS runtime или product E2E выполненными без соответствующего host/backend evidence.

## Подготовлено, но не реализовано

- R04 ограничен local-first SQLite persistence: async `ReceiptRepository`, lossless сохранение/чтение Receipt aggregates, migration/failure boundaries и restart evidence.
- Выбор и rationale зафиксированы в ADR-005; реализация выполняется только по `prompts/R04-local-receipt-persistence.md`.
