# Receipt Scanner UA — архитектура, АВТОМАТИЗАЦИЯ КОНТЕКСТА и этапы для Codex

**Назначение:** локальная система для обработки фотографий украинских чеков: OCR → парсинг → нормализация товаров → история цен → Excel.<br>
**Режим:** UX-first; Windows/Python processing core; Android/iOS native target; local-first.<br>
**Ключевой принцип:** глобальный Codex router действует как user layer, а проект содержит локальные instructions; formal DEV bridge пока не включён.<br>
**Дата спецификации:** 2026-08-10.

---

## Навигация

Исходная спецификация разделена по назначению, чтобы для одной задачи не загружать весь документ.

- [Архитектура](docs/ARCHITECTURE.md) — продукт, стек, модель данных и pipeline.
- [Автоматизация контекста](docs/CONTEXT_AUTOMATION.md) — наследование правил, локальные deltas и checklist.
- [System specification](specs/system.spec.md) — требования и границы UX/Functional/Production MVP.
- [Roadmap](docs/ROADMAP.md) — UX-first stages и сохранённый legacy backlog.
- [Security](docs/SECURITY.md) и [Privacy](docs/PRIVACY.md) — project-specific data boundaries.
- [STAGES](docs/STAGES.md) — текущий этап, подтверждённое состояние и следующий шаг.
- [Definition of Done](docs/DEFINITION_OF_DONE.md) — общие критерии завершения этапа.
- [Исторические stage contracts](docs/notes/legacy-stage-contracts.md) — прежние R00–R05 и remapped backlog 00–23.

## R05 local image intake

Flutter shell находится в [`mobile/`](mobile/README.md). R04 добавил local-first SQLite v1 для агрегатов чеков, а R05 — выбор одной JPEG/PNG из photo library за port/adapter boundary, bounded local copy и Preview metadata. Synthetic fixtures остаются только для demo/test composition: они не seed'ят пользовательскую БД. Android/iOS остаются product targets, Windows используется только для локальной проверки. Camera capture/OCR/backend всё ещё вне scope.

Базовые проверки выполняются из `mobile/`:

```powershell
flutter analyze --no-pub
flutter test --no-pub test
flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows
flutter test --no-pub integration_test/local_persistence_flow_test.dart -d windows
flutter test --no-pub integration_test/local_image_intake_flow_test.dart -d windows
```

Последняя команда требует Windows Developer Mode для symlink support Flutter plugins. Android/iOS runtime evidence требует соответствующего host.

## Правило загрузки

Для обычной задачи открывайте только `AGENTS.md`, выбранный record в `docs/STAGES.md` и один релевантный документ. Полный архив stage contracts автоматически не загружайте.
