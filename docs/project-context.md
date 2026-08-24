# Контекст проекта Receipt Scanner UA

## Назначение

Receipt Scanner UA — local-first мобильное приложение для безопасного импорта украинских чеков, последующего OCR/parsing, ручной проверки и локальной истории цен. Текущий продуктовый shell реализован на Flutter; Android и iOS являются целевыми платформами, Windows используется как доступная среда детерминированной проверки.

## Архитектурные границы

- widgets/routes зависят от application controller и ports, но не вызывают SQLite, picker, OCR или filesystem напрямую;
- domain aggregates, persistence DTO/schema, image assets и fixture/demo data остаются раздельными;
- пользовательские изображения и чеки считаются недоверенными и приватными;
- offline/local-first — базовый режим; backend, sync и cloud fallback не подразумеваются;
- денежные значения хранятся без потери точности, а schema evolution выполняется только через явные миграции.

## Подтверждённое состояние

R00–R03 сформировали UX-first контракт и Flutter shell. В основном checkout присутствует незавершённый пользовательский merge с локально реализованными R04 (SQLite persistence) и R05 (gallery image intake); его `MERGE_HEAD`, index и рабочие файлы сохранены миграцией без разрешения конфликта. Native Android/iOS runtime остаётся `UNVERIFIED`. Подробные этапы, включая R04/R05 и backlog 00–23, консолидированы в `prompts/STAGES.md`.

## Источники истины

- `docs/ARCHITECTURE.md` — границы приложения и адаптеров;
- `docs/DESIGN.md` — каноническая адаптация UX/visual contract; `docs/CALM_BLUE_UI.md` — принадлежащий проекту подробный design-system baseline;
- `docs/SECURITY.md` и `docs/PRIVACY.md` — обработка чеков, изображений и логов;
- `docs/DECISIONS.md` — ADR;
- `docs/ROADMAP.md`, `docs/AI_PLAN.md`, `docs/AI_STATUS.md` — последовательность и evidence;
- `prompts/STAGES.md` — единственный подробный исполняемый источник этапов.

## Gates

Из каталога `mobile/`: formatting, `flutter analyze --no-pub`, `flutter test --no-pub test` и только доступные platform integration checks. Недоступная native-проверка маркируется `UNVERIFIED`, а не `PASS`.
