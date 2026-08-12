# 47. PROMPT 22 — Security / Failure Recovery / Backups

```text
Проведи project-specific privacy/security review поверх inherited global rules.

Проверь:
raw data, logs, Excel formula injection, path traversal,
malicious/corrupt images, oversized images, decompression bombs,
DB backup/restore, migration recovery, user filenames.

Добавь backup canonical DB/config/aliases без raw photos по умолчанию.
```

### DoD
- threat/failure modes documented;
- formula injection mitigated;
- uncontrolled file writes отсутствуют;
- backup/restore acceptance test проходит.

---
