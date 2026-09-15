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

R00–R03 сформировали UX-first контракт и Flutter shell. R04 (SQLite persistence), R05 (gallery image intake) и governance migration объединены в `main`; native Android/iOS runtime остаётся `UNVERIFIED`. Выбранный R05 и evidence ведутся в `docs/STAGES.md`; прежние подробные R00–R05/00–23 contracts сохранены в `docs/notes/legacy-stage-contracts.md`.

## Источники истины

- `docs/ARCHITECTURE.md` — границы приложения и адаптеров;
- `docs/DESIGN.md` — каноническая адаптация UX/visual contract; `docs/CALM_BLUE_UI.md` — принадлежащий проекту подробный design-system baseline;
- `docs/SECURITY.md` и `docs/PRIVACY.md` — обработка чеков, изображений и логов;
- `docs/DECISIONS.md` — ADR;
- `docs/ROADMAP.md` — последовательность; `docs/STAGES.md` — один текущий stage/evidence/NEXT;
- `docs/notes/legacy-stage-contracts.md` — historical contract reference без live status authority.

## Gates

Из каталога `mobile/`: formatting, `flutter analyze --no-pub`, `flutter test --no-pub test` и только доступные platform integration checks. Недоступная native-проверка маркируется `UNVERIFIED`, а не `PASS`.
