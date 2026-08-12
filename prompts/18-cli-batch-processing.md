# 43. PROMPT 18 — workflow CLI и пакетная обработка

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
- каталог проходит end-to-end проверку;
- interrupted run можно продолжить;
- duplicate processing не плодит записи.

---
