# 39. PROMPT 14 — сохранение истории цен

```text
Сформируй canonical PriceObservation/PurchaseItem history.

Храни receipt, shop, purchased_at, canonical product,
raw item, quantity, unit, unit_price, total, discount.

Добавь queries:
latest price; history by product; history by shop.
```

### DoD
- цены по разным датам не перезаписываются;
- ручные исправления отражаются;
- история трассируется до чека.

---
