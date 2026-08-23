# Этапы Receipt Scanner UA

Единственный исполняемый источник этапов проекта. Статусы сверяются с `docs/ROADMAP.md` и `docs/AI_STATUS.md`; требования — со связанными SPEC и ADR. Документ объединяет принятую UX-first последовательность R00–R05 и сохранённый backlog 00–23 без потери уникальных ограничений.

## Порядок работы

1. Выбрать ровно один этап.
2. Проверить его входной контекст, scope, non-goals, security/fallback и acceptance criteria.
3. Не менять принятые tests/fixtures/goldens без отдельного решения контракта.
4. Обновить evidence и статус только после фактического прогона gates.
5. Push/merge выполнять только с явным разрешением пользователя.

## Универсальный контракт этапа
1. Работай только в Receipt Scanner UA и только в scope текущего prompt.
2. Прочитай project `AGENTS.md`, `docs/AI_STATUS.md`, текущий prompt и непосредственно относящиеся source-of-truth документы.
3. Для R00–R03 используй `docs/UX_FIRST_RECONCILIATION.md`; не загружай весь legacy backlog без необходимости.
4. До реализации существенного поведения проверь SPEC/acceptance criteria. Prompt не заменяет SPEC.
5. Не добавляй agents/hooks/MCP/skills/config до проверки `docs/CONTEXT_COMPATIBILITY.md`.
6. Сохраняй local-first режим, provenance, honest confidence, `Decimal`, adapter boundaries и возможность отключить экспериментальный backend.
7. Не изменяй принятые tests/fixtures/goldens в цикле реализации. Новые contract artifacts проходят отдельную приёмку.
8. После функциональных изменений обязательны unit, integration и component checks. E2E считается закрытым только для живого `client → API/CLI → backend`; иначе `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.
9. Архитектурные решения фиксируй ADR; performance-sensitive изменения — benchmark; retry/fallback/side effects — по fallback policy.
10. Обновляй `AI_STATUS.md` только подтверждённым evidence. Не начинай следующий prompt автоматически.

Запрещено: реальные чеки/секреты в Git, float для денег, скрытие low-confidence normalization, Excel как source of truth, обязательный cloud/account для local core, silent renumbering или удаление legacy prompts.

# Активная UX-first последовательность

## R00 — Согласование старого плана с UX-first направлением
Статус: `COMPLETE` (2026-08-20). Тип: documentation/reconciliation. Product code не изменён.

### Цель

Сопоставить `prompts/00–23` с направлением `UX MVP → Functional MVP → Production MVP`, не потеряв полезный OCR/parser/normalization backlog.

### Входной контекст

- `AGENTS.md`, `docs/AI_STATUS.md`, `docs/CONTEXT_COMPATIBILITY.md`;
- `docs/DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`;
- `prompts/README.md`, `prompts/UNIVERSAL_STAGE.md`;
- `docs/UX_FIRST_RECONCILIATION.md` как исходная матрица, если документ уже существует.

### Требования

1. Считать UX-first приоритетным продуктовым направлением.
2. Сохранить старые prompts как legacy backlog; не выполнять `01–23` напрямую до назначения им новой фазы и зависимостей.
3. Зафиксировать Quick UX и Power UX.
4. Сохранить local-first/offline core, provenance, confidence review, aliases, regional packs и unknown merchant path.
5. Native mobile означает Android/iOS targets, не PWA. KMP/Compose и Flutter остаются кандидатами до ADR/spike.
6. OCR implementations подключаются через adapter boundary; один SDK не становится доменной зависимостью.
7. B2B, cloud, billing и account system не входят в consumer UX MVP.
8. Не менять product code, schemas, dependencies, CI или infrastructure.

### DoD

- актуальна матрица `KEEP / MOVE / SPLIT / REWRITE / OBSOLETE`;
- `prompts/00–23` сохранены;
- UX MVP стоит перед DB/OCR/backend implementation;
- следующий этап однозначно `R01`;
- product code и зависимости не изменены.

### Evidence завершения

- матрица сохранения и переноса: `docs/UX_FIRST_RECONCILIATION.md`;
- активная последовательность: `prompts/README.md`;
- UX/mobile/local-first границы согласованы в `AGENTS.md`, `docs/DESIGN.md`, `docs/ARCHITECTURE.md` и `docs/ROADMAP.md`;
- все legacy prompts `00–23` присутствуют;
- проверка Markdown-ссылок и `git diff --check` пройдена;
- изменения `src/`, `tests/`, manifests, dependencies и CI отсутствуют.

## R01 — Обновление КАРКАСА Receipt Scanner UA
Статус: `COMPLETE` (2026-08-20). Тип: project overlay/documentation. Product code не изменён.

### Цель

После принятого R00 согласовать project-specific документы с UX-first направлением, не копируя глобальные правила ДЕВ.

### Scope

- проверить и точечно обновить `AGENTS.md`, SPEC, `ARCHITECTURE`, `DESIGN`, `SECURITY/PRIVACY`, `ROADMAP`, `DECISIONS`, `AI_STATUS/AI_PLAN`, prompt index и quality gates;
- закрепить границы Receipt Core, OCR adapters, Region Pack, Merchant Adapter, local storage, optional sync, native shell и future B2B;
- различить UX MVP, Functional MVP и Production MVP;
- оставить старые prompts в legacy backlog с новой фазой и зависимостями.

### Ограничения

- не создавать mobile app, OCR implementation или production infrastructure;
- не добавлять project-local agents/hooks/MCP/skills без подтверждённого пробела;
- до Production MVP не добавлять always-on server infrastructure, если этап выполняется local-first или на fixtures.

### DoD

- source-of-truth документы согласованы;
- `CONTEXT_COMPATIBILITY.md` классифицирует изменения;
- старый backlog сохранён;
- следующий этап — `R02`;
- product code/dependencies не изменены.

### Evidence завершения

- добавлены `specs/system.spec.md`, `docs/AI_PLAN.md`, `docs/SECURITY.md`, `docs/PRIVACY.md`;
- `AGENTS.md`, `README.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `AI_STATUS.md`, `AI_PLAN.md` и compatibility matrix согласованы;
- source-of-truth роли и UX/Functional/Production boundaries однозначны;
- документационные ссылки, обязательные artifacts и `git diff --check` проверены;
- все legacy prompts сохранены; product code, dependencies и CI не изменены;
- reviewer подтвердил DoD после устранения замечаний.

## R02 — UX MVP specification и state map
Статус: `COMPLETE`. Тип: specification/design. Реализация приложения в этом этапе не выполнялась.

### Цель

Специфицировать fixture-driven native-mobile-looking UX MVP до подключения камеры, OCR, backend, auth, billing, cloud или production persistence.

### Пользовательские пути

- Quick UX: `Home → Scan simulation → Preview → Processing → Result → Done`.
- Power UX: `Inbox/Review → correction → merchant/product resolution → history → price history → insights → storage/backup settings`.

### Экраны

Home; Camera/Scan simulation; Crop/Preview; Processing; Receipt Result; Review Queue; Line-item Correction; Unknown Merchant; Receipt Evidence; Purchases/History; Product/Price History; Insights; Storage/Sync; Backup/Restore; «Для бизнеса — скоро».

Для каждого экрана определить цель, actions, navigation, normal/loading/empty/error/offline/low-confidence/stale states, accessibility и границу fixture/domain data.

### Fixture scenarios

Известный merchant; low-confidence line; неизвестный ФОП; discount; pharmacy/non-grocery; total mismatch; duplicate; long receipt/multi-shot concept; offline/LOCAL_ONLY; sync teaser. Использовать только синтетические данные.

### UX-инварианты

- scan не обязан немедленно вести в review;
- неизвестный merchant — штатное состояние;
- OCR confidence не является вероятностью истины;
- raw evidence, parsed candidate и normalized entity различимы;
- cloud/subscription/B2B не блокируют local consumer core.

### DoD

- все экраны и состояния специфицированы;
- Quick/Power state map и fixture matrix готовы;
- acceptance criteria для R03 определены;
- реализации и инфраструктуры нет.

### Verification evidence

- UX contract: `specs/features/ux-mvp.spec.md`;
- state map: `docs/UX_STATE_MAP.md`;
- fixture matrix: `docs/UX_FIXTURE_MATRIX.md`;
- все 15 экранов и R03 acceptance criteria проверены;
- независимый read-only review пройден без блокеров после устранения lifecycle/privacy неоднозначностей;
- product code, dependencies, CI и принятые test artifacts не изменялись.

## R03 — Native mobile strategy и fixture-driven shell
Статус: `COMPLETE`. Тип: prototype implementation. Основание: принятый UX-контракт R02.

### Цель

Через ADR/spike выбрать минимально рискованный native-mobile stack и создать offline fixture-driven UX shell без реального OCR/backend.

### Technology decision

Сравнить Kotlin Multiplatform + Compose Multiplatform и Flutter по Android/iOS workflow, native camera path, local DB, OCR/native ML integration, Text Recognition Core integration, accessibility, performance, testing и maintainability. Решение подтверждать evidence.

### Scope

- Android и iOS app targets; не PWA/WebView wrapper;
- navigation, tokens/theme, reusable primitives, fixture repository и ports/use cases;
- минимум `Home → Scan simulation → Preview → Processing → Result`;
- Power UX routes допускаются как fixture skeletons;
- camera остаётся simulation за `CameraCapturePort` или эквивалентом.

### Non-goals

Production backend, real sync, billing, обязательный account, real OCR и production camera pipeline.

### Проверки и DoD

- ADR KMP/Compose vs Flutter;
- build/compile feasibility хотя бы доступного target с честно указанными ограничениями;
- navigation component tests, accessibility checks и стабильные screenshot/golden tests, где доступны;
- demo полностью работает без сети;
- UI зависит от ports/use cases;
- unit, integration и component проверки выполнены; E2E без живого backend помечен `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

### Verification evidence

- ADR-004 выбрал Flutter `3.47.1` / Dart `3.13.1`; KMP остаётся явным fallback для пересмотра до Functional MVP native integrations.
- Создан `mobile/` package с Android/iOS product targets и Windows validation runner, 15 typed routes, synthetic fixtures, ports/use cases и in-memory adapters.
- `dart format --output=none --set-exit-if-changed lib test integration_test` — passed.
- `flutter analyze --no-pub` — passed, no issues.
- `flutter test --no-pub test` — passed, 14 tests: unit, widget/component, accessibility, golden и smoke всех 15 routes.
- `flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows` — passed; offline Quick UX завершён без network dependency.
- `flutter build windows --release --no-pub` — passed.
- Android build: `UNVERIFIED` (Android SDK отсутствует). iOS build: `UNVERIFIED` (требуется macOS/Xcode).
- Product E2E: `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`; Windows integration test не выдаётся за mobile/backend E2E.

## R04 — Local receipt persistence
Статус: `IMPLEMENTED_AND_VALIDATED_ON_WINDOWS`; Android/iOS runtime остаётся `UNVERIFIED`. Тип: Functional MVP implementation slice.

### Goal

Заменить prototype-only `InMemoryReceiptStore` в production Flutter composition на local-first SQLite persistence за асинхронным `ReceiptRepository`, чтобы пользовательские Receipt aggregates сохранялись и читались после перезапуска приложения.

### Context

R03 создал Flutter shell с 15 typed routes, in-memory state и synthetic fixtures. Локальное хранение — первый intentional Functional MVP slice; оно не должно смешиваться с real camera/import, OCR, parsing, backend, sync или account.

Канонический контракт: [`specs/features/local-receipt-persistence.spec.md`](../specs/features/local-receipt-persistence.spec.md). Архитектурное решение: ADR-005 в [`docs/DECISIONS.md`](../docs/DECISIONS.md). Существующие UX/visual boundaries остаются в [`docs/DESIGN.md`](../docs/DESIGN.md).

### Current state / evidence

- `mobile/lib/src/domain.dart` содержит synchronous `ReceiptRepository` и `InMemoryReceiptStore`.
- `mobile/lib/src/composition.dart` injects `InMemoryReceiptStore`; `AppController` seeds fixtures in memory.
- UI читает receipt list в Home, Review, History и Price History; existing shell уже имеет loading/empty/error/offline states.
- В `mobile/pubspec.yaml` отсутствуют persistence dependencies.
- R03 tests, including 14 unit/widget/component checks, passed before this plan. Android/iOS runtime remain `UNVERIFIED` in the current host.

### Scope

- Ввести `ReceiptAggregate` domain contract, async repository lifecycle и typed persistence failures without leaking SQLite into UI.
- Реализовать SQLite v1 adapter for Android/iOS using `sqflite`; use `sqflite_common_ffi` only for deterministic Windows/unit/integration validation where needed.
- Сохранить lossless aggregate payload plus minimal query fields, stable id and schema version; keep money in integer minor units.
- Переключить production composition root to persistent repository; keep fixture/demo dependencies explicit and separate from user storage.
- Показать bootstrap loading, true empty, local read error и user-initiated retry through existing routes.
- Добавить only new tests required for this behavior; preserve all accepted tests, fixtures and goldens.
- Update relevant architecture/status documentation only after evidence is obtained.

### Non-goals

- real camera, gallery/photo import, raw image storage or permissions;
- OCR, parsing, normalization, merchant adapters and real review workflow;
- backend, sync, account, telemetry, billing, backup/restore, export, delete/reset UI;
- changing Android/iOS product target policy, treating Windows as a product target, or adding a parallel KMP implementation;
- schema v2+ and migration from an older user database (none exists before v1).

### Requirements

Implement PERS-001 through PERS-007 from the linked SPEC. In particular:

- No direct storage access from widgets, fixture repository or routes.
- Saving and reopening preserve stable id, money precision and provenance-relevant fields.
- Empty is not automatically populated by fixture data in production.
- Repository duplicate behavior is documented and test-covered.
- Deserialization validates schema and payload before constructing a domain aggregate.
- Errors shown to users/logs are safe categories, never receipt payload or secrets.

### Architecture constraints

- Keep application/domain, persistence DTO/schema and UI/fixture data distinct.
- Preserve adapter boundaries and local-first `LOCAL_ONLY` baseline.
- Use Flutter composition root for dependency selection; do not scatter platform checks across screens.
- SQLite is the canonical mutable local store for this slice; Excel/JSON files are not a database substitute.
- Do not retain `ReceiptFixture` as the persistent production domain type: fixture scenarios map into `ReceiptAggregate`.
- New packages must be pinned through the lockfile and reviewed for target compatibility; do not add unrelated dependencies.

### Security & abuse constraints

- Use only application-controlled platform storage paths; never accept arbitrary user path input.
- Validate payload version, shape, required values and resource limits before reading into domain objects.
- No real receipts, PII, test credentials or raw image payloads in Git, fixtures or ordinary logs.
- Do not expose destructive reset/recovery controls in R04. Failed migration, corrupt data or incompatible schema must retain the original state for explicit future recovery.

### Fallback / failure behavior

```text
SQLite open/read
→ user-initiated close/reopen retry for a transient operational failure
→ explicit local-read-error UI
→ fail closed for corrupt payload, incompatible schema or failed migration
```

No automatic retry loop, in-memory fallback, fixture fallback or overwrite of unknown partial state. Save is disabled or fails explicitly until a successful open; it must not create duplicate records after a retry.

### Compatibility / migration

Create schema v1 transactionally. There is no pre-R04 persistent data migration. Future schema evolution starts from this documented v1 boundary and requires its own migration plan, tests and ADR update. The FFI adapter is validation tooling, not a different product persistence format.

### Testing & validation

Run existing checks from `mobile/` and add focused coverage:

- `dart format --output=none --set-exit-if-changed lib test integration_test`;
- `flutter analyze --no-pub`;
- `flutter test --no-pub test`;
- repository contract: lossless round-trip, duplicate semantics, empty database, close/reopen persistence, corrupt/incompatible payload, migration/open failure and retry;
- widget/component: loading, empty and local read-error/retry state;
- available Windows local persistence integration scenario; keep its evidence separate from product/backend E2E;
- run Android/iOS build/runtime checks only when required SDK/host is available; otherwise state `UNVERIFIED`.

Do not modify approved tests/fixtures/goldens in this stage. If an accepted test conflicts with this SPEC, stop and request a separate contract-change decision.

### Acceptance criteria

All seven acceptance criteria in the linked SPEC are met. Additionally, `AI_STATUS.md` must distinguish implementation, local validation, commit, push and merge evidence; it must not claim Android/iOS runtime or backend E2E without evidence.

### Definition of Done

- R04 code conforms to the persistence SPEC and ADR-005.
- Required tests/checks pass or unavailable platform checks are recorded honestly.
- Existing test contracts are preserved; no known undocumented regression remains.
- `ARCHITECTURE.md`, `DECISIONS.md`, `AI_STATUS.md` and `AI_PLAN.md` reflect verified facts only.
- Work is committed on a non-protected branch. Merge/push happen only with explicit user approval.

### Out-of-scope follow-ups

Real camera/import, evidence image retention, OCR/parser integration, review/correction persistence expansion, richer SQLite query schema, backup/restore, export and optional online services each require separate scope and acceptance criteria.

## R05 — Local receipt image intake
Статус: `IMPLEMENTED_LOCALLY`; native platform evidence pending. Тип: Functional MVP implementation slice.

### Goal

Позволить пользователю выбрать одну фотографию чека из photo library, безопасно сохранить её локально в app-controlled storage и увидеть Preview без подключения camera capture, OCR, parser, backend или sync.

### Context

R04 завершил async local receipt persistence и Windows platform integration. Текущий Scan flow — fixture-driven, а Preview показывает placeholder. R05 вводит отдельную image-intake boundary, чтобы real user input не зависел от synthetic fixtures и не протекал напрямую в UI/SQLite.

Канонический контракт: [`specs/features/local-receipt-image-intake.spec.md`](../specs/features/local-receipt-image-intake.spec.md). Связанные границы: [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md), [`docs/DESIGN.md`](../docs/DESIGN.md), [`docs/SECURITY.md`](../docs/SECURITY.md), [`docs/PRIVACY.md`](../docs/PRIVACY.md), ADR-006 в [`docs/DECISIONS.md`](../docs/DECISIONS.md).

### Current state / evidence

- R04 Windows persistence integration passed: `flutter test --no-pub integration_test/local_persistence_flow_test.dart -d windows`.
- `CameraCapturePort` and `DeterministicCameraCaptureAdapter` accept only `ReceiptFixture`; they are demo/test behaviour.
- Production `ReceiptRepository` persists structured aggregates only. No raw image is stored in SQLite.
- Android/iOS remain product targets; their native runtime is still `UNVERIFIED` on this host.

### Scope

- Add `ReceiptImageIntakePort`, safe image-draft metadata and typed intake failures.
- Use endorsed Flutter `image_picker` only for a single `ImageSource.gallery` acquisition behind the port; use a pure-Dart decoder only to validate image type/dimensions before acceptance.
- Copy accepted file to a fixed app-controlled local directory with generated id and storage-relative reference.
- Support picker lost-data recovery, loading/cancel/error/retry UX and Preview metadata.
- Add the iOS photo-library usage description required by the plugin. Android uses the platform picker/scoped storage; do not add broad storage permissions.
- Add focused new tests and a deterministic Windows integration scenario where possible.

### Non-goals

- `ImageSource.camera`, camera permission, video, multi-select, image preprocessing/transforms, OCR, parser, normalization, review, receipt creation from image, raw-image SQLite persistence, backend/sync/backup/export/delete UI.
- Editing accepted fixtures/goldens/tests or converting Windows into a product target.

### Requirements

Implement all requirements and acceptance criteria in the linked SPEC. In particular:

- enforce byte, dimension and pixel limits before accepting or copying input;
- never expose/persist user-selected absolute paths or raw image content;
- distinguish cancel from a failure; provide retry only for explicit operational errors;
- use the same validation/copy pipeline for normal picker and recovered lost data;
- preserve current fixture flow for accepted R03 tests without using it as fallback for image intake.

### Architecture constraints

- Ports/use cases own application contracts; adapters own picker, decoder and filesystem interaction; widgets do not call plugin APIs.
- Keep image asset storage separate from R04 SQLite aggregate schema. Do not invent a schema migration merely to persist a temporary image reference.
- `image_picker` is an implementation choice for photo-library import, not a domain type; `XFile` must not cross the application boundary.
- The adapter must be injectable so unit/widget tests run without a real picker or user image.

### Security & abuse constraints

- Treat every selected file and its metadata as untrusted. Validate MIME/header/decode, byte size, width/height and pixel count before acceptance.
- Use generated names and fixed app directories only; no user filename/path may control a destination.
- Do not log raw bytes, absolute path, EXIF or receipt text. Do not make network calls or add cloud fallbacks.
- On Android, recover picker lost data on startup/re-entry; do not repeat an operation when its side effect is unknown.

### Fallback / failure behavior

```text
gallery picker + controlled local copy
→ user-initiated retry for transient picker/storage error
→ explicit local-import-error
→ fail closed
```

Cancel, permission denial, invalid/oversized/unsupported image and corruption are non-retryable unless the user explicitly starts a fresh selection. No fixture, camera, cloud or partial-file fallback.

### Compatibility / migration

Add packages through `pubspec.lock` and generated plugin registrants. R04 SQLite v1 and accepted test artifacts remain unchanged. iOS runtime check is unavailable without macOS/Xcode; Android runtime requires Android SDK/device evidence.

### Testing & validation

- Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- Run `flutter analyze --no-pub` and `flutter test --no-pub test`.
- Add unit/negative tests for MIME/header, byte/dimension/pixel bounds, generated destination, partial-copy cleanup and lost-data recovery.
- Add controller/widget tests for selecting, cancel, invalid/error, retry and ready Preview state.
- Preserve existing R03/R04 tests, fixtures and goldens without edits.
- Run a Windows deterministic integration path if compatible; do not call it Android/iOS product E2E.

### Acceptance criteria

All AC-IMG-001 through AC-IMG-006 in the linked SPEC are met. Evidence must distinguish local unit/widget validation, Windows runner validation and unverified Android/iOS runtime.

### Definition of Done

- Code conforms to the R05 SPEC and ADR-006.
- Security negative tests and ordinary relevant tests pass.
- Documentation/status records verified facts, including unavailable native checks.
- Work is committed on a non-protected branch. Push/merge occur only with explicit user approval.

### Out-of-scope follow-ups

R06 camera capture and permissions; R07 preprocessing/crop; R08 OCR adapter; later parser/review/image retention management each need an independent SPEC/prompt.

# Сохранённый legacy backlog 00–23

Эти этапы остаются источником будущих backend/OCR/аналитических работ. Они не переопределяют текущую UX-first последовательность и активируются только отдельным решением.

## 25. PROMPT 00 — аудит совместимости контекста
```text
Работай в репозитории Receipt Scanner UA.

Сначала НЕ пиши product code.

Проведи Context Compatibility Audit.

1. Найди доступные workspace/project/global AGENTS, .codex, .agents, rules,
   skills, hooks, MCP config, agent TOML и Git workflow.
2. Не загружай весь глобальный архив в parent context.
3. Каждую планируемую локальную automation-сущность классифицируй:
   INHERITED / EXTEND / PROJECT_ONLY / CONFLICT / OBSOLETE.
4. Generic AI Dev Team roles локально не дублируй.
5. Project hooks и MCP по умолчанию не активируй.
6. Создай/обнови docs/CONTEXT_COMPATIBILITY.md.
7. Root AGENTS.md должен содержать только Receipt-specific deltas.
8. Не меняй глобальную AI Dev Team конфигурацию.
9. При конфликте оставляй более сильное/глобальное правило.
10. Дай итоговый список только тех локальных automation-файлов, которые действительно нужны.

Остановись после Stage 00.
```

#### DoD
- матрица совместимости создана;
- универсальных дубликатов = 0;
- дублирующих MCP = 0;
- глобальная конфигурация не изменена;
- локальный AGENTS компактный.

---

## 26. PROMPT 01 — основа репозитория
```text
Создай Foundation Receipt Scanner UA с учётом CONTEXT_COMPATIBILITY.md.

Используй Python src-layout и uv.
Создай pyproject.toml, uv.lock, .python-version, .gitignore, .env.example.
Создай canonical docs.
Не добавляй OCR models в Git.
Не добавляй MCP.
Не дублируй inherited hooks.

Добавь CLI entrypoint:
receipt --help
receipt doctor
receipt version

Doctor проверяет runtime, data directories, DB availability, config и OCR capability.
Добавь smoke/unit tests.
```

#### DoD
- `uv sync` воспроизводим;
- CLI запускается;
- tests запускаются;
- docs созданы;
- raw/secrets отсутствуют.

---

## 27. PROMPT 02 — базовый набор данных и конфиденциальность
```text
Сделай dataset-first основу.

Создай fixtures/synthetic, fixtures/anonymized, fixtures/expected.
Создай manifest: fixture id, shop, languages, difficulty, expected fields.
Реальные чеки держи только в data/raw и gitignore.

Нужные cases:
ATB-like, Silpo-like, generic, blur, perspective, shadow,
long-name wrap, weight item, discount, mixed Ukrainian/Russian.

Добавь privacy scanner для tracked fixtures.
Не регистрируй его как hook, если inherited DLP уже покрывает проверку.
```

#### DoD
- схема fixtures версионируется;
- реальные PII не отслеживаются;
- ожидаемые результаты существуют;
- privacy check проходит.

---

## 28. PROMPT 03 — доменная модель и схема базы данных
```text
Реализуй domain/persistence.

Entities:
ReceiptImage, OCRRun, OCRBlock, LogicalLine, Receipt, RawItemLine,
Shop, CanonicalProduct, ProductAlias, PurchaseItem,
ReviewItem, Correction, PipelineRun.

SQLite + SQLAlchemy + Alembic.
Money = Decimal/fixed precision.
Repository abstraction не должна привязывать domain к SQLite details.
Добавь constraints/indexes/foreign keys/migrations.
```

#### Tests
- migrations;
- round-trip Decimal;
- уникальный hash содержимого;
- поведение репозитория.

#### DoD
- DB создаётся с нуля;
- схема документирована;
- Excel не является хранилищем.

---

## 29. PROMPT 04 — приём данных и дедупликация
```text
Реализуй scan file/directory/recursive.

Для каждого файла:
validate → SHA-256 → dimensions/metadata → exact dedupe → DB registration.
Raw image не изменять.

Optional perceptual hash может только помечать probable duplicate,
но не удалять автоматически.

Batch должен переживать повреждённый файл.
```

#### DoD
- exact duplicate не создаёт вторую запись;
- недействительное изображение создаёт контролируемую ошибку;
- batch продолжает работу.

---

## 30. PROMPT 05 — базовая предварительная обработка изображений
```text
Реализуй versioned profile receipt-default-v1.

orientation → boundary → perspective → crop → grayscale →
illumination → CLAHE → denoise → deskew → resize.

Сохраняй OCR-ready variants:
RAW / ENHANCED_GRAY / ADAPTIVE_THRESHOLD / HIGH_CONTRAST.

Каждый transform — отдельная тестируемая функция.
Processed/cache должен быть rebuildable.
```

#### Tests
- rotation;
- perspective;
- low contrast;
- shadow;
- чистый чек.

#### DoD
- версия профиля сохранена;
- clean fixture существенно не ухудшается;
- rebuild работает.

---

## 31. PROMPT 06 — базовый OCR
```text
Введи OCRBackend abstraction.
Реализуй PaddleOCR backend с Ukrainian language path.

Сохраняй full text, blocks, polygons, confidence,
model/backend/version, config hash, duration.

Parser не писать внутри OCR.
OCR не пишет Excel напрямую.

Добавь receipt ocr <image-or-id>.
```

#### DoD
- тест контракта backend;
- анонимизированные интеграционные fixtures;
- raw OCR audit сохранён;
- базовые метрики записаны.

---

## 32. PROMPT 07 — оценка OCR и выбор нескольких профилей
```text
Сравни OCR для RAW / ENHANCED_GRAY / ADAPTIVE_THRESHOLD / HIGH_CONTRAST.

Score должен учитывать не только mean confidence, но и numeric consistency,
line sanity и ground truth metrics в evaluation mode.

Сохраняй chosen profile + evidence.
```

#### DoD
- автоматизированный отчёт benchmark;
- выбор profile объясним;
- регрессионный порог задан.

---

## 33. PROMPT 08 — восстановление layout
```text
Восстанови LogicalLine[] из OCR polygons.

Используй y overlap, baseline, x order, gaps, wrapped-name heuristics.
Сохраняй source OCRBlock ids.
Создай debug JSON/text representation.
```

#### DoD
- reading order стабилен;
- fixture перенесённого названия товара проходит;
- provenance сохраняется.

---

## 34. PROMPT 09 — определение магазина и framework адаптеров
```text
Создай StoreAdapter protocol и StoreDetector.

Baseline adapters:
ATB, Silpo, VARUS, NOVUS, Fora, Generic.

Detection возвращает score + evidence.
Не копируй core parser в каждый adapter.
Ambiguous shop → Generic/review warning.
```

#### DoD
- новый магазин можно добавить отдельным adapter;
- тесты определения существуют;
- ambiguous case не скрывается.

---

## 35. PROMPT 10 — core parser чеков
```text
Реализуй LogicalLine classification и item extraction.

Поддержи:
header, date/time, item, wrapped item, quantity/weight,
unit price, line total, discount, subtotal, total, payment,
fiscal/footer, unknown.

Unknown lines сохраняй.
Parser result = values + confidence + evidence.
```

#### DoD
- базовые fixtures извлекают товары;
- raw names не теряются;
- регрессионные тесты существуют.

---

## 36. PROMPT 11 — разбор чисел и сверка
```text
Поддержи десятичные запятые и точки, пробелы, обозначение умножения,
весовые количества и скидки.
Используй Decimal.

Проверяй:
qty * unit_price ≈ line_total;
sum(items) - discounts ≈ receipt total.

Несоответствие создаёт проблему качества, а не незаметное исправление данных.
```

#### Критерии завершения
- property-based тесты;
- граничные случаи округления;
- настраиваемый допуск;
- происхождение автоматических исправлений.

---

## 37. PROMPT 12 — базовая нормализация товаров
```text
Pipeline:
Unicode → case → whitespace → punctuation → units → OCR confusables →
alias lookup → candidate generation → scoring.

RapidFuzz — только один сигнал.
Не merge товары с различающимися значимыми brand/size/unit/flavor/fat/pack attributes.

Введи AUTO_ACCEPT / REVIEW / UNRESOLVED.
Калибруй на labeled dataset.
```

#### DoD
- точность автоматического принятия измеряется;
- false merge отдельно измеряется;
- каждое автоматическое совпадение объяснимо;
- low-confidence не merge автоматически.

---

## 38. PROMPT 13 — ручная проверка и обучение aliases
```text
Создай CLI review queue.

Показывай source/raw OCR/raw item/candidates/confidence.
Действия: choose product, create product, edit field, skip, create alias.

Каждая правка создаёт Correction.
Alias scope: receipt-only / shop-specific / global.
```

#### DoD
- audit trail;
- corrections воспроизводимы;
- alias source сохраняется;
- повторная правка возможна.

---

## 39. PROMPT 14 — сохранение истории цен
```text
Сформируй canonical PriceObservation/PurchaseItem history.

Храни receipt, shop, purchased_at, canonical product,
raw item, quantity, unit, unit_price, total, discount.

Добавь queries:
latest price; history by product; history by shop.
```

#### DoD
- цены по разным датам не перезаписываются;
- ручные исправления отражаются;
- история трассируется до чека.

---

## 40. PROMPT 15 — аналитический слой Arrow/Parquet
```text
Добавь схему PyArrow и снимки Parquet.

Не заменяй SQLite как источник истины.
Добавь round-trip тесты DB → Arrow → Parquet → Arrow.
Схема должна быть версионируемой.
```

#### Критерии завершения
- round-trip проверка Decimal и временных меток;
- возможность восстановить Parquet из базы данных;
- документированная производительность.

---

## 41. PROMPT 16 — экспорт Excel
```text
Реализуй openpyxl export.

Sheets:
Prices, Purchases, Receipts, Products, Aliases, Review, Errors, Quality, Metadata.

Prices: rows=products; columns=date+shop.
Same date/shop multiple receipts → #2/#3.

Добавь freeze panes, filters, number formats, widths,
low-confidence highlighting и export metadata.
```

#### DoD
- workbook открывается;
- expected sheets/cells проверяются тестом;
- несколько наблюдений не теряются;
- Excel строится только из canonical data.

---

## 42. PROMPT 17 — метрики качества и регрессионная инфраструктура
```text
Создай evaluator.

OCR: CER/WER/numeric accuracy.
Parser: field accuracy/item precision-recall-F1.
Normalization: top-1, auto-accept precision, false merge, false split, review rate.
End-to-end: usable receipt rate, corrections/receipt, seconds/receipt.

Генерируй JSON + Markdown report.
Большой report сохраняй в файл, parent context получает summary.
```

#### DoD
- базовый уровень версионируется;
- сравнение критического порога работает;
- regression report показывает компонент ухудшения.

---

## 43. PROMPT 18 — workflow CLI и пакетная обработка
```text
Собери команды:
scan, process, ocr, parse, normalize, review, export,
evaluate, benchmark, doctor, status.

Batch:
- продолжает после ошибки одного receipt;
- сохраняет stage status;
- поддерживает resume;
- не повторяет completed stage без --force;
- idempotent где возможно.
```

#### DoD
- каталог проходит end-to-end проверку;
- interrupted run можно продолжить;
- duplicate processing не плодит записи.

---

## 44. PROMPT 19 — производительность, кэширование и параллелизм
```text
Сначала profile, потом optimize.

Измерь preprocess, OCR, DB, normalization, Excel.
Кэшируй только deterministic expensive stages.
Parallelism — между независимыми receipts.
Не поднимай N heavy model instances без memory benchmark.
```

#### DoD
- benchmark до и после;
- регрессия корректности отсутствует;
- однопоточный fallback существует.

---

## 45. PROMPT 20 — необязательный локальный UI проверки
```text
Только после стабильного CLI review.
Перед UI обнови docs/DESIGN.md.

UI вызывает существующие application services; новую business logic во frontend не копировать.

Screens:
Queue, Receipt Detail, OCR Overlay, Parsed Items,
Candidate Products, Correction History, Status/Export.
Local-only default.
```

#### DoD
- CLI остаётся рабочим;
- проверка с приоритетом клавиатуры;
- DESIGN.md соответствует UI;
- business logic не дублирована.

---

## 46. PROMPT 21 — исследование ONNX / NPU
```text
Этап исследования.

Сначала измерь базовый уровень и узкое место на CPU.
Исследуй ONNX Runtime и аппаратные providers выполнения только для конкретной операции.

Сравни точность, время запуска, задержку, пропускную способность, RAM/VRAM, размер модели и доступность оборудования.
CPU = эталон и fallback.
```

#### Критерии завершения
- отчёт об исследовании;
- benchmark;
- feature flag;
- fallback;
- отсутствие обязательной зависимости от NPU.

---

## 47. PROMPT 22 — безопасность, восстановление после сбоев и резервные копии
```text
Проведи project-specific privacy/security review поверх inherited global rules.

Проверь:
raw data, logs, Excel formula injection, path traversal,
malicious/corrupt images, oversized images, decompression bombs,
DB backup/restore, migration recovery, user filenames.

Добавь backup canonical DB/config/aliases без raw photos по умолчанию.
```

#### DoD
- модели угроз и сбоев документированы;
- injection формул предотвращена;
- неконтролируемая запись файлов отсутствует;
- приёмочный тест резервного копирования и восстановления проходит.

---

## 48. PROMPT 23 — упаковка и финальная приёмка
```text
Проведи clean acceptance:

1. clean checkout;
2. uv sync;
3. migrations;
4. process acceptance dataset;
5. review required cases;
6. export Excel;
7. quality report;
8. full tests;
9. verify no raw PII/secrets tracked;
10. verify context automation compatibility;
11. update ARCHITECTURE/DECISIONS/DESIGN/AI_STATUS/AI_PLAN;
12. separate supported vs experimental features.
```

#### Final DoD
- fresh setup воспроизводим;
- набор данных проходит end-to-end проверку;
- Excel корректен;
- пороги качества соблюдены;
- audit trail есть;
- corrections сохраняются;
- универсальных дубликатов AI Dev Team = 0;
- CPU baseline работает;
- экспериментальное ускорение можно отключить.

---
