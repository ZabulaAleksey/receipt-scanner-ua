# 40. PROMPT 15 — Arrow/Parquet Analytical Layer

```text
Добавь PyArrow schema и Parquet snapshots.

Не заменяй SQLite как source of truth.
DB → Arrow → Parquet → Arrow round-trip tests.
Schema versioned.
```

### DoD
- Decimal/timestamps round-trip;
- Parquet rebuildable from DB;
- performance documented.

---
