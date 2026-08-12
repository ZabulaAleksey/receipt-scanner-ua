# 39. PROMPT 14 — Price History Persistence

```text
Сформируй canonical PriceObservation/PurchaseItem history.

Храни receipt, shop, purchased_at, canonical product,
raw item, quantity, unit, unit_price, total, discount.

Добавь queries:
latest price; history by product; history by shop.
```

### DoD
- цены по разным датам не перезаписываются;
- manual corrections отражаются;
- история трассируется до чека.

---
