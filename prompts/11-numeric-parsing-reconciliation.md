# 36. PROMPT 11 — Numeric Parsing + Reconciliation

```text
Поддержи decimal comma/dot, spaces, multiplication notation,
weight quantities и discounts.
Используй Decimal.

Проверяй:
qty * unit_price ≈ line_total;
sum(items) - discounts ≈ receipt total.

Mismatch создаёт quality issue, а не silent rewrite.
```

### DoD
- property tests;
- rounding edge cases;
- configurable tolerance;
- provenance automatic corrections.

---
