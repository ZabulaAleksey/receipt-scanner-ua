# Контекстная совместимость (жёсткая проверка)

Исторический R00–R03 local overlay прошёл проверки; formal DEV bridge
отсутствует и текущая state-location migration описана ниже отдельно.

## Maintenance — консолидация статуса

| Изменение | Класс | Вывод |
|---|---|---|
| Удаление `docs/PROGRESS.md` | OBSOLETE | На момент maintenance файл дублировал отдельные AI status/plan; их live роль затем заменена ADR-007 |
| Рабочие ссылки на статус | EXTEND | `docs/STAGES.md` — единый owner status/evidence/NEXT после ADR-007 |
| Локальные команды Flutter tests в `AGENTS.md` | EXTEND | Устаревшее утверждение об отсутствии автотестов синхронизировано с фактическим R03 toolchain |

Удаление не меняет product requirements, roadmap или test contracts. Git history сохраняет историческое содержимое `PROGRESS.md`.

## R03 — Flutter fixture-driven mobile shell

| Изменение | Класс | Вывод |
|---|---|---|
| `mobile/` Flutter package | PROJECT_ONLY | Receipt-specific UX prototype; не копирует глобальную AI Dev Team automation |
| ADR-004 Flutter и platform boundary | EXTEND | Конкретизирует mobile architecture и fallback до Functional MVP |
| Unit/component/accessibility/golden/integration проверки | INHERITED | Глобальный test contract сохранён; принятые R02 fixtures не изменены |
| Windows validation runner | PROJECT_ONLY | Инструмент проверки, не новая product platform |
| Новые agents/hooks/MCP/skills/config | OBSOLETE | Подтверждённого пробела нет; ничего не добавлено |

R03 не конфликтует с ДЕВ: UI изолирован за ports/use cases, scope не расширен до production integrations, Android/iOS limitations отмечены честно, а product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

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
| `docs/STAGES.md`, актуализация status/progress | PROJECT_ONLY | Локальная маршрутизация одного этапа и evidence после ADR-007 |
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

Конфликтов после reconciliation не осталось. R02 создал requirements/acceptance criteria до R03 implementation. Старые prompts и принятые test artifacts не удалены.

- Базовая проверка: global context (`~/.codex/AGENTS.md`) + project overlay (`AGENTS.md`).
- `AGENTS.proposed.md` отсутствует как активный слой.
- Автоматизация, hooks/MCP/skills/config/workflow в проекте не дублируются.

## Матрица локальной классификации (INHERITED / EXTEND / PROJECT_ONLY / CONFLICT / OBSOLETE)

| Компонент | Слой | Класс | Обоснование |
|---|---|---|---|
| Preset | workspace/presets | INHERITED | Для `receipt-scanner-ua` не используется отдельный preset (директория `projects/receipt-scanner-ua` не подключена к preset).
| `AGENTS.md` (global) | root/global | INHERITED | Базовые правила из `~/.codex/AGENTS.md`.
| `AGENTS.md` (project) | project | EXTEND | Проектный overlay с локальными ограничениями и правилами.
| `docs/STAGES.md` | project | PROJECT_ONLY | Единый выбранный этап, статус, evidence и NEXT.
| `docs/CONTEXT_COMPATIBILITY.md` | project | PROJECT_ONLY | Локальный аудит совместимости и delta-решений.
| `docs/CONTEXT_AUTOMATION.md` | project | PROJECT_ONLY | Локальные процессные правила проектной автоматизации.
| `README.md` | project | PROJECT_ONLY | Оперируемый индекс и структура проекта.
| `docs/notes/legacy-stage-contracts.md` | project | HISTORICAL | Старые stage contracts без live status authority.
| agents/hooks/MCP/skills (локальные файлы) | project | OBSOLETE | Локальный слой не нужен: подтверждённого пробела нет, файлы отсутствуют. |
| hooks (активные) | project | OBSOLETE | Проектные hooks не требуются; активных hook-файлов нет.
| MCP | project | OBSOLETE | Проектный MCP не требуется; локальных конфигов нет.
| skills | project | OBSOLETE | Проектные skills не требуются; локальных manifest/файлов нет.
| потенциальные дубли | all | OBSOLETE | Активных дублей `agent/hook/MCP/skills` не найдено; отдельная параллельная конфигурация не нужна.

## Служебное замечание


- Нулевой проектный конфиг/папки по `agents/`, `hooks/`, `mcp/`, `config/`, `*.toml` в самом репозитории.
- Исторические упоминания прошлого `AGENTS.proposed.md` оставлены только как лог/контекст, но не как активный артефакт.

## Brownfield state-location migration

Read-only `reconcile_project_framework.py` повторён на GitHub `main`
`f706261` в clean isolated clone. `prompts/STAGES.md`, AI_PLAN и
AI_STATUS классифицированы `MERGE`; `docs/STAGES.md` — `ADD`.
Flutter mobile code/tests, assets, `pubspec.lock`, platform manifests,
fixtures и runtime receipt data защищены как `FORBIDDEN_TO_OVERWRITE`.
Source SHA256/rollback parent сохранены в
`docs/notes/legacy-ai-state-evidence.md`.

CONFLICT: AI_STATUS описывал R05 в рабочей ветке и одновременно
`docs/project-context.md` называл его интегрированным. Product commit
`79e77ca` и merge `02b08d4` — ancestors of GitHub main, поэтому
код интегрирован; Windows image-intake exit verdict и Android/iOS
runtime всё ещё отсутствуют. Selected R05 — `implemented_unverified`;
NEXT `R05-PLATFORM-EVIDENCE`, без camera/OCR completion claim.

Flutter/Dart executable на этом Windows host не найден в PATH и
проверенных стандартных SDK locations. New Flutter restore/tests не
заявлены. Structural stage adapter и Markdown/path checks повторяются
после migration. Formal `.codex/dev-project.toml` отсутствует;
путь STAGES не включает full DEV inheritance сам по себе.
