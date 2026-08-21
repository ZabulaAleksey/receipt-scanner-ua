# R02 — UX MVP specification и state map

Статус: `COMPLETE`. Тип: specification/design. Реализация приложения в этом этапе не выполнялась.

## Цель

Специфицировать fixture-driven native-mobile-looking UX MVP до подключения камеры, OCR, backend, auth, billing, cloud или production persistence.

## Пользовательские пути

- Quick UX: `Home → Scan simulation → Preview → Processing → Result → Done`.
- Power UX: `Inbox/Review → correction → merchant/product resolution → history → price history → insights → storage/backup settings`.

## Экраны

Home; Camera/Scan simulation; Crop/Preview; Processing; Receipt Result; Review Queue; Line-item Correction; Unknown Merchant; Receipt Evidence; Purchases/History; Product/Price History; Insights; Storage/Sync; Backup/Restore; «Для бизнеса — скоро».

Для каждого экрана определить цель, actions, navigation, normal/loading/empty/error/offline/low-confidence/stale states, accessibility и границу fixture/domain data.

## Fixture scenarios

Известный merchant; low-confidence line; неизвестный ФОП; discount; pharmacy/non-grocery; total mismatch; duplicate; long receipt/multi-shot concept; offline/LOCAL_ONLY; sync teaser. Использовать только синтетические данные.

## UX-инварианты

- scan не обязан немедленно вести в review;
- неизвестный merchant — штатное состояние;
- OCR confidence не является вероятностью истины;
- raw evidence, parsed candidate и normalized entity различимы;
- cloud/subscription/B2B не блокируют local consumer core.

## DoD

- все экраны и состояния специфицированы;
- Quick/Power state map и fixture matrix готовы;
- acceptance criteria для R03 определены;
- реализации и инфраструктуры нет.

## Verification evidence

- UX contract: `specs/features/ux-mvp.spec.md`;
- state map: `docs/UX_STATE_MAP.md`;
- fixture matrix: `docs/UX_FIXTURE_MATRIX.md`;
- все 15 экранов и R03 acceptance criteria проверены;
- независимый read-only review пройден без блокеров после устранения lifecycle/privacy неоднозначностей;
- product code, dependencies, CI и принятые test artifacts не изменялись.
