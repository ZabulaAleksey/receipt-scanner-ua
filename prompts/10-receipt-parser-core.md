# 35. PROMPT 10 — Receipt Parser Core

```text
Реализуй LogicalLine classification и item extraction.

Поддержи:
header, date/time, item, wrapped item, quantity/weight,
unit price, line total, discount, subtotal, total, payment,
fiscal/footer, unknown.

Unknown lines сохраняй.
Parser result = values + confidence + evidence.
```

### DoD
- baseline fixtures извлекают items;
- raw names не теряются;
- regression tests есть.

---
