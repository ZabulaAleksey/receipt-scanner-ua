# AI Status

## Текущий этап

R04 — local receipt persistence реализован и validated на Windows runner в рабочей ветке `plan/functional-mvp-local-persistence` поверх R03 shell. SQLite adapter, async bootstrap, local read/save/error/retry lifecycle и security boundaries проверены format/analyze/unit/widget/component и Windows platform integration tests.

Позиция в активной последовательности: R04 реализует первый slice этапа 5 из 6 (`Functional MVP`), но сама product-фаза ещё не завершена. На уровне продуктовых фаз завершена первая из трёх: `UX MVP`; Functional MVP находится в реализации.

## Выполнено

- R00–R02 завершили UX-first reconciliation, project overlay и UX MVP-контракт для 15 экранов и 14 synthetic fixture scenarios.
- ADR-004 выбрал Flutter для R03 prototype; KMP/Compose рассмотрен как альтернатива и оставлен fallback для отдельного пересмотра до Functional MVP native integrations.
- Создан `mobile/` Flutter package с Android/iOS product targets и Windows validation runner.
- Реализованы 15 typed routes, Quick и Power UX, deterministic synthetic fixtures, loading/empty/error/offline states и честные placeholders будущих capabilities.
- Production mobile composition использует async `ReceiptRepository` с SQLite v1 и `ReceiptAggregate`; synthetic fixtures остаются только явным demo/test input и не seed'ят пользовательскую БД.
- UI получает loading/empty/local-read-error/retry через controller, не обращаясь к SQLite напрямую. Corrupted/incompatible payload, index/payload mismatch и duplicate id fail closed без fixture/in-memory fallback.
- Real camera/OCR/network/auth/billing/sync не подключены.
- Добавлены unit, widget/component, accessibility, state coverage, golden и offline integration tests.
- Сохранены R03 design concepts в `docs/design-concepts/` и golden главного экрана в `mobile/test/goldens/home.png`.

## Verification evidence

- Flutter `3.47.1`, Dart `3.13.1`.
- `dart format --output=none --set-exit-if-changed lib test integration_test` — passed.
- `flutter analyze --no-pub` — passed, no issues.
- `flutter test --no-pub test` — passed, 14 tests, включая smoke всех 15 routes.
- `flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows` — passed.
- `flutter build windows --release --no-pub` — passed.
- R04: `dart format --output=none --set-exit-if-changed lib test integration_test` — passed.
- R04: `flutter analyze --no-pub` — passed, no issues.
- R04: `flutter test --no-pub test` — passed, 25 tests, включая SQLite round-trip/reopen, corruption/index mismatch/size limits и lifecycle retry/dispose.
- R04: `flutter test --no-pub integration_test/local_persistence_flow_test.dart -d windows` — passed; Windows app собран и persistence-flow без сети выполнен.
- R04 reviews: code review — no blocking findings after fixes; security review findings fixed in code, iOS runtime remains unverified.

## Известные ограничения

- Android build/runtime — `UNVERIFIED`: в текущей Windows-среде нет Android SDK.
- iOS build/runtime — `UNVERIFIED`: требуется macOS/Xcode.
- Windows runner служит только compile/visual/integration validation и не является product target.
- Windows device local-persistence integration — passed после включения Windows Developer Mode; Windows остаётся validation runner, а не product target.
- Реальный путь `client → API/CLI → backend` отсутствует; product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

## Далее

1. Спланировать R05 как отдельный image-intake или preprocessing slice; не подключать camera, OCR и backend одним этапом.
2. Для real Android/iOS image acquisition получить native runtime evidence на соответствующем host.
3. Не объявлять Android/iOS runtime или product E2E выполненными без соответствующего host/backend evidence.

## Реализовано и validated на Windows

- R04 ограничен local-first SQLite persistence: async `ReceiptRepository`, lossless сохранение/чтение Receipt aggregates, migration/failure boundaries и restart evidence.
- Выбор и rationale зафиксированы в ADR-005; Android/iOS build/runtime всё ещё не выдаются за пройденные.
