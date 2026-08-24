# AI Status

## Governance migration — 2026-08-24

- Репозиторий перемещён в `~/codex-workspace/receipt-scanner-ua`; linked worktree восстановлен.
- Содержание универсального контракта, R00–R05 и legacy backlog 00–23 полностью объединено в единственный `prompts/STAGES.md`.
- Calm Blue UI перенесён из глобального `~/.codex/DESIGN.md` в проектный `docs/CALM_BLUE_UI.md` и подключён через канонический `docs/DESIGN.md` без перезаписи Receipt-specific правил.
- Project overlay validator, Dart formatting, Flutter analyze и 14 Flutter tests — PASS.
- Основной checkout остаётся в пользовательском merge с R04/R05; `MERGE_HEAD`, index и backup ref сохранены, автоматическое разрешение не выполнялось.
- Push/merge не выполнялись.

## Текущий этап

R03 — fixture-driven native mobile shell завершён и локально проверен. Следующий разрешённый шаг — спланировать ограниченный первый slice Functional MVP и создать для него SPEC/prompt до подключения production integrations.

Позиция в активной последовательности: завершён этап 4 из 6; этап 5 (`Functional MVP`) ещё не начат и находится в планировании. На уровне продуктовых фаз завершена первая из трёх: `UX MVP`.

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

1. Спланировать первый Functional MVP slice с явным ownership локальных данных и контрактом Flutter ↔ processing core.
2. До реализации определить отдельный SPEC/prompt, acceptance criteria, миграционные и fallback boundaries.
3. Не подключать одновременно camera, OCR, persistence и backend одним неограниченным этапом.
