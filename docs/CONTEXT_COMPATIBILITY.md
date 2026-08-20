# Контекстная совместимость (жёсткая проверка)

Статус: Stage 00 и R00 пройдены; UX-first prompt roadmap совместим с каскадом правил.

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
