# 34. PROMPT 09 — Store Detection + Adapter Framework

```text
Создай StoreAdapter protocol и StoreDetector.

Baseline adapters:
ATB, Silpo, VARUS, NOVUS, Fora, Generic.

Detection возвращает score + evidence.
Не копируй core parser в каждый adapter.
Ambiguous shop → Generic/review warning.
```

### DoD
- новый магазин можно добавить отдельным adapter;
- detection tests есть;
- ambiguous case не скрывается.

---
