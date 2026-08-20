# UX MVP specification

Статус: принятый UX MVP-контракт R02. Реализацию приложения не описывает и не разрешает.

## Цель

Проверить navigation, information hierarchy, correction workflow, offline/local-first expectations и mobile ergonomics на synthetic fixtures до выбора stack и подключения production camera/OCR/backend.

## Общие инварианты

- Quick UX и Power UX используют одну модель Receipt, Merchant, LineItem, ReviewIssue и provenance.
- Scan может завершиться сохранением без немедленного review; review queue существует отдельно.
- Unknown Merchant — штатное состояние, а не ошибка.
- Raw evidence, OCR text, parsed candidate, correction и normalized entity визуально различимы.
- Confidence — сигнал review, не вероятность истины; `100%` не показывается без реального источника такой гарантии.
- `LOCAL_ONLY` полностью работоспособен без network/account/subscription.
- Sync, backup, subscription и B2B в UX MVP являются честно обозначенными teaser/placeholder, а не фиктивно работающими production features.
- Все данные R03 — synthetic fixtures; реальные чеки и PII запрещены.

## Navigation model

Нижняя mobile navigation: `Home`, `Review`, `History`, `Settings`. Primary Scan action доступен с Home и может быть центральным action. Detail/correction/merchant resolution открываются как nested routes и возвращают пользователя в исходный контекст.

## Экраны

### 1. Home

- Цель: начать scan за одно действие и увидеть recent receipts/review count.
- Primary: `Сканировать чек`; secondary: открыть recent receipt, Review Queue, Batch Scan concept.
- Вход/выход: launch/navigation tab → Scan, Receipt Detail, Review, History.
- Состояния: normal; empty с первым CTA; offline без деградации local content; stale sync badge только для opt-in mode; error локального чтения с retry/diagnostics.
- Accessibility: Scan имеет ясный label, порядок focus начинается с primary action, totals озвучиваются с валютой.
- Data: fixture recent receipts/review count; позже ReceiptQuery и ReviewQueue ports.

### 2. Camera / Scan Simulation

- Цель: понять framing/quality feedback будущей камеры без доступа к реальной camera.
- Primary: simulated capture; secondary: выбрать synthetic example, cancel, flash placeholder без обмана о доступности.
- Вход/выход: Home → Crop/Preview либо Home при cancel.
- Состояния: ready; too dark; blur; glare; incomplete coverage; auto-capture ready; permission education placeholder; offline не влияет.
- Accessibility: feedback не только цветом, haptic/audio обозначены как future platform behavior, capture доступен screen reader.
- Data: deterministic simulation states; позже `CameraCapturePort` и `CaptureQualityPort`.

### 3. Crop / Preview

- Цель: подтвердить границы и качество изображения до обработки.
- Primary: `Обработать`; secondary: retake, rotate, adjust crop, add page/long receipt concept.
- Вход/выход: Camera → Processing; назад → Camera.
- Состояния: valid; crop incomplete; low resolution warning; multi-shot draft; recoverable edit error.
- Accessibility: handles имеют alternative controls, actions имеют text labels, zoom не блокирует system magnification.
- Data: fixture image metadata/corners; позже image preprocessing/crop port.

### 4. Processing

- Цель: показать текущий stage и честный mode без ложного progress.
- Primary: отсутствует во время короткого run; secondary: cancel, run in background concept, diagnostics при error.
- Вход/выход: Preview → Receipt Result; cancel → Home; recoverable failure → Preview/retry.
- Состояния: queued, preprocessing, recognizing, parsing, normalizing, offline-local, optional-cloud-unavailable, cancelled, failed.
- Accessibility: progress announcements throttled, spinner имеет text status, motion учитывает reduced-motion.
- Data: deterministic fixture timeline; позже ProcessingUseCase events.

### 5. Receipt Result

- Цель: быстро подтвердить merchant/date/total и сохранить без обязательного детального review.
- Primary: `Сохранить`; secondary: review issues, edit header, view evidence, rescan.
- Вход/выход: Processing → Home after save либо Line-item Correction/Unknown Merchant/Receipt Detail.
- Состояния: clean; low-confidence issue count; total mismatch; unknown merchant; duplicate warning; saved; save error.
- Accessibility: issues сгруппированы и озвучиваются до success, currency/date localized, rows имеют accessible names.
- Data: fixture ReceiptSummary/ReviewIssue; позже ReceiptProcessingResult.

### 6. Review Queue

- Цель: независимо от Quick UX обработать накопленные issues.
- Primary: открыть следующий issue; secondary: filter/sort, defer, open receipt.
- Вход/выход: Review tab/Home badge → Correction, Unknown Merchant или Receipt Detail → обратно с сохранённой позицией.
- Состояния: normal; empty; loading; offline; stale sync; filter-no-results; local read error.
- Accessibility: список поддерживает keyboard/screen-reader navigation, filters имеют selected state, issue priority не только цветом.
- Data: fixture ReviewIssue list; позже ReviewQueuePort.

### 7. Line-item Correction

- Цель: исправить raw fields или выбрать normalized product, сохранив provenance.
- Primary: применить correction; secondary: choose candidate, create product concept, unresolved, skip/defer.
- Вход/выход: Review/Receipt Result → source context after save/cancel.
- Состояния: candidates available; no candidate; low-confidence; validation error; conflict/stale edit; save failure.
- Accessibility: raw/parsed/normalized labels читаются явно, form errors связаны с полями, touch и keyboard actions эквивалентны.
- Data: fixture LineItemEvidence/Candidates; позже CorrectionUseCase и AliasPort.

### 8. Unknown Merchant Resolution

- Цель: подтвердить merchant, создать локальный profile/alias либо оставить unknown.
- Primary: подтвердить выбранное решение; secondary: choose candidate, create local merchant, keep unknown, merge concept с warning.
- Вход/выход: Result/Review → исходный receipt context.
- Состояния: no candidates; possible matches; ambiguous identity; validation error; saved local alias; offline normal.
- Accessibility: evidence и consequence каждого merge озвучиваются; dangerous merge требует явного confirmation.
- Data: fixture MerchantEvidence/Candidates; позже MerchantResolutionPort.

### 9. Receipt Detail / Evidence

- Цель: просмотреть сохранённый чек и трассу raw evidence → parsed → normalized.
- Primary: открыть issue/edit; secondary: view image overlay concept, export, duplicate relationship, delete concept.
- Вход/выход: Home/History/Review → nested corrections/product/merchant → обратно.
- Состояния: complete; pending review; missing local image; archived; duplicate; corrupted evidence explicit error.
- Accessibility: provenance доступен как структурированный текст, overlay не единственный способ чтения, tables имеют headers.
- Data: fixture ReceiptAggregate/Provenance; позже ReceiptRepository query.

### 10. Purchases / History

- Цель: находить receipts/items по времени, merchant и category.
- Primary: открыть receipt; secondary: search/filter/date range, switch receipt/item view.
- Вход/выход: History tab → Receipt Detail/Product Detail.
- Состояния: normal; empty; filtered empty; offline; stale optional sync; pagination/loading; query error.
- Accessibility: filters и dates имеют локализованные labels, charts не обязательны для понимания, list order объявляется.
- Data: fixture PurchaseHistory; позже HistoryQueryPort.

### 11. Product / Price History

- Цель: увидеть normalized product, aliases и подтверждённую историю цен.
- Primary: открыть purchase/receipt point; secondary: change range, inspect aliases, correction entry.
- Вход/выход: History/Receipt Detail → related receipts/correction.
- Состояния: sufficient history; single point; no history; unresolved product; stale optional sync; query error.
- Accessibility: график имеет текстовую таблицу/summary, price change не только цветом, tabular numbers.
- Data: fixture ProductPriceSeries; позже PriceHistoryPort.

### 12. Insights / Analytics

- Цель: показать полезные локальные summaries без обещания финансовой точности.
- Primary: открыть supporting purchases; secondary: range/category filter, explanation.
- Вход/выход: History/Insights route → filtered History/Product Detail.
- Состояния: normal; insufficient data; empty; offline; stale; calculation error.
- Accessibility: каждое visual insight имеет text equivalent; units/time range озвучиваются; no essential gesture-only controls.
- Data: fixture InsightCards; позже AnalyticsQueryPort.

### 13. Settings / Storage / Sync

- Цель: объяснить processing/storage mode и будущие opt-in capabilities.
- Primary: изменить доступные local settings; secondary: открыть inline Privacy disclosure, Backup, Region Pack, sync/subscription teaser.
- Вход/выход: Settings tab → Privacy disclosure sheet внутри экрана, Backup/Restore или system permission routes; disclosure закрывается обратно в Settings и не является 16-м экраном.
- Состояния: LOCAL_ONLY active; privacy disclosure; sync unavailable/not configured; future plan teaser; offline; settings save error.
- Accessibility: toggles имеют consequence text и current value; disabled teaser объясняет причину; destructive actions отделены.
- Data: fixture settings; позже SettingsPort/StorageModePort.

### 14. Backup / Restore Teaser

- Цель: проверить понятность будущих backup modes, не имитируя передачу данных.
- Primary: в UX MVP — `Понятно`/return; secondary: compare local export/BYO/cloud concepts.
- Вход/выход: Settings → Settings.
- Состояния: informational; LOCAL_ONLY; provider unavailable placeholder; restore conflict concept; offline.
- Accessibility: teaser явно помечен «ещё недоступно», comparison читается линейно, никаких fake progress/success.
- Data: static fixture capability descriptors; позже BackupPort/RestoreUseCase.

### 15. «Для бизнеса — скоро»

- Цель: обозначить future B2B branch без enterprise workflow в consumer navigation.
- Primary: вернуться; secondary: необязательный learn-more static content.
- Вход/выход: Settings/About или отдельная ненавязчивая ссылка → назад.
- Состояния: только informational/offline; network lead form отсутствует.
- Accessibility: placeholder не выглядит активной недоступной feature; смысл доступен без изображения.
- Data: static copy; organization/account/backend data отсутствуют.

## Cross-screen error policy

- Recoverable local operation: показать cause category, retry и безопасный back path.
- Corrupted evidence/schema mismatch: fail closed, не показывать stale data как корректные.
- Optional network unavailable: сохранить local operation и явно показать, какая только online-функция недоступна.
- Save conflict: не перетирать correction молча; показать choice/reload path как будущий Functional MVP contract.

## R03 acceptance criteria

1. Запускаемый доступный native target реализует Quick UX `Home → Scan Simulation → Preview → Processing → Result → Save` без сети.
2. Bottom navigation и nested routes покрывают все 15 экранов; Power UX допускает fixture skeletons, но routes и ключевые states существуют.
3. Минимум три demo fixtures: known merchant/clean, unknown merchant, low-confidence line.
4. UI получает данные через fixture repository + ports/use cases, а не читает scattered JSON напрямую.
5. Tokens/visual language соответствуют `docs/DESIGN.md`; mobile touch и accessibility semantics проверяемы.
6. Loading/empty/error/offline states реализованы минимум для Home, Processing, Result, Review и History.
7. Cloud/sync/backup/subscription/B2B обозначены честными placeholders и не блокируют local flow.
8. Navigation component tests, accessibility checks и стабильные screenshot/golden tests выполнены там, где stack позволяет.
9. Real camera/OCR/backend/auth/billing/sync не реализованы.
10. E2E без live backend остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`; offline fixture demo проверяется как component/integration path.
