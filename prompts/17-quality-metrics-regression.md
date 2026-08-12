# 42. PROMPT 17 — метрики качества и регрессионная инфраструктура

```text
Создай evaluator.

OCR: CER/WER/numeric accuracy.
Parser: field accuracy/item precision-recall-F1.
Normalization: top-1, auto-accept precision, false merge, false split, review rate.
End-to-end: usable receipt rate, corrections/receipt, seconds/receipt.

Генерируй JSON + Markdown report.
Большой report сохраняй в файл, parent context получает summary.
```

### DoD
- базовый уровень версионируется;
- сравнение критического порога работает;
- regression report показывает компонент ухудшения.

---
