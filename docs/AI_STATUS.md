# AI Status

## Текущий этап

R02 — UX MVP specification завершён локально. Следующий разрешённый этап: R03 — ADR/spike mobile stack и fixture-driven native shell.

## Выполнено

- Проектная спецификация разнесена по тематическим документам и отдельным stage-промптам.
- Все разделы разбивки сохранены в `prompts/01..23`.
- `AGENTS.proposed.md` удалён; теперь единственным активным проектным слоем является `AGENTS.md`.
- Старые prompts `00–23` сохранены как legacy backlog и классифицированы в `docs/UX_FIRST_RECONCILIATION.md`.
- Активная последовательность изменена на `R00 → R01 → R02 → R03 → Functional MVP → Production MVP`.
- UX MVP, native mobile shell, local-first storage, Region Pack и OCR adapter boundaries согласованы в канонических документах.
- Добавлены канонические SPEC, AI plan, security/privacy delta и принятые ADR для UX-first, local-first и provider/regional boundaries.
- Принят детальный UX MVP-контракт для 15 экранов, Quick/Power navigation, lifecycle и cross-screen error policy.
- Зафиксирована матрица из 14 синтетических fixture scenarios и 10 acceptance criteria для R03.

## Известные ограничения

- Прямых project-специфичных agents/hooks/MCP/skills конфигов в репозитории сейчас нет; используются только описания в `docs/CONTEXT_AUTOMATION.md`.
- Product code, dependencies, schemas и CI в R00–R02 не изменялись.
- Реальный путь `client → API/CLI → backend` отсутствует; product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

## Далее

1. Выполнить `prompts/R03-native-mobile-mock-shell.md`.
2. До реализации выбрать KMP/Compose или Flutter через ADR/spike evidence, не расширяя scope до camera/OCR/backend.
