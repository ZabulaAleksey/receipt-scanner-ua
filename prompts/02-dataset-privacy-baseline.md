# 27. PROMPT 02 — Dataset + Privacy Baseline

```text
Сделай dataset-first основу.

Создай fixtures/synthetic, fixtures/anonymized, fixtures/expected.
Создай manifest: fixture id, shop, languages, difficulty, expected fields.
Реальные чеки держи только в data/raw и gitignore.

Нужные cases:
ATB-like, Silpo-like, generic, blur, perspective, shadow,
long-name wrap, weight item, discount, mixed Ukrainian/Russian.

Добавь privacy scanner для tracked fixtures.
Не регистрируй его как hook, если inherited DLP уже покрывает проверку.
```

### DoD
- fixture schema versioned;
- no real PII tracked;
- expected outputs есть;
- privacy check проходит.

---
