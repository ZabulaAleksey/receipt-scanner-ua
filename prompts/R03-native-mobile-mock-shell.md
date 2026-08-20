# R03 — Native mobile strategy и fixture-driven shell

Статус: `READY`. Тип: prototype implementation. Основание: принятый UX-контракт R02.

## Цель

Через ADR/spike выбрать минимально рискованный native-mobile stack и создать offline fixture-driven UX shell без реального OCR/backend.

## Technology decision

Сравнить Kotlin Multiplatform + Compose Multiplatform и Flutter по Android/iOS workflow, native camera path, local DB, OCR/native ML integration, Text Recognition Core integration, accessibility, performance, testing и maintainability. Решение подтверждать evidence.

## Scope

- Android и iOS app targets; не PWA/WebView wrapper;
- navigation, tokens/theme, reusable primitives, fixture repository и ports/use cases;
- минимум `Home → Scan simulation → Preview → Processing → Result`;
- Power UX routes допускаются как fixture skeletons;
- camera остаётся simulation за `CameraCapturePort` или эквивалентом.

## Non-goals

Production backend, real sync, billing, обязательный account, real OCR и production camera pipeline.

## Проверки и DoD

- ADR KMP/Compose vs Flutter;
- build/compile feasibility хотя бы доступного target с честно указанными ограничениями;
- navigation component tests, accessibility checks и стабильные screenshot/golden tests, где доступны;
- demo полностью работает без сети;
- UI зависит от ports/use cases;
- unit, integration и component проверки выполнены; E2E без живого backend помечен `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`.
