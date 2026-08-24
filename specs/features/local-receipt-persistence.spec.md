# Local receipt persistence specification

Статус: `IMPLEMENTED_AND_VALIDATED_ON_WINDOWS`; Android/iOS runtime остаётся `UNVERIFIED` из-за отсутствия соответствующих host/SDK.

## Цель

Сохранить и прочитать локальные `ReceiptAggregate` после перезапуска Android/iOS приложения, не меняя local-first модель продукта и не подключая camera, OCR, backend, sync или account.

## Контекст и границы

R03 предоставляет Flutter shell, 15 маршрутов, synthetic fixtures и синхронный `InMemoryReceiptStore`. Он полезен для UX, но не сохраняет данные между запусками. R04 заменяет только production composition этого store на persistent adapter за `ReceiptRepository`.

В scope входят:

- асинхронный контракт `ReceiptRepository` для load/save и типизированных ошибок;
- отдельная domain-модель `ReceiptAggregate` и mapper между fixture scenario и domain aggregate;
- SQLite schema version 1 для lossless локального сохранения aggregate;
- загрузка, empty, local read error и user-initiated retry в существующих Home/History/Review flows;
- unit, component и offline persistence integration evidence.

В scope не входят real camera/photo import, raw image persistence, OCR/provider SDK, parsing, normalization, sync, cloud/account, backup/restore, delete/reset UI, export, schema версии выше v1 и изменение approved fixtures/goldens.

## Требования

### PERS-001 — canonical local owner

`ReceiptRepository` остаётся единственной application boundary для receipt persistence. UI, routes и fixtures не обращаются к SQLite или файловой системе напрямую. Production composition не автоматически добавляет synthetic fixtures в пользовательское хранилище.

### PERS-002 — domain и precision

Persistent domain использует `ReceiptAggregate`, а fixture-specific тип остаётся test/demo adapter input. Сохранение восстанавливает все поля, необходимые текущим Home, Review, History и Receipt Detail flows: stable id, merchant, date, total, line items, raw/parsed/normalized/correction provenance и review-relevant flags. Денежные значения хранятся как integer minor units вместе с currency; `double`/`float` запрещены.

### PERS-003 — SQLite schema v1

Android/iOS adapter использует SQLite. Schema v1 должна содержать version marker, stable primary key, минимальные query fields и lossless versioned payload aggregate. Create/upgrade операции выполняются в транзакции. Persistence DTO и SQLite columns не становятся UI models и не заменяют domain contract.

### PERS-004 — local lifecycle

При bootstrap приложение явно показывает loading до завершения local read. Пустая база отображается как честное empty state, а не скрытое fixture-filled состояние. Успешный Save создаёт или сохраняет receipt по stable id и после повторного открытия базы возвращает тот же aggregate без потери provenance. Политика duplicate остаётся явной и покрытой тестом.

### PERS-005 — failure и recovery

Transient storage-open/read failure предоставляет безопасный user-initiated retry, который закрывает и повторно открывает local adapter. Corrupted payload, incompatible schema или failed migration не подменяются `InMemoryReceiptStore` либо fixture data и не перезаписываются: пользователь видит local read error, операция save не выполняется до успешного recovery. Автоматические retries, destructive reset и тихий fallback запрещены.

### PERS-006 — privacy и безопасность

R04 не пишет raw receipt images, real receipts, PII или secrets в Git, logs либо fixtures. Ошибки не содержат payload aggregate. SQLite path создаётся через безопасный platform storage API; user-provided path не принимается. Schema/payload deserialization валидирует version, required fields, type и reasonable resource limits до создания domain aggregate.

### PERS-007 — совместимость

Первый запуск R04 не имеет legacy persistent store для миграции. Future schema changes начинаются только от documented v1 и обязаны иметь отдельную migration/recovery SPEC, ADR delta и tests. Windows runner не становится product target, но может использовать FFI implementation для deterministic persistence validation.

## Acceptance criteria

1. Production `ReceiptRepository` является async SQLite adapter; UI не знает о SQLite API.
2. Новый receipt сохраняется локально и после close/reopen возвращается с теми же money values и provenance-relevant fields.
3. Empty, loading и local read error различимы в existing UX; retry не создаёт fixture data и не дублирует receipt.
4. Corrupted/incompatible local state завершает чтение явной безопасной ошибкой без in-memory fallback и без записи поверх неизвестного состояния.
5. Existing accepted tests/fixtures/goldens не изменены; новые tests покрывают repository contract, serialization, reopen, duplicate, failure and retry semantics.
6. `dart format`, `flutter analyze`, unit/widget/component tests и доступный offline local persistence integration path проходят. Android/iOS runtime status честно указан, если SDK/host недоступны.
7. Product E2E `client → API/CLI → backend` остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`; local persistence integration не называется backend E2E.

## Связи

- [System specification](../system.spec.md)
- [UX MVP specification](ux-mvp.spec.md)
- [ADR-002 и ADR-005](../../docs/DECISIONS.md)
- [Security](../../docs/SECURITY.md) и [Privacy](../../docs/PRIVACY.md)
- [R04 implementation prompt](../../prompts/R04-local-receipt-persistence.md)
