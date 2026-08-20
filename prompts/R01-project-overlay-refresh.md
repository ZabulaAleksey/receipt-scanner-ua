# R01 — Обновление КАРКАСА Receipt Scanner UA

Статус: `READY`. Тип: project overlay/documentation. Product code не изменять.

## Цель

После принятого R00 согласовать project-specific документы с UX-first направлением, не копируя глобальные правила ДЕВ.

## Scope

- проверить и точечно обновить `AGENTS.md`, SPEC, `ARCHITECTURE`, `DESIGN`, `SECURITY/PRIVACY`, `ROADMAP`, `DECISIONS`, `AI_STATUS/AI_PLAN`, prompt index и quality gates;
- закрепить границы Receipt Core, OCR adapters, Region Pack, Merchant Adapter, local storage, optional sync, native shell и future B2B;
- различить UX MVP, Functional MVP и Production MVP;
- оставить старые prompts в legacy backlog с новой фазой и зависимостями.

## Ограничения

- не создавать mobile app, OCR implementation или production infrastructure;
- не добавлять project-local agents/hooks/MCP/skills без подтверждённого пробела;
- до Production MVP не добавлять always-on server infrastructure, если этап выполняется local-first или на fixtures.

## DoD

- source-of-truth документы согласованы;
- `CONTEXT_COMPATIBILITY.md` классифицирует изменения;
- старый backlog сохранён;
- следующий этап — `R02`;
- product code/dependencies не изменены.
