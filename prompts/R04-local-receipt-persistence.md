# R04 — Local receipt persistence

Статус: `APPROVED FOR IMPLEMENTATION` после планирования 2026-08-21. Тип: Functional MVP implementation slice.

## Goal

Заменить prototype-only `InMemoryReceiptStore` в production Flutter composition на local-first SQLite persistence за асинхронным `ReceiptRepository`, чтобы пользовательские Receipt aggregates сохранялись и читались после перезапуска приложения.

## Context

R03 создал Flutter shell с 15 typed routes, in-memory state и synthetic fixtures. Локальное хранение — первый intentional Functional MVP slice; оно не должно смешиваться с real camera/import, OCR, parsing, backend, sync или account.

Канонический контракт: [`specs/features/local-receipt-persistence.spec.md`](../specs/features/local-receipt-persistence.spec.md). Архитектурное решение: ADR-005 в [`docs/DECISIONS.md`](../docs/DECISIONS.md). Существующие UX/visual boundaries остаются в [`docs/DESIGN.md`](../docs/DESIGN.md).

## Current state / evidence

- `mobile/lib/src/domain.dart` содержит synchronous `ReceiptRepository` и `InMemoryReceiptStore`.
- `mobile/lib/src/composition.dart` injects `InMemoryReceiptStore`; `AppController` seeds fixtures in memory.
- UI читает receipt list в Home, Review, History и Price History; existing shell уже имеет loading/empty/error/offline states.
- В `mobile/pubspec.yaml` отсутствуют persistence dependencies.
- R03 tests, including 14 unit/widget/component checks, passed before this plan. Android/iOS runtime remain `UNVERIFIED` in the current host.

## Scope

- Ввести `ReceiptAggregate` domain contract, async repository lifecycle и typed persistence failures without leaking SQLite into UI.
- Реализовать SQLite v1 adapter for Android/iOS using `sqflite`; use `sqflite_common_ffi` only for deterministic Windows/unit/integration validation where needed.
- Сохранить lossless aggregate payload plus minimal query fields, stable id and schema version; keep money in integer minor units.
- Переключить production composition root to persistent repository; keep fixture/demo dependencies explicit and separate from user storage.
- Показать bootstrap loading, true empty, local read error и user-initiated retry through existing routes.
- Добавить only new tests required for this behavior; preserve all accepted tests, fixtures and goldens.
- Update relevant architecture/status documentation only after evidence is obtained.

## Non-goals

- real camera, gallery/photo import, raw image storage or permissions;
- OCR, parsing, normalization, merchant adapters and real review workflow;
- backend, sync, account, telemetry, billing, backup/restore, export, delete/reset UI;
- changing Android/iOS product target policy, treating Windows as a product target, or adding a parallel KMP implementation;
- schema v2+ and migration from an older user database (none exists before v1).

## Requirements

Implement PERS-001 through PERS-007 from the linked SPEC. In particular:

- No direct storage access from widgets, fixture repository or routes.
- Saving and reopening preserve stable id, money precision and provenance-relevant fields.
- Empty is not automatically populated by fixture data in production.
- Repository duplicate behavior is documented and test-covered.
- Deserialization validates schema and payload before constructing a domain aggregate.
- Errors shown to users/logs are safe categories, never receipt payload or secrets.

## Architecture constraints

- Keep application/domain, persistence DTO/schema and UI/fixture data distinct.
- Preserve adapter boundaries and local-first `LOCAL_ONLY` baseline.
- Use Flutter composition root for dependency selection; do not scatter platform checks across screens.
- SQLite is the canonical mutable local store for this slice; Excel/JSON files are not a database substitute.
- Do not retain `ReceiptFixture` as the persistent production domain type: fixture scenarios map into `ReceiptAggregate`.
- New packages must be pinned through the lockfile and reviewed for target compatibility; do not add unrelated dependencies.

## Security & abuse constraints

- Use only application-controlled platform storage paths; never accept arbitrary user path input.
- Validate payload version, shape, required values and resource limits before reading into domain objects.
- No real receipts, PII, test credentials or raw image payloads in Git, fixtures or ordinary logs.
- Do not expose destructive reset/recovery controls in R04. Failed migration, corrupt data or incompatible schema must retain the original state for explicit future recovery.

## Fallback / failure behavior

```text
SQLite open/read
→ user-initiated close/reopen retry for a transient operational failure
→ explicit local-read-error UI
→ fail closed for corrupt payload, incompatible schema or failed migration
```

No automatic retry loop, in-memory fallback, fixture fallback or overwrite of unknown partial state. Save is disabled or fails explicitly until a successful open; it must not create duplicate records after a retry.

## Compatibility / migration

Create schema v1 transactionally. There is no pre-R04 persistent data migration. Future schema evolution starts from this documented v1 boundary and requires its own migration plan, tests and ADR update. The FFI adapter is validation tooling, not a different product persistence format.

## Testing & validation

Run existing checks from `mobile/` and add focused coverage:

- `dart format --output=none --set-exit-if-changed lib test integration_test`;
- `flutter analyze --no-pub`;
- `flutter test --no-pub test`;
- repository contract: lossless round-trip, duplicate semantics, empty database, close/reopen persistence, corrupt/incompatible payload, migration/open failure and retry;
- widget/component: loading, empty and local read-error/retry state;
- available Windows local persistence integration scenario; keep its evidence separate from product/backend E2E;
- run Android/iOS build/runtime checks only when required SDK/host is available; otherwise state `UNVERIFIED`.

Do not modify approved tests/fixtures/goldens in this stage. If an accepted test conflicts with this SPEC, stop and request a separate contract-change decision.

## Acceptance criteria

All seven acceptance criteria in the linked SPEC are met. Additionally, `AI_STATUS.md` must distinguish implementation, local validation, commit, push and merge evidence; it must not claim Android/iOS runtime or backend E2E without evidence.

## Definition of Done

- R04 code conforms to the persistence SPEC and ADR-005.
- Required tests/checks pass or unavailable platform checks are recorded honestly.
- Existing test contracts are preserved; no known undocumented regression remains.
- `ARCHITECTURE.md`, `DECISIONS.md`, `AI_STATUS.md` and `AI_PLAN.md` reflect verified facts only.
- Work is committed on a non-protected branch. Merge/push happen only with explicit user approval.

## Out-of-scope follow-ups

Real camera/import, evidence image retention, OCR/parser integration, review/correction persistence expansion, richer SQLite query schema, backup/restore, export and optional online services each require separate scope and acceptance criteria.
