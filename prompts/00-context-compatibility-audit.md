# 25. PROMPT 00 — аудит совместимости контекста

```text
Работай в репозитории Receipt Scanner UA.

Сначала НЕ пиши product code.

Проведи Context Compatibility Audit.

1. Найди доступные workspace/project/global AGENTS, .codex, .agents, rules,
   skills, hooks, MCP config, agent TOML и Git workflow.
2. Не загружай весь глобальный архив в parent context.
3. Каждую планируемую локальную automation-сущность классифицируй:
   INHERITED / EXTEND / PROJECT_ONLY / CONFLICT / OBSOLETE.
4. Generic AI Dev Team roles локально не дублируй.
5. Project hooks и MCP по умолчанию не активируй.
6. Создай/обнови docs/CONTEXT_COMPATIBILITY.md.
7. Root AGENTS.md должен содержать только Receipt-specific deltas.
8. Не меняй глобальную AI Dev Team конфигурацию.
9. При конфликте оставляй более сильное/глобальное правило.
10. Дай итоговый список только тех локальных automation-файлов, которые действительно нужны.

Остановись после Stage 00.
```

### DoD
- матрица совместимости создана;
- универсальных дубликатов = 0;
- дублирующих MCP = 0;
- глобальная конфигурация не изменена;
- локальный AGENTS компактный.

---
