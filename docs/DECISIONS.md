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

---
