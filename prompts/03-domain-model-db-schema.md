# 28. PROMPT 03 — доменная модель и схема базы данных

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

### Tests
- migrations;
- round-trip Decimal;
- уникальный hash содержимого;
- поведение репозитория.

### DoD
- DB создаётся с нуля;
- схема документирована;
- Excel не является хранилищем.

---
