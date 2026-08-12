# 34. PROMPT 09 — определение магазина и framework адаптеров

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
- тесты определения существуют;
- ambiguous case не скрывается.

---
