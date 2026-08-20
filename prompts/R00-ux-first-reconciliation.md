# R00 — Согласование старого плана с UX-first направлением

Статус: `READY`. Тип: documentation/reconciliation. Product code не изменять.

## Цель

Сопоставить `prompts/00–23` с направлением `UX MVP → Functional MVP → Production MVP`, не потеряв полезный OCR/parser/normalization backlog.

## Входной контекст

- `AGENTS.md`, `docs/AI_STATUS.md`, `docs/CONTEXT_COMPATIBILITY.md`;
- `docs/DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`;
- `prompts/README.md`, `prompts/UNIVERSAL_STAGE.md`;
- `docs/UX_FIRST_RECONCILIATION.md` как исходная матрица, если документ уже существует.

## Требования

1. Считать UX-first приоритетным продуктовым направлением.
2. Сохранить старые prompts как legacy backlog; не выполнять `01–23` напрямую до назначения им новой фазы и зависимостей.
3. Зафиксировать Quick UX и Power UX.
4. Сохранить local-first/offline core, provenance, confidence review, aliases, regional packs и unknown merchant path.
5. Native mobile означает Android/iOS targets, не PWA. KMP/Compose и Flutter остаются кандидатами до ADR/spike.
6. OCR implementations подключаются через adapter boundary; один SDK не становится доменной зависимостью.
7. B2B, cloud, billing и account system не входят в consumer UX MVP.
8. Не менять product code, schemas, dependencies, CI или infrastructure.

## DoD

- актуальна матрица `KEEP / MOVE / SPLIT / REWRITE / OBSOLETE`;
- `prompts/00–23` сохранены;
- UX MVP стоит перед DB/OCR/backend implementation;
- следующий этап однозначно `R01`;
- product code и зависимости не изменены.
