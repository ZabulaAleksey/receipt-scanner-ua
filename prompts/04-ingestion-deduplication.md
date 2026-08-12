# 29. PROMPT 04 — Ingestion + Deduplication

```text
Реализуй scan file/directory/recursive.

Для каждого файла:
validate → SHA-256 → dimensions/metadata → exact dedupe → DB registration.
Raw image не изменять.

Optional perceptual hash может только помечать probable duplicate,
но не удалять автоматически.

Batch должен переживать повреждённый файл.
```

### DoD
- exact duplicate не создаёт вторую запись;
- invalid image даёт controlled error;
- batch продолжает работу.

---
