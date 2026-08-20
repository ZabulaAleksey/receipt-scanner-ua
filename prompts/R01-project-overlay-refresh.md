# R01 — Обновление КАРКАСА Receipt Scanner UA

Статус: `COMPLETE` (2026-08-20). Тип: project overlay/documentation. Product code не изменён.

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

## Evidence завершения

- добавлены `specs/system.spec.md`, `docs/AI_PLAN.md`, `docs/SECURITY.md`, `docs/PRIVACY.md`;
- `AGENTS.md`, `README.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md` и compatibility matrix согласованы;
- source-of-truth роли и UX/Functional/Production boundaries однозначны;
- документационные ссылки, обязательные artifacts и `git diff --check` проверены;
- все legacy prompts сохранены; product code, dependencies и CI не изменены;
- reviewer подтвердил DoD после устранения замечаний.
