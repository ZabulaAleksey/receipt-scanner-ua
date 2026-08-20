# AI Plan

## Текущая цель

Выполнить R02: создать UX MVP specification, state map, synthetic fixture matrix и acceptance criteria без реализации приложения.

## Устойчивая последовательность

1. R02 — UX MVP specification, state map, synthetic fixture matrix и acceptance criteria.
2. R03 — ADR/spike mobile stack и fixture-driven native shell.
4. Functional MVP — real local data/camera/OCR/parser/normalization/review.
5. Production MVP — optional online services и release hardening.

## Зависимости

- R02 начинается только после DoD и review R01.
- R03 начинается только после принятой UX specification R02.
- Выбор KMP/Compose или Flutter запрещён без R03 ADR/spike evidence.
- Legacy prompts `00–23` используются через migration map `docs/UX_FIRST_RECONCILIATION.md`.

## Первый незавершённый шаг

Выполнить `prompts/R02-ux-mvp-specification.md`.
