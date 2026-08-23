# Receipt Scanner UA — локальные инструкции

Перед началом работы прочитай `~/.codex/AGENTS.md`. Этот проект содержит только дополнения, относящиеся к обработке чеков.

## Инварианты проекта

- Приоритетная продуктовая последовательность: `UX MVP → Functional MVP → Production MVP`; актуальный порядок этапов находится в `prompts/README.md`.
- Windows/Python остаётся baseline для processing core и CLI, но не запрещает отдельные Android/iOS native app targets. Mobile stack выбирается только через ADR/spike.
- Consumer core обязан работать local-first/offline без обязательного account, cloud OCR и server storage.
- OCR SDK подключается через adapter boundary; Receipt Scanner не должен зависеть от одного provider. Text Recognition Core является предпочтительной интеграционной границей, если его контракт подходит.
- Украина является первым Region Pack. Merchant-specific behavior остаётся за adapters, а неизвестный merchant проходит generic path.
- До Production MVP запрещено добавлять постоянно работающую серверную инфраструктуру только ради будущей синхронизации, если текущий stage выполняется local-first или на mock/fixture data.

- Baseline processing core/CLI работает на Windows и Python; native clients имеют отдельные targets. Обработка по умолчанию локальная; исходные чеки и секреты никогда не добавляются в коммиты.
- База данных является каноническим состоянием; Excel используется для экспорта.
- Сохраняй исходный результат OCR и его происхождение. Результаты с низкой уверенностью требуют проверки.
- Для денежных значений используй `Decimal`, а объединение товаров делай объяснимым.
- Сохраняй путь OCR на CPU, а для экспериментальной технологии требуй flag, fallback и benchmark.
- Специфичное для продавца поведение размещай за адаптерами.

## Маршрутизация контекста

- Начинай с `docs/AI_STATUS.md`, затем открывай один относящийся к задаче документ по архитектуре, модели данных, OCR, нормализации или качеству.
- При работе над этапом используй только текущий prompt этапа из `prompts/`.
- Не загружай одновременно полную дорожную карту, коллекцию prompts, fixtures, дерево правил, набор SPEC и `LEARNING_LOG.md`.

## Канонические источники

- product requirements: `specs/system.spec.md`;
- UX/visual requirements: `docs/DESIGN.md`;
- system boundaries: `docs/ARCHITECTURE.md`;
- security/privacy delta: `docs/SECURITY.md`, `docs/PRIVACY.md`;
- stages: `docs/ROADMAP.md`, `prompts/README.md`;
- current evidence/next work: `docs/AI_STATUS.md`, `docs/AI_PLAN.md`;
- architectural decisions: `docs/DECISIONS.md`.


## Локальные правила тестирования

### Тестовый контракт
- После принятия тестов/fixtures/golden-сценариев они считаются контрактом и не редактируются в этом же цикле генерации.
- Тесты, добавленные по новым требованиям, проходят отдельный review перед слиянием.

### Unit / integration / component
- Flutter mobile shell имеет unit, widget/component, accessibility, state, golden и offline integration tests.
- Из `mobile/` используй `flutter analyze --no-pub`, `flutter test --no-pub test` и доступный platform integration runner.
- Python processing core ещё не реализован; после его появления минимум включает `python -m pytest` и отдельные тесты OCR/normalization pipeline.

### E2E (критические)
1. Импорт чека/чеков → OCR → структурированный результат.
2. Проверка корректности арифметики и reconciliation.
3. Экспорт результата (Excel/JSON) без потери данных.

- Пока нет стабильно работающего backend/API и UI-стендов: `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.
