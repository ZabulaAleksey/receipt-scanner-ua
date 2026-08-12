# 37. PROMPT 12 — Product Normalization Baseline

```text
Pipeline:
Unicode → case → whitespace → punctuation → units → OCR confusables →
alias lookup → candidate generation → scoring.

RapidFuzz — только один сигнал.
Не merge товары с различающимися значимыми brand/size/unit/flavor/fat/pack attributes.

Введи AUTO_ACCEPT / REVIEW / UNRESOLVED.
Калибруй на labeled dataset.
```

### DoD
- auto-accept precision измеряется;
- false merge отдельно измеряется;
- every auto-match explainable;
- low-confidence не merge автоматически.

---
