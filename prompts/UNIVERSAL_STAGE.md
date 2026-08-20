# Универсальный контракт этапа

1. Работай только в Receipt Scanner UA и только в scope текущего prompt.
2. Прочитай project `AGENTS.md`, `docs/AI_STATUS.md`, текущий prompt и непосредственно относящиеся source-of-truth документы.
3. Для R00–R03 используй `docs/UX_FIRST_RECONCILIATION.md`; не загружай весь legacy backlog без необходимости.
4. До реализации существенного поведения проверь SPEC/acceptance criteria. Prompt не заменяет SPEC.
5. Не добавляй agents/hooks/MCP/skills/config до проверки `docs/CONTEXT_COMPATIBILITY.md`.
6. Сохраняй local-first режим, provenance, honest confidence, `Decimal`, adapter boundaries и возможность отключить экспериментальный backend.
7. Не изменяй принятые tests/fixtures/goldens в цикле реализации. Новые contract artifacts проходят отдельную приёмку.
8. После функциональных изменений обязательны unit, integration и component checks. E2E считается закрытым только для живого `client → API/CLI → backend`; иначе `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.
9. Архитектурные решения фиксируй ADR; performance-sensitive изменения — benchmark; retry/fallback/side effects — по fallback policy.
10. Обновляй `AI_STATUS.md` только подтверждённым evidence. Не начинай следующий prompt автоматически.

Запрещено: реальные чеки/секреты в Git, float для денег, скрытие low-confidence normalization, Excel как source of truth, обязательный cloud/account для local core, silent renumbering или удаление legacy prompts.
