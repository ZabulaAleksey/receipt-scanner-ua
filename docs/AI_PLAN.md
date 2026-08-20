# AI Plan

## Текущая цель

Выполнить R03: выбрать native-mobile stack через ADR/spike и реализовать fixture-driven shell по принятому UX-контракту R02.

## Устойчивая последовательность

1. R02 — UX MVP specification, state map, synthetic fixture matrix и acceptance criteria — завершён.
2. R03 — ADR/spike mobile stack и fixture-driven native shell — следующий.
3. Functional MVP — real local data/camera/OCR/parser/normalization/review.
4. Production MVP — optional online services и release hardening.

## Зависимости

- R02 начинается только после DoD и review R01.
- R03 опирается на принятые `specs/features/ux-mvp.spec.md`, `docs/UX_STATE_MAP.md` и `docs/UX_FIXTURE_MATRIX.md`.
- Выбор KMP/Compose или Flutter запрещён без R03 ADR/spike evidence.
- Legacy prompts `00–23` используются через migration map `docs/UX_FIRST_RECONCILIATION.md`.

## Первый незавершённый шаг

Выполнить `prompts/R03-native-mobile-mock-shell.md`.
