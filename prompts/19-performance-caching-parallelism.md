# 44. PROMPT 19 — производительность, кэширование и параллелизм

```text
Сначала profile, потом optimize.

Измерь preprocess, OCR, DB, normalization, Excel.
Кэшируй только deterministic expensive stages.
Parallelism — между независимыми receipts.
Не поднимай N heavy model instances без memory benchmark.
```

### DoD
- benchmark до и после;
- регрессия корректности отсутствует;
- однопоточный fallback существует.

---
