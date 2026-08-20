# AI Plan

## Текущая цель

Подготовить первый ограниченный этап Functional MVP поверх проверенного R03 shell, не смешивая local persistence, real camera, OCR и backend в один scope.

## Устойчивая последовательность

1. R00 — UX-first reconciliation — завершён.
2. R01 — project overlay refresh — завершён.
3. R02 — UX MVP specification — завершён.
4. R03 — Flutter fixture-driven native shell — завершён и проверен на Windows validation runner.
5. Functional MVP — планирование: выбрать первый вертикальный slice и зафиксировать SPEC/prompt.
6. Production MVP — optional online services и release hardening после доказанного local core.

## Ограничения следующего решения

- Android/iOS остаются product targets; Windows не становится продуктовой платформой.
- Перед production persistence определить canonical data owner и migration boundary.
- Перед real camera/OCR проверить Flutter platform channel/plugin strategy и при необходимости пересмотреть ADR-004.
- Legacy prompts `00–23` применяются только через migration map `docs/UX_FIRST_RECONCILIATION.md`, а не напрямую.
- Product E2E нельзя закрыть без живого пути `client → API/CLI → backend`.

## Первый незавершённый шаг

Создать отдельный план/SPEC для одного Functional MVP slice. Предпочтительный кандидат: локальное сохранение и чтение Receipt aggregates за `ReceiptRepository`, без одновременного подключения camera/OCR/backend.
