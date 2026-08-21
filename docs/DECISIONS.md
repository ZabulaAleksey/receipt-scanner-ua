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

---
