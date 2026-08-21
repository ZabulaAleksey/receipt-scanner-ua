# Журнал архитектурных решений

## 21. DECISIONS.md

ADR-lite:

```md
## ADR-XXX — Title
Date:
Status:
Context:
Decision:
Alternatives:
Consequences:
Fallback:
Tests/benchmark:
```

Исторический список кандидатов ADR (актуальные решения ниже имеют приоритет):
- SQLite как источник истины;
- Excel только как отчёт;
- PaddleOCR как один из OCR adapter implementations (уточнено ADR-003);
- сохранение исходного OCR;
- parsing магазинов через адаптеры;
- fuzzy-нормализация с ручной проверкой;
- аналитический слой Arrow/Parquet;
- базовый вариант на CPU перед NPU.

## ADR-001 — UX-first последовательность

Date: 2026-08-20
Status: Accepted
Context: Старый roadmap реализовывал DB/OCR/CLI до проверки формы consumer product.
Decision: Использовать `UX MVP → Functional MVP → Production MVP`; старые prompts сохранить как remapped backlog.
Alternatives: продолжить CLI-first; сразу строить production mobile/backend.
Consequences: fixture-driven UX появляется раньше реальных integrations; backend backlog не удаляется.
Fallback: если native prototype невозможен в доступном окружении, зафиксировать platform limitation, но не подменять target PWA без отдельного решения.
Tests/benchmark: documentation/link checks в R01; UX acceptance и component checks определяются R02/R03.

## ADR-002 — Local-first consumer baseline

Date: 2026-08-20
Status: Accepted
Context: Cloud/account повышают стоимость, privacy-риск и блокируют offline use.
Decision: `LOCAL_ONLY` является полноценным baseline; sync/account/cloud OCR — optional adapters.
Alternatives: mandatory hosted backend; cloud OCR for every receipt.
Consequences: local storage и offline flows являются обязательными; online convenience может появиться позднее.
Fallback: недоступность optional provider возвращает пользователя к local mode без потери canonical data; corrupted state не скрывается fallback.
Tests/benchmark: no-network demo в R03, persistence/recovery tests в Functional MVP.

## ADR-003 — Provider и regional boundaries

Date: 2026-08-20
Status: Accepted
Context: Прямая зависимость от PaddleOCR и украинских merchant rules ограничивает заменяемость core.
Decision: OCR providers подключаются через port/adapter; Украина — первый Region Pack; merchant adapters являются оптимизацией generic path.
Alternatives: единственный встроенный OCR SDK; country/store hardcode.
Consequences: Text Recognition Core, local/platform/cloud OCR могут конкурировать по одному контракту; unknown merchant остаётся штатным.
Fallback: CPU/local adapter сохраняется, если экспериментальный provider недоступен; semantic/schema mismatch завершается явной ошибкой.
Tests/benchmark: contract tests и benchmark требуются в Functional MVP.

## ADR-004 — Flutter для fixture-driven mobile shell

Date: 2026-08-20
Status: Accepted for R03 prototype
Context: R03 требует один общий Android/iOS UX shell, быстрый offline feedback, widget/component, accessibility и golden tests. В репозитории не было mobile stack или product code. Локальный Windows host не содержит Android SDK и не может собирать iOS, но имеет Visual Studio C++/Windows SDK. Capability spike установил Flutter `3.47.1` / Dart `3.13.1`; Windows runner доступен как validation-only target.
Decision: Использовать Flutter для R03. Android и iOS остаются product targets; Windows runner существует только для локальной compile/visual verification и не меняет product scope. UI зависит от Dart ports/use cases и fixture repository. Camera/OCR/backend/persistence SDK не подключаются. Перед Functional MVP отдельно проверить стоимость platform channels/Pigeon и ownership on-device storage.
Alternatives: Kotlin Multiplatform + Compose Multiplatform — сильнее для прямого Kotlin/Swift interop и остаётся допустимым будущим вариантом, но для текущего UX shell имеет более сложный Gradle/source-set bootstrap и менее зрелый общий golden/component workflow; два параллельных spikes запрещены. Отдельные SwiftUI/Jetpack Compose clients и PWA отклонены как избыточные либо не соответствующие R03.
Consequences: одна Dart/Flutter UI codebase ускоряет проверку всех 15 routes и deterministic fixtures; будущие native camera/OCR adapters потребуют platform channel/plugin boundary. Android build остаётся `UNVERIFIED` до Android SDK, iOS build — до macOS/Xcode. Windows build не является mobile E2E.
Fallback: fixture `CameraCapturePort` и остальные domain ports не зависят от Flutter plugins. Если Functional MVP spike докажет неприемлемую сложность native integration, решение пересматривается отдельным ADR до подключения реальных данных; текущий shell не дублируется параллельно на KMP.
Tests/benchmark: `flutter analyze`, unit/widget/integration tests, Flutter Accessibility Guideline API, deterministic golden screenshots и `flutter build windows`. Product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

Официальные основания: [Flutter testing](https://docs.flutter.dev/testing/overview), [accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing), [platform channels](https://docs.flutter.dev/platform-integration/platform-channels), [Kotlin Multiplatform quickstart](https://kotlinlang.org/docs/multiplatform/quickstart.html), [Compose accessibility](https://kotlinlang.org/docs/multiplatform/compose-accessibility.html).

## ADR-005 — SQLite за async `ReceiptRepository` для первого local persistence slice

Date: 2026-08-21
Status: Accepted; implemented locally in R04, platform runtime evidence pending
Context: R03 хранит `ReceiptFixture` только в памяти процесса. Functional MVP требует local-first сохранение и чтение после перезапуска, но не разрешает одновременно подключать camera, OCR, backend или sync. Android/iOS остаются product targets, а Windows — только validation runner.
Decision: В R04 `ReceiptRepository` становится асинхронной application boundary для `ReceiptAggregate`. Android/iOS persistence adapter использует SQLite через `sqflite`; `sqflite_common_ffi` используется только для deterministic unit/integration проверки на Windows. Первый schema version хранит lossless versioned representation aggregate и минимальные query fields; деньги остаются integer minor units, без `double`/`float`. В production composition root нет автоматического заполнения пользовательской базы fixtures.
Alternatives: оставить in-memory store; использовать файлы/JSON как canonical state; сразу внедрить ORM/code generation; выбрать Drift; подключить Python/SQLAlchemy core. Они отклонены для R04 как недолговечные, преждевременно сложные либо не соответствующие Flutter mobile boundary. Drift или отдельный processing core могут быть рассмотрены позже при доказанной сложности schema/query.
Consequences: UI и use cases получают typed async load/save failures и честные loading/empty/local-read-error states. Persistent DTO/schema не смешивается с Flutter UI или fixture data. SQLite schema migration выполняется транзакционно; corrupted/incompatible state не подменяется in-memory/fixture данными. Повторное открытие доступно только по user-initiated retry; destructive reset и backup/restore не входят в R04.
Fallback: local SQLite is primary. Для transient open failure разрешён явный retry с повторным open; при corrupted/incompatible schema — fail closed с безопасной ошибкой и без перезаписи данных. Camera/OCR/network fallback отсутствует, потому что эти capabilities вне scope.
Tests/benchmark: format/analyze and 25 Flutter unit/widget/component tests passed, including repository round-trip/reopen, duplicate, corruption, index mismatch, size limits, lifecycle retry and dispose. Windows device integration is blocked by missing Developer Mode/symlink support; Android/iOS runtime require their SDK/host and remain `UNVERIFIED`.

Основания: [sqflite package](https://pub.dev/packages/sqflite) документирует SQLite для Android/iOS; [sqflite_common_ffi](https://pub.dev/documentation/sqflite_common_ffi/latest/) поддерживает Windows и unit tests.

---
