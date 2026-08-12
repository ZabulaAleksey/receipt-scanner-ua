# 29. PROMPT 04 — приём данных и дедупликация

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
- недействительное изображение создаёт контролируемую ошибку;
- batch продолжает работу.

---
