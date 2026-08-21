# Privacy

## Data principles

- `LOCAL_ONLY` — baseline: raw images и structured purchase data остаются на устройстве.
- Собирать и хранить только данные, необходимые выбранному пользователем режиму.
- Original receipt images не загружаются автоматически.
- R04 structured local database хранится в dedicated app-controlled directory; Android backup выключен, iOS получает backup exclusion до открытия SQLite. Эта native runtime гарантия ещё не проверена на Android/iOS host.
- Cloud processing, structured sync и raw-image backup имеют раздельные opt-in controls.
- Model-training consent отделён от обычной обработки и по умолчанию выключен.

## Storage modes

- `LOCAL_ONLY` — всё локально;
- `SYNC_STRUCTURED` — только receipts/items/merchants/aliases/history;
- `SYNC_RECEIPTS` — opt-in backup изображений и structured data;
- `BYO_STORAGE` — будущий экспорт/backup в выбранное пользователем хранилище.

## User control

До Production MVP должны быть определены retention, delete, export, backup/restore и revocation semantics. Permission rationale показывается в контексте действия, а privacy agreement не блокирует ранний local-only UX первым экраном.

## Development data

В Git допускаются только synthetic или подтверждённо анонимизированные fixtures. Реальные чеки хранятся вне tracked directories; privacy scanner и review должны предотвращать случайный commit PII.

## Неутверждённое

Конкретный cloud provider, telemetry SDK, analytics vendor, subscription backend, юридический текст и store declarations не выбраны и требуют отдельного решения позднее.
