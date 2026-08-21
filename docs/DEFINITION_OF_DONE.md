# 23. Общие критерии готовности

Любой этап завершён, если:

- scope выполнен;
- smoke test проходит;
- unit tests проходят;
- нужные integration tests проходят;
- acceptance/golden fixture добавлен при изменении поведения;
- regression dataset не ухудшен без ADR;
- `AI_STATUS.md` обновлён при изменении подтверждённого состояния;
- `AI_PLAN.md` обновлён при изменении следующего шага;
- `DECISIONS.md` обновлён при архитектурном решении;
- `ARCHITECTURE.md` обновлён при изменении boundaries;
- `DESIGN.md` обновлён при UI change;
- performance-sensitive изменение имеет benchmark;
- experimental feature имеет flag + fallback;
- raw receipts/secrets не попали в Git;
- reviewer не нашёл blocking problems;
- global AI Dev Team automation не продублирована.

---
