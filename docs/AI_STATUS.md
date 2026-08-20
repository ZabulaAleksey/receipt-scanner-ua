# AI Status

## Текущий этап

R01 — обновление project overlay/КАРКАСА завершён локально и проверен. Следующий разрешённый этап: R02 — UX MVP specification и state map без реализации приложения.

## Выполнено

- Проектная спецификация разнесена по тематическим документам и отдельным stage-промптам.
- Все разделы разбивки сохранены в `prompts/01..23`.
- `AGENTS.proposed.md` удалён; теперь единственным активным проектным слоем является `AGENTS.md`.
- Старые prompts `00–23` сохранены как legacy backlog и классифицированы в `docs/UX_FIRST_RECONCILIATION.md`.
- Активная последовательность изменена на `R00 → R01 → R02 → R03 → Functional MVP → Production MVP`.
- UX MVP, native mobile shell, local-first storage, Region Pack и OCR adapter boundaries согласованы в канонических документах.
- Добавлены канонические SPEC, AI plan, security/privacy delta и принятые ADR для UX-first, local-first и provider/regional boundaries.

## Известные ограничения

- Прямых project-специфичных agents/hooks/MCP/skills конфигов в репозитории сейчас нет; используются только описания в `docs/CONTEXT_AUTOMATION.md`.
- Product code, dependencies, schemas и CI в R00/R01 не изменялись.

## Далее

1. Выполнить `prompts/R02-ux-mvp-specification.md`.
2. Не начинать R03 до принятой UX state map, fixture matrix и acceptance criteria R02.
