# UX-first reconciliation

Статус: R00 завершён 2026-08-20; миграционная карта принята как вход для R01. Product code не изменён.

## Решение

Новая последовательность: `R00 → R01 → R02 → R03 → Functional MVP backlog → Production MVP backlog`. Старые `00–23` не удаляются, но больше не являются автономной очередью исполнения.

## Матрица старых этапов

| Старые этапы | Решение | Новое место |
|---|---|---|
| 00 | KEEP / REWRITE | Исторический compatibility audit сохранён; R00 заменяет его только для продуктовой reconciliation |
| 01 | MOVE / SPLIT | Foundation после выбора topology; Python core и mobile shell разделить |
| 02 | KEEP / MOVE | Synthetic fixture/privacy baseline уже в R02/R03, расширение в Functional MVP |
| 03–05 | KEEP / MOVE | Functional MVP после UX validation |
| 06–08 | KEEP / REWRITE | Functional MVP; OCR только через provider/adapter boundary |
| 09 | KEEP / REWRITE | Region Pack + Merchant Adapter + штатный Unknown Merchant |
| 10–12 | KEEP / MOVE | Functional MVP; country-neutral core и provenance обязательны |
| 13 | SPLIT | UX review в R02; реальное alias learning — Functional MVP |
| 14 | SPLIT | Fixture price history в UX MVP; persistence — Functional MVP |
| 15–19 | MOVE | После Functional MVP и измеримого baseline |
| 20 | REWRITE / MOVE | Заменён R02/R03; desktop power-review остаётся будущим client mode |
| 21 | MOVE | Research после baseline и ADR/benchmark |
| 22 | SPLIT | Data boundaries сейчас; recovery/privacy/store release — позднее по риску |
| 23 | REWRITE | Acceptance старого CLI milestone, не финальная приёмка продукта |

## Совместимость с правилами

- `AGENTS.md`: local-first, provenance, Decimal, confidence review, adapters и fallback сохраняются.
- ДЕВ/КАРКАС: prompts остаются project-only overlay; глобальные agents/hooks/MCP/skills не копируются.
- SDD: R02 создаёт UX requirements/acceptance criteria до R03 implementation.
- Test contract: принятые tests/fixtures/goldens не переписываются; новые проходят отдельную приёмку.
- E2E: до живого `client → API/CLI → backend` имеет статус `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.
- Git: merge только после явного разрешения.

## Устранённые конфликты

1. Windows/Python — baseline processing core, а не запрет native clients.
2. SQLite — допустимый local canonical store; PostgreSQL/cloud не являются обязательным baseline.
3. PaddleOCR — один adapter implementation, а не зависимость домена.
4. Mobile переносится в UX MVP как fixture-driven shell; real camera/OCR остаётся Functional MVP.
5. Старый Stage 23 становится acceptance CLI/core milestone.

## Пока не реализовывать

Production backend, organization/B2B workflows, billing, обязательный account, real cloud sync, cloud OCR dependency, raw-image cloud retention и окончательный mobile stack без ADR/spike.
