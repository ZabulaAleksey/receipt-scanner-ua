# UX MVP fixture matrix

Все fixtures синтетические. Имена merchants являются вымышленными либо текстовыми category examples без чужих brand assets.

| ID | Сценарий | Ключевые данные | Ожидаемые экраны/состояния | Проверяемый invariant |
|---|---|---|---|---|
| `FX-01-CLEAN` | Известный merchant, чистый чек | 5 items, matching totals, high signals | Home, Processing, clean Result, Detail, History | Quick UX сохраняет без review |
| `FX-02-LOW-CONFIDENCE` | Одна сомнительная строка | ambiguous product text, 2 candidates | Result issue badge, Queue, Correction, Evidence | Confidence не скрывается; save всё равно возможен |
| `FX-03-UNKNOWN-MERCHANT` | Неизвестный ФОП/частник | raw name/address, no catalog match | Result, Unknown Merchant, Detail | Unknown — normal; keep unknown доступен |
| `FX-04-DISCOUNT` | Discount/loyalty line | item discount + receipt discount | Result, Detail/Evidence, History | Discount не превращается в товар; total объясним |
| `FX-05-PHARMACY` | Pharmacy/non-grocery | medicine-like/general health items | Result, Correction, Product History | Core не ограничен grocery taxonomy |
| `FX-06-TOTAL-MISMATCH` | Несходящийся total | item sum отличается от total | Processing, Result warning, Review Queue | Ошибка не маскируется success |
| `FX-07-DUPLICATE` | Повторный чек | matching fingerprint, existing receipt id | Result duplicate state, existing Detail | Нет silent merge/delete |
| `FX-08-LONG-RECEIPT` | Long receipt/multi-shot concept | 3 image segments, overlap metadata | Camera simulation, Preview multi-shot, Processing | Concept видим без real stitching implementation |
| `FX-09-OFFLINE` | Offline/local-only | network false, local history populated | Home, Scan, Result, Review, History, Settings | Core flow полностью работает без сети |
| `FX-10-SYNC-TEASER-OFF` | Sync unavailable/disabled | LOCAL_ONLY, teaser disabled | Settings, Backup teaser | Teaser честно не работает и не блокирует core |
| `FX-11-SYNC-TEASER-ON` | Future plan comparison | capability flags only, no credentials | Settings comparison и inline privacy disclosure | Нет fake sync success и сетевого side effect; новый экран не добавляется |
| `FX-12-EMPTY` | Новый пользователь | no receipts/issues/history | Home/Review/History empty states | Empty states ведут к Scan, не выглядят ошибкой |
| `FX-13-LOCAL-ERROR` | Local repository read failure | deterministic error category | Home/Review/History error + retry | Failure видим, stale data не выдаётся за current |
| `FX-14-STALE-EDIT` | Conflict concept | edit version mismatch | Correction conflict state | Correction не перетирается молча |

## Минимальный demo set R03

Обязательны `FX-01-CLEAN`, `FX-02-LOW-CONFIDENCE`, `FX-03-UNKNOWN-MERCHANT`. Для no-network acceptance дополнительно использовать `FX-09-OFFLINE`. Остальные могут быть fixture skeletons, но schema и expected state должны оставаться стабильными.

## Fixture contract

- Stable fixture id и deterministic values.
- Fixed precision money; explicit currency/locale.
- Raw evidence, parsed and normalized layers stored separately.
- No real phone, card, fiscal id, email, loyalty id, QR payload or personal address.
- Accepted fixture/golden не изменяется в implementation cycle; contract change выполняется отдельно.
