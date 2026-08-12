# 47. PROMPT 22 — безопасность, восстановление после сбоев и резервные копии

```text
Проведи project-specific privacy/security review поверх inherited global rules.

Проверь:
raw data, logs, Excel formula injection, path traversal,
malicious/corrupt images, oversized images, decompression bombs,
DB backup/restore, migration recovery, user filenames.

Добавь backup canonical DB/config/aliases без raw photos по умолчанию.
```

### DoD
- модели угроз и сбоев документированы;
- injection формул предотвращена;
- неконтролируемая запись файлов отсутствует;
- приёмочный тест резервного копирования и восстановления проходит.

---
