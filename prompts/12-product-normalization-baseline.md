# 37. PROMPT 12 — базовая нормализация товаров

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
- точность автоматического принятия измеряется;
- false merge отдельно измеряется;
- каждое автоматическое совпадение объяснимо;
- low-confidence не merge автоматически.

---
