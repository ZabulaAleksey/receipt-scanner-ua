# AI Plan

## Текущая цель

Закрыть platform evidence R04, затем выбрать следующий ограниченный Functional MVP slice без смешивания camera, OCR и backend.

## Устойчивая последовательность

1. R00 — UX-first reconciliation — завершён.
2. R01 — project overlay refresh — завершён.
3. R02 — UX MVP specification — завершён.
4. R03 — Flutter fixture-driven native shell — завершён и проверен на Windows validation runner.
5. Functional MVP — R04 local receipt persistence реализован и локально validated; Windows device integration blocked by Developer Mode, Android/iOS runtime `UNVERIFIED`.
6. Production MVP — optional online services и release hardening после доказанного local core.

## Ограничения следующего решения

- Android/iOS остаются product targets; Windows не становится продуктовой платформой.
- Перед production persistence определить canonical data owner и migration boundary.
- Перед real camera/OCR проверить Flutter platform channel/plugin strategy и при необходимости пересмотреть ADR-004.
- Legacy prompts `00–23` применяются только через migration map `docs/UX_FIRST_RECONCILIATION.md`, а не напрямую.
- Product E2E нельзя закрыть без живого пути `client → API/CLI → backend`.

## Первый незавершённый шаг

Получить platform evidence для [R04](../prompts/R04-local-receipt-persistence.md): включить Windows Developer Mode для Flutter plugin symlinks либо проверить Android/iOS на подходящем host. Только затем спланировать следующий отдельный Functional MVP slice.
