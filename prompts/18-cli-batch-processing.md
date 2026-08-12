# 43. PROMPT 18 — CLI Workflow + Batch Processing

```text
Собери команды:
scan, process, ocr, parse, normalize, review, export,
evaluate, benchmark, doctor, status.

Batch:
- продолжает после ошибки одного receipt;
- сохраняет stage status;
- поддерживает resume;
- не повторяет completed stage без --force;
- idempotent где возможно.
```

### DoD
- directory проходит end-to-end;
- interrupted run можно продолжить;
- duplicate processing не плодит записи.

---
