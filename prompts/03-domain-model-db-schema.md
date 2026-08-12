# 28. PROMPT 03 — Domain Model + DB Schema

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
- Decimal round-trip;
- unique content hash;
- repository behavior.

### DoD
- DB создаётся с нуля;
- schema documented;
- Excel не storage.

---
