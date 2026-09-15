# Исторические AI facts Receipt Scanner UA

Evidence archive для preservation/rollback, не второй plan/status owner.
Полные исходные bytes восстанавливаются из Git `main` `f706261` /
parent миграционного commit.

| Original source | SHA256 |
|---|---|
| `prompts/STAGES.md` | `ac5e628c844c28fc24c3182604dd7c32c1499df9c29cd651a823099a540dd945` |
| `docs/AI_PLAN.md` | `2c1726f80035500580a5c6dcc6b094441c8a5ff80582523dd60c8be4bc169fba` |
| `docs/AI_STATUS.md` | `d4040890d648abb7626d6ef771fc78546345d25f11ed1f49da78c1f727119847` |

AI_PLAN выбирал R05 platform evidence после UX-first R00–R04,
сохранял Android/iOS как product targets и ставил camera/OCR позже.
Его ссылка на `prompts/R05-local-receipt-image-intake.md` уже
отсутствовала в Git `main` `f706261` — R05 contract был внутри STAGES.
AI_STATUS фиксировал R00–R03 UX-first shell, R04 SQLite persistence
с 25 Flutter tests и Windows integration PASS, R05 gallery intake
с 36 Flutter tests PASS по историческому runner. R05 Windows debug
build/integration не получил конечного exit verdict; Android/iOS
runtime UNVERIFIED. Product `client → API/CLI → backend` отсутствовал.

Старое утверждение AI_STATUS о R05 «в локальной рабочей ветке»
устарело: product commit `79e77ca` и merge `02b08d4` — ancestors
опубликованного GitHub `main` `f706261`. Это доказывает интеграцию
кода, но не terminal native platform evidence. User images/receipt
data, fixtures, Flutter manifests/lock и mobile tests не менялись.

Прежний `prompts/STAGES.md` содержал уникальные UX-first R00–R05
contracts и remapped legacy backlog 00–23; полный catalog перенесён
в `docs/notes/legacy-stage-contracts.md`. Старый `prompts/README.md`
называл STAGES единственным detailed owner, а AI_STATUS/AI_PLAN —
раздельными live state owners; эту launcher формулировку сохраняет
Git parent, текущий route принадлежит `docs/STAGES.md`.
