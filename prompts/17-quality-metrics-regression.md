# 42. PROMPT 17 — Quality Metrics + Regression Harness

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
- baseline versioned;
- critical threshold comparison работает;
- regression report показывает компонент ухудшения.

---
