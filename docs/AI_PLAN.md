# AI Plan

## Текущая цель

Подтвердить native platform evidence R05: local image intake из photo library без camera capture, preprocessing, OCR или backend уже реализован локально.

## Устойчивая последовательность

1. R00 — UX-first reconciliation — завершён.
2. R01 — project overlay refresh — завершён.
3. R02 — UX MVP specification — завершён.
4. R03 — Flutter fixture-driven native shell — завершён и проверен на Windows validation runner.
5. Functional MVP — R04 local receipt persistence реализован и validated на Windows device integration; Android/iOS runtime `UNVERIFIED`.
6. Production MVP — optional online services и release hardening после доказанного local core.

## Ограничения следующего решения

- Android/iOS остаются product targets; Windows не становится продуктовой платформой.
- Перед production persistence определить canonical data owner и migration boundary.
- Перед real camera/OCR проверить Flutter platform channel/plugin strategy и при необходимости пересмотреть ADR-004.
- Legacy prompts `00–23` применяются только через migration map `docs/UX_FIRST_RECONCILIATION.md`, а не напрямую.
- Product E2E нельзя закрыть без живого пути `client → API/CLI → backend`.

## Первый незавершённый шаг

Получить platform evidence для [R05](../prompts/R05-local-receipt-image-intake.md): повторить Windows integration с полным exit verdict и проверить Android/iOS на подходящем host. Только затем планировать camera capture или preprocessing как отдельный slice.
