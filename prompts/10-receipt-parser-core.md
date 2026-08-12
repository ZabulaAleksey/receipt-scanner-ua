# 35. PROMPT 10 — core parser чеков

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
- базовые fixtures извлекают товары;
- raw names не теряются;
- регрессионные тесты существуют.

---
