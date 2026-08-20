# Контекстная совместимость (жёсткая проверка)

Статус: Stage 00, R00–R02 пройдены; project overlay совместим с каскадом правил.

## R02 — UX MVP specification

| Изменение | Класс | Вывод |
|---|---|---|
| `specs/features/ux-mvp.spec.md` | PROJECT_ONLY | Receipt-specific UX contract, уточняющий system spec без дублирования глобального ДЕВ |
| `docs/UX_STATE_MAP.md`, `docs/UX_FIXTURE_MATRIX.md` | PROJECT_ONLY | Проектные navigation/lifecycle и synthetic fixture contracts для R03 |
| Синхронизация prompt/status/index документов | PROJECT_ONLY | Производные статусы приведены к фактическому состоянию R02 |
| Новые agents/hooks/MCP/skills/config | OBSOLETE | Для specification-stage подтверждённого пробела нет; ничего не добавлено |

R02 не изменяет глобальные test/fallback policies: принятые fixtures остаются контрактом, а E2E без живого backend отмечается `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

## R01 — project overlay refresh

| Изменение | Класс | Вывод |
|---|---|---|
| `specs/system.spec.md`, `specs/README.md` | PROJECT_ONLY | Канонические Receipt-specific product requirements |
| `docs/SECURITY.md`, `docs/PRIVACY.md` | EXTEND | Project delta поверх глобальных security/fallback policies |
| `docs/AI_PLAN.md`, актуализация status/progress | PROJECT_ONLY | Локальная маршрутизация следующего этапа и evidence |
| ADR-001..003, architecture/design/roadmap updates | PROJECT_ONLY | Receipt-specific boundaries и решения |
| Canonical source list и anti-overengineering в `AGENTS.md` | EXTEND | Уточнение локального overlay без копирования ДЕВ |
| Удаление `AGENTS.proposed.md` | OBSOLETE | Дублирующий proposal заменён активным project `AGENTS.md` |
| Новые local agents/hooks/MCP/skills | OBSOLETE | Подтверждённого пробела нет; не добавлены |

## R00 — UX-first reconciliation

| Изменение | Класс | Вывод |
|---|---|---|
| R00–R03 и prompt index | PROJECT_ONLY | Receipt-specific workflow, не копия глобального ДЕВ |
| UX-first invariants в `AGENTS.md` | EXTEND | Уточняют platform/product boundaries проекта |
| Test contract и E2E blocked marker | INHERITED | Глобальная policy сохранена без ослабления |
| OCR/mobile/cloud adapter boundaries | EXTEND | Проектная конкретизация architecture/fallback rules |
| Новые agents/hooks/MCP/skills | OBSOLETE | Для R00 не требуются и не добавлены |

Конфликтов после reconciliation не осталось. R02 обязан создать requirements/acceptance criteria до R03 implementation. Старые prompts и принятые test artifacts не удалены.

- Базовая проверка: workspace/root context (`~/codex-workspace/AGENTS.md`) + project overlay (`AGENTS.md`).
- `AGENTS.proposed.md` отсутствует как активный слой.
- Автоматизация, hooks/MCP/skills/config/workflow в проекте не дублируются.

## Матрица локальной классификации (INHERITED / EXTEND / PROJECT_ONLY / CONFLICT / OBSOLETE)

| Компонент | Слой | Класс | Обоснование |
|---|---|---|---|
| Preset | workspace/presets | INHERITED | Для `receipt-scanner-ua` не используется отдельный preset (директория `projects/receipt-scanner-ua` не подключена к preset).
| `AGENTS.md` (workspace) | root/global | INHERITED | Базовые правила из `~/codex-workspace/AGENTS.md`.
| `AGENTS.md` (project) | project | EXTEND | Проектный overlay с локальными ограничениями и правилами.
| `docs/AI_STATUS.md` | project | PROJECT_ONLY | Описание текущего статуса проекта.
| `docs/CONTEXT_COMPATIBILITY.md` | project | PROJECT_ONLY | Локальный аудит совместимости и delta-решений.
| `docs/CONTEXT_AUTOMATION.md` | project | PROJECT_ONLY | Локальные процессные правила проектной автоматизации.
| `README.md` | project | PROJECT_ONLY | Оперируемый индекс и структура проекта.
| `prompts/*` | project | PROJECT_ONLY | Stage-подсказки и чеклисты на уровне проекта.
| agents/hooks/MCP/skills (локальные файлы) | project | OBSOLETE | Локальный слой не нужен: подтверждённого пробела нет, файлы отсутствуют. |
| hooks (активные) | project | OBSOLETE | Проектные hooks не требуются; активных hook-файлов нет.
| MCP | project | OBSOLETE | Проектный MCP не требуется; локальных конфигов нет.
| skills | project | OBSOLETE | Проектные skills не требуются; локальных manifest/файлов нет.
| потенциальные дубли | all | OBSOLETE | Активных дублей `agent/hook/MCP/skills` не найдено; отдельная параллельная конфигурация не нужна.

## Служебное замечание


- Нулевой проектный конфиг/папки по `agents/`, `hooks/`, `mcp/`, `config/`, `*.toml` в самом репозитории.
- Исторические упоминания прошлого `AGENTS.proposed.md` оставлены только как лог/контекст, но не как активный артефакт.
