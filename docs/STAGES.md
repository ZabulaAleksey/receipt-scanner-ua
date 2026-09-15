# Этапы Receipt Scanner UA

- Stage ID: R05

Этот файл — единственный live owner выбранного этапа, status,
blockers/evidence и NEXT. UX-first порядок находится в `docs/ROADMAP.md`,
requirements — в accepted SPEC. Старые R00–R05/00–23 contracts сохранены
в `docs/notes/legacy-stage-contracts.md` как historical reference,
а не в отдельном prompt/status owner.

## R05 — Local receipt image intake

- Status: implemented_unverified
- NEXT: R05-PLATFORM-EVIDENCE
- Depends on: R04 local persistence and accepted UX MVP shell
- Blockers: Windows image-intake integration exit verdict отсутствует;
  Android/iOS native runtime не проверен. В isolated Windows clone
  Flutter/Dart executable не обнаружен, поэтому текущие formatting,
  analyze и 36 Flutter tests не повторены. Product backend/OCR path
  отсутствует, его E2E остаётся BLOCKED_BY_BACKEND_RECEIPT_SCANNER.
- Evidence: R05 product commit 79e77ca is ancestor of GitHub main f706261; historical Flutter 36 tests passed, native platform exit verdict pending.

Цель: выбрать одну photo-library фотографию чека через
`ReceiptImageIntakePort`, проверить type/size/dimensions, скопировать
в app-controlled local storage и показать честный Preview без OCR,
camera capture, backend или sync. Реализация присутствует в `mobile/lib`
и tests; accepted contract —
`specs/features/local-receipt-image-intake.spec.md` и ADR-006.

DoD: AC-IMG-001..006 и privacy negative cases PASS; frozen Flutter
restore/format/analyze/full test и доступные platform integration gates
имеют явный exit verdict. Windows runner лишь validation surface;
Android/iOS product runtime evidence фиксируется отдельно. Без него
не повышать R05 до `completed` и не начинать camera/OCR slice.

### Действия пользователя и интеграция

- `USER-RSU-R05-NATIVE-EVIDENCE` — `PENDING`, condition: доступен host
  с официальным Flutter SDK и Android device/emulator, затем macOS/Xcode
  для iOS. Действие: на отдельной безопасной fixture/photo без приватных
  чеков повторить R05 Windows integration при доступном runner и выполнить
  Android/iOS build+gallery intake/cancel/retry/Preview сценарий по SPEC;
  не включать cloud/OCR. Ожидаемое evidence: toolchain/device profile,
  команды, exit verdict и результаты privacy/negative checks без
  пользовательских изображений или secrets. Это разблокирует terminal
  native/platform gates R05; backend E2E остаётся отдельным blocker.
- `USER-RSU-STAGES-INTEGRATION` — `DONE`: пользователь разрешил merge
  `feature/docs-stages-canonical`; `main` fast-forward до `a3c18c0` и
  опубликован. GitHub read-back подтвердил только `docs/STAGES.md` из
  четырёх state paths; canonical adapter выбирает R05,
  `implemented_unverified` и NEXT. Platform action выше остаётся
  `PENDING`; Flutter tests не повторены на этом host.
