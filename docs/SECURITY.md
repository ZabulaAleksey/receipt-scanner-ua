# Security

## Scope

Receipt Scanner обрабатывает недоверенные изображения и потенциально чувствительные данные покупок. Этот документ содержит только project-specific delta поверх глобального security baseline.

## Trust boundaries

- camera/photo picker/imported files;
- OCR/provider output и model metadata;
- merchant/region packs и обновляемые dictionaries;
- optional sync/storage providers;
- exported Excel/CSV/JSON;
- future account, billing и B2B boundaries.

## Baseline controls

- проверять content type, размер, dimensions и resource limits изображений; защищаться от decompression bombs и path traversal;
- не доверять OCR/model output: schema validation и arithmetic reconciliation обязательны;
- не включать raw receipt content, tokens и sensitive identifiers в обычные logs;
- защищать Excel export от formula injection;
- использовать OS secure storage для future credentials/tokens;
- destructive delete/restore/migration должен быть явным, проверяемым и восстанавливаемым;
- corrupted state, schema mismatch и failed authorization не допускают silent fallback.

## Phase boundaries

- UX MVP: только synthetic fixtures, network не требуется.
- Functional MVP: local data protection, import limits, backup/restore integrity и permissions testing.
- Production MVP: threat model для account/sync, server authorization, quotas, retention, deletion/export, dependency/SDK telemetry audit и store declarations.

## Deferred controls

AuthN/AuthZ, rate limits и cloud tenancy не реализуются до появления соответствующей сетевой поверхности. Их отсутствие не считается разрешением добавлять публичный backend без отдельной SPEC и review.
