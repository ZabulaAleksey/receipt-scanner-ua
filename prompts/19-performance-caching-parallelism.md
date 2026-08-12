# 44. PROMPT 19 — Performance / Caching / Parallelism

```text
Сначала profile, потом optimize.

Измерь preprocess, OCR, DB, normalization, Excel.
Кэшируй только deterministic expensive stages.
Parallelism — между независимыми receipts.
Не поднимай N heavy model instances без memory benchmark.
```

### DoD
- before/after benchmark;
- correctness regression отсутствует;
- single-thread fallback есть.

---
