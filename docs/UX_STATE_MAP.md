# UX MVP state map

Статус: каноническая navigation/state map R02, framework-neutral.

## Quick UX

```text
HOME
  → SCAN_SIMULATION
      → CAPTURE_NOT_READY (blur / glare / coverage / darkness)
      → CAPTURE_READY
          → CROP_PREVIEW
              → PROCESSING_LOCAL
                  → RESULT_CLEAN → SAVE → HOME
                  → RESULT_REVIEWABLE → SAVE → HOME + REVIEW_BADGE
                  → RESULT_UNKNOWN_MERCHANT → RESOLVE | KEEP_UNKNOWN → SAVE
                  → RESULT_DUPLICATE → OPEN_EXISTING | SAVE_SEPARATE | CANCEL
                  → PROCESSING_FAILED → RETRY | PREVIEW | HOME
```

Quick UX никогда не требует входа в correction screen для сохранения reviewable receipt. Нерешённые issues попадают в отдельную очередь.

## Power UX

```text
REVIEW_QUEUE
  → LINE_ITEM_CORRECTION → SAVE | DEFER → REVIEW_QUEUE
  → UNKNOWN_MERCHANT → CONFIRM | KEEP_UNKNOWN | DEFER → REVIEW_QUEUE
  → RECEIPT_DETAIL
      → EVIDENCE
      → LINE_ITEM_CORRECTION
      → PRODUCT_PRICE_HISTORY

HISTORY
  → RECEIPT_DETAIL
  → PRODUCT_PRICE_HISTORY
  → INSIGHTS → FILTERED_HISTORY

SETTINGS
  → STORAGE_SYNC
      → PRIVACY_DISCLOSURE_SHEET → STORAGE_SYNC
  → BACKUP_RESTORE_TEASER
  → BUSINESS_PLACEHOLDER
```

## Global modes

| Mode | Local behavior | Online representation |
|---|---|---|
| `LOCAL_ONLY` | Полностью доступен | Online controls выключены с объяснением |
| `SYNC_STRUCTURED` teaser | Local data работает | Только informational в UX MVP |
| `SYNC_RECEIPTS` teaser | Original image остаётся local | Только opt-in concept |
| `BYO_STORAGE` teaser | Export concept | Provider не подключается |
| Offline | Capture/review/history доступны | Stale/unavailable badge только на online feature |

## Receipt persistence lifecycle

```text
DRAFT_CAPTURE
→ PROCESSING
→ PROCESSED_CLEAN | PROCESSED_WITH_ISSUES | FAILED
→ SAVED
→ ARCHIVED
```

Review status является отдельным измерением и назначается только при наличии issues:

```text
PROCESSED_CLEAN → REVIEW_NOT_REQUIRED
PROCESSED_WITH_ISSUES → REVIEW_PENDING
REVIEW_PENDING → REVIEWED | PARTIALLY_REVIEWED | UNRESOLVED
```

Duplicate detection не удаляет и не объединяет receipt автоматически. Unknown merchant и unresolved item допустимы в `SAVED`; чистый `SAVED` receipt не попадает в Review Queue.

## Review issue lifecycle

```text
OPEN → IN_REVIEW → RESOLVED
                 → DEFERRED → OPEN
                 → UNRESOLVED
```

Correction создаёт новую provenance event; raw evidence не мутируется.

## Failure transitions

- Local read/write error → retry либо safe back; неподтверждённый success запрещён.
- Optional sync unavailable → local flow продолжается; retry относится только к sync.
- Corrupted evidence/schema mismatch → explicit blocked detail; silent fallback запрещён.
- Cancel processing → draft удаляется только после подтверждения, если уже есть локальные изменения.

## Back navigation invariants

- Correction возвращает в исходный Receipt/Queue context и сохраняет scroll/filter position.
- Смена tab не уничтожает unsaved edit без confirmation.
- Deep link в nested screen при отсутствии fixture показывает explicit unavailable state, не crash.
