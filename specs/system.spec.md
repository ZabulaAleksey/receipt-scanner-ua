# Receipt Scanner UA — system specification

Статус: канонический baseline требований после R02. Детальный UX MVP-контракт находится в [`features/ux-mvp.spec.md`](features/ux-mvp.spec.md).

## Цель продукта

Помочь пользователю локально собирать чеки, проверять качество распознавания, нормализовать товары и продавцов, видеть историю покупок/цен и экспортировать структурированные данные, сохраняя provenance и контроль над приватными данными.

## Фазы

1. UX MVP — fixture-driven native-mobile-looking приложение без production camera/OCR/backend.
2. Functional MVP — реальная camera/import, local database, OCR adapters, parsing, normalization, review и offline history.
3. Production MVP — необязательные account/sync/backup/subscription, privacy/store readiness и operational hardening.

## Обязательные требования

- Quick UX и Power UX используют одну доменную модель.
- Consumer core работает offline и без account, server storage или cloud OCR.
- Android/iOS являются целевыми native app targets; окончательный stack выбирается ADR/spike.
- Украина — первый Region Pack; core не зашивает country/merchant assumptions.
- Неизвестный merchant и non-grocery receipt являются штатными сценариями.
- Raw evidence, OCR output, parsed candidates, corrections и normalized entities остаются различимыми и трассируемыми.
- Low-confidence и арифметические несоответствия требуют review; они не маскируются success-состоянием.
- Деньги хранятся fixed precision/Decimal.
- OCR и storage/sync implementations подключаются через ports/adapters и имеют явную fallback policy.
- B2B остаётся отдельной будущей веткой и не создаёт зависимостей consumer MVP.

## Privacy и безопасность

- Исходные изображения считаются чувствительными пользовательскими данными и по умолчанию остаются локально.
- Реальные чеки, PII и secrets не попадают в Git, fixtures — синтетические либо подтверждённо анонимизированные.
- Cloud processing, image backup и model-training opt-in являются отдельными решениями пользователя.
- Недоверенные изображения и импортируемые данные проходят type/size/resource validation.

## Тестовый контракт

- Принятые tests/fixtures/goldens не меняются в цикле реализации.
- Для функциональных изменений обязательны unit, integration и component checks.
- E2E закрывается только живым путём `client → API/CLI → backend`; до него статус `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.

## Non-goals до Production MVP

Always-on infrastructure, обязательный account, mandatory cloud OCR, enterprise organization model, billing implementation и постоянное хранение raw receipt images на сервере.

## Связанные спецификации

- [`features/ux-mvp.spec.md`](features/ux-mvp.spec.md) — экраны, состояния, navigation boundaries и acceptance criteria для R03.
- [`../docs/UX_STATE_MAP.md`](../docs/UX_STATE_MAP.md) — Quick/Power UX и lifecycle transitions.
- [`../docs/UX_FIXTURE_MATRIX.md`](../docs/UX_FIXTURE_MATRIX.md) — синтетические сценарии и ожидаемые состояния.
