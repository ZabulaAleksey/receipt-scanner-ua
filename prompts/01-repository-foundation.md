# 26. PROMPT 01 — Repository Foundation

```text
Создай Foundation Receipt Scanner UA с учётом CONTEXT_COMPATIBILITY.md.

Используй Python src-layout и uv.
Создай pyproject.toml, uv.lock, .python-version, .gitignore, .env.example.
Создай canonical docs.
Не добавляй OCR models в Git.
Не добавляй MCP.
Не дублируй inherited hooks.

Добавь CLI entrypoint:
receipt --help
receipt doctor
receipt version

Doctor проверяет runtime, data directories, DB availability, config и OCR capability.
Добавь smoke/unit tests.
```

### DoD
- `uv sync` воспроизводим;
- CLI запускается;
- tests запускаются;
- docs созданы;
- raw/secrets отсутствуют.

---
