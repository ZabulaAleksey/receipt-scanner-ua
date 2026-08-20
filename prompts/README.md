# Промпты этапов Receipt Scanner UA

Каноническое направление: **UX MVP → Functional MVP → Production MVP**. Открывай только текущий prompt и `UNIVERSAL_STAGE.md`.

## Активная последовательность

1. [R00 — UX-first reconciliation](R00-ux-first-reconciliation.md) — `COMPLETE`.
2. [R01 — project overlay refresh](R01-project-overlay-refresh.md) — `READY`, текущий этап.
3. [R02 — UX MVP specification](R02-ux-mvp-specification.md) — после R01.
4. [R03 — native mobile mock shell](R03-native-mobile-mock-shell.md) — после R02.

Не переходи к следующему этапу только потому, что предыдущий файл существует: нужны выполненный DoD, verification evidence и обновлённый `AI_STATUS.md`.

## Legacy backlog 00–23

Старые prompts сохранены как технический backlog. Их классификация и новые зависимости находятся в [UX_FIRST_RECONCILIATION.md](../docs/UX_FIRST_RECONCILIATION.md). До завершения R00/R01 их нельзя выполнять напрямую по старой нумерации.

- 00 — исторический context audit, superseded by R00 для продуктовой reconciliation;
- 01–19 — преимущественно Functional MVP и post-baseline backlog;
- 20 — superseded by R02/R03, но desktop power-review требования сохраняются;
- 21 — research после измеримого baseline;
- 22 — ранние data boundaries и поздний production hardening;
- 23 — acceptance CLI/core milestone, не финал всего продукта.

Исходные файлы `00-context-compatibility-audit.md` … `23-packaging-final-acceptance.md` не удалены и не считаются автоматически одобренными к исполнению.
