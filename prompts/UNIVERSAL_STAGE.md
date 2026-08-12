## 49. Universal stage prompt

```text
Работай только в Receipt Scanner UA.

Перед изменениями:
1. прочитай root AGENTS.md;
2. прочитай текущий section docs/PROGRESS.md;
3. открой только релевантный section ARCHITECTURE/DECISIONS;
4. прочитай target rule/skill при необходимости;
5. не загружай весь PROMPTS/ROADMAP/AI Dev Team archive.

Перед добавлением agent/hook/MCP/config проверь CONTEXT_COMPATIBILITY.md.

Составь короткий implementation plan.
Сделай минимальный проверяемый scope.

Обязательно:
- tests;
- regression fixture для OCR/parser/normalization bugfix;
- benchmark для performance-sensitive change;
- feature flag + fallback для experimental tech;
- ADR для архитектурного решения;
- PROGRESS update.

Запрещено:
- менять global AI Dev Team config из проекта;
- дублировать generic agents/hooks/MCP;
- коммитить raw receipts;
- float для денег;
- скрывать low-confidence normalization;
- делать Excel source of truth;
- вводить технологию без причины/измерения.
```

---
