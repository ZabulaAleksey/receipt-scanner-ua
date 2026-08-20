# Receipt Scanner UA — DESIGN

Статус: канонический UX/visual baseline. Fixture-driven UX MVP реализован в `mobile/`; real camera/OCR/backend остаются за границей R03.

Детальный контракт экранов и состояний: [`../specs/features/ux-mvp.spec.md`](../specs/features/ux-mvp.spec.md). Навигационные переходы и тестовые сценарии зафиксированы в [`UX_STATE_MAP.md`](UX_STATE_MAP.md) и [`UX_FIXTURE_MATRIX.md`](UX_FIXTURE_MATRIX.md); этот документ остаётся источником visual language и общих UX-принципов.

## Product experience

Практичный light-first интерфейс без fintech-декоративности. Основной путь: импорт/скан → распознавание → результат → при необходимости review → история/экспорт. Confidence, manual correction и normalization всегда отображаются как разные состояния.

Два режима используют одну модель данных:

- Quick UX: сфотографировать, сохранить результат и выйти без обязательной немедленной проверки;
- Power UX: inbox, массовая проверка, corrections, aliases, evidence, price history и analytics.

## Visual language

- белые/серые поверхности, синий action accent, зелёный только для подтверждённого success;
- компактные таблицы, небольшие radii, минимум shadow;
- tabular numbers для денег и количеств;
- украинская локализация — baseline, компоненты не зашивают язык;
- не показывать ложные `100% confidence` и не смешивать OCR text с normalized entity.

## Native mobile UX

Android и iOS являются отдельными native targets, не PWA. Smartphone flow проектируется для portrait, one-hand actions, крупных touch targets и platform accessibility. Tablet/landscape может использовать split view. Camera permissions запрашиваются только в контексте действия пользователя.

Канонические UX MVP экраны:

1. Home / Scan CTA.
2. Camera/Scan simulation с будущей framing/quality boundary.
3. Crop/Preview.
4. Processing с честным local/cloud mode.
5. Receipt Result.
6. Review Queue.
7. Line-item Correction.
8. Unknown Merchant Resolution.
9. Receipt Detail / raw evidence ↔ parsed ↔ normalized provenance.
10. Purchases / History.
11. Product / Price History.
12. Insights.
13. Settings / Storage / Sync.
14. Backup / Restore teaser.
15. «Для бизнеса — скоро» без enterprise workflows.

## Desktop / power review

Desktop/web review остаётся отдельным будущим client mode: source image слева, metadata/matching в центре, structured items/confidence/export справа, ниже history/recent receipts. Массовая таблица обязана поддерживать keyboard-first workflow.

## Regional and merchant UX

Украина — первый Region Pack, не hardcode core. Известный merchant ускоряет обработку, но неизвестный ФОП/частник является штатным состоянием. Raw merchant text хранится отдельно от normalized merchant, а объединение aliases требует confidence/review.

## Local-first и privacy

- `LOCAL_ONLY` — полноценный default без account/server;
- `SYNC_STRUCTURED`, `SYNC_RECEIPTS` и `BYO_STORAGE` — будущие opt-in modes;
- capture, inbox, review и local history должны работать offline;
- original images остаются on-device по умолчанию;
- cloud processing различим до отправки данных;
- model-training opt-in отделён от обычного consent;
- billing/subscription/B2B не блокируют consumer core.

## UX MVP boundary

UX MVP использует только synthetic fixtures/mock data. Backend-dependent элементы могут быть визуально представлены, но не имитируют готовую production capability. Реальная camera, OCR, persistence, sync, auth и billing подключаются только в последующих этапах через ports/use cases.

## R03 visual evidence

Концепты, использованные для реализации:

- [`design-concepts/r03-quick-ux.png`](design-concepts/r03-quick-ux.png) — Home, Scan simulation, Preview, Processing, Result;
- [`design-concepts/r03-power-ux.png`](design-concepts/r03-power-ux.png) — Review, Correction, Merchant, Detail, History;
- [`design-concepts/r03-insights-settings.png`](design-concepts/r03-insights-settings.png) — Price History, Insights, Settings, Backup, Business.

Реализованный Flutter shell сохраняет light-first palette, navy typography, blue primary action, четыре нижних navigation context, tabular totals и компактные receipt cards. Допустимые отклонения R03: вместо реального camera preview используется fixture selector, графики представлены простыми локальными summaries, а platform chrome зависит от Flutter runner. Golden baseline главного экрана: `mobile/test/goldens/home.png` при logical viewport `390×844`.
