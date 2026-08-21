# Receipt Scanner UA — архитектура, АВТОМАТИЗАЦИЯ КОНТЕКСТА и промпты для Codex

**Назначение:** локальная система для обработки фотографий украинских чеков: OCR → парсинг → нормализация товаров → история цен → Excel.<br>
**Режим:** UX-first; Windows/Python processing core; Android/iOS native target; local-first.<br>
**Ключевой принцип:** проект наследует уже установленную **AI Dev Team / «АВТОМАТИЗАЦИЮ КОНТЕКСТА»** и содержит только локальные project-specific deltas.<br>
**Дата спецификации:** 2026-08-10.

---

## Навигация

Исходная спецификация разделена по назначению, чтобы для одной задачи не загружать весь документ.

- [Архитектура](docs/ARCHITECTURE.md) — продукт, стек, модель данных и pipeline.
- [Автоматизация контекста](docs/CONTEXT_AUTOMATION.md) — наследование правил, локальные deltas и checklist.
- [System specification](specs/system.spec.md) — требования и границы UX/Functional/Production MVP.
- [Roadmap](docs/ROADMAP.md) — UX-first stages и сохранённый legacy backlog.
- [Security](docs/SECURITY.md) и [Privacy](docs/PRIVACY.md) — project-specific data boundaries.
- [AI Plan](docs/AI_PLAN.md) и [AI Status](docs/AI_STATUS.md) — следующий шаг и подтверждённое состояние.
- [Definition of Done](docs/DEFINITION_OF_DONE.md) — общие критерии завершения этапа.
- [Stage-промпты](prompts/README.md) — активная цепочка R00–R04 и legacy backlog 00–23.

## R04 local persistence

Flutter shell находится в [`mobile/`](mobile/README.md). R04 добавляет local-first SQLite v1 для агрегатов чеков и async loading/empty/local-error/retry lifecycle. Synthetic fixtures остаются только для demo/test composition: они не seed'ят пользовательскую БД. Android/iOS остаются product targets, Windows используется только для локальной проверки. Real camera/OCR/backend всё ещё вне scope.

Базовые проверки выполняются из `mobile/`:

```powershell
flutter analyze --no-pub
flutter test --no-pub test
flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows
flutter test --no-pub integration_test/local_persistence_flow_test.dart -d windows
```

Последняя команда требует Windows Developer Mode для symlink support Flutter plugins. Android/iOS runtime evidence требует соответствующего host.

## Правило загрузки

Для обычной задачи открывайте только `AGENTS.md`, текущий раздел `docs/AI_STATUS.md`, один релевантный документ и один stage-промпт. Полный набор промптов автоматически не загружайте.
