# Автоматизация контекста

## 3. Совместимость с существующим архивом «АВТОМАТИЗАЦИЯ КОНТЕКСТА»

### 3.1. Что считается унаследованным и локально не дублируется

Если в глобальной AI Dev Team уже есть:

- Lead Architect;
- Context Curator;
- Implementation Engineer;
- Test/QA Engineer;
- Reviewer;
- Performance Engineer;
- Security/Privacy Engineer;
- Docs Engineer;
- Git workflow;
- common hooks;
- GitHub MCP;
- Context7 MCP;
- DevTools MCP;
- global Skills;
- глобальные security rules;

**не создавать их вторую локальную копию.**

### 3.2. Anti-conflict protocol

Перед добавлением любого `agent / hook / MCP / skill / config` Codex обязан проверить существующий контекст и присвоить статус:

```text
INHERITED     — уже есть, использовать как есть;
EXTEND        — добавить только локальный delta;
PROJECT_ONLY  — специфично Receipt Scanner, можно создать;
CONFLICT      — дублирует/противоречит; не создавать;
OBSOLETE      — старый локальный duplicate, заменить ссылкой на более сильное правило.
```

Результат фиксируется в:

```text
docs/CONTEXT_COMPATIBILITY.md
```

### 3.3. Запрещено

```text
NO duplicate generic architect
NO duplicate generic tester/reviewer/security/docs agents
NO second Git workflow
NO duplicate GitHub/Context7/DevTools MCP
NO project MCP "на всякий случай"
NO second active global config.toml
NO SessionStart dump всего PROMPTS/ROADMAP/fixtures
NO чтение всего архива AI Dev Team для простой локальной задачи
```

---

---

## 4. Политика загрузки контекста

Порядок правил:

```text
SYSTEM / PLATFORM
    ↓
GLOBAL AI DEV TEAM
    ↓
WORKSPACE AGENTS
    ↓
ROOT AGENTS.md
    ↓
MODULE AGENTS.md
    ↓
TARGET SKILL / STAGE PROMPT
```

### Root `AGENTS.md`

Содержит только:
- Receipt-specific invariants;
- canonical docs;
- privacy/data rules;
- правила выбора локальных skills/agents;
- anti-conflict rule.

Целевой размер: ~3–7 KB.

### Module `AGENTS.md`

Только delta, например:

```text
src/receipt_scanner/ocr/AGENTS.md
src/receipt_scanner/parser/AGENTS.md
src/receipt_scanner/normalization/AGENTS.md
```

### Не загружать автоматически

- весь `PROMPTS.md`;
- весь `ROADMAP.md`;
- все TOML subagents;
- все Skill bodies;
- все OCR fixtures;
- старые benchmark reports;
- весь alias dictionary;
- весь `DECISIONS.md`, если нужна одна ADR.

---

---

## 19. АВТОМАТИЗАЦИЯ КОНТЕКСТА

### 19.1. Root `AGENTS.md`

Рекомендуемый смысл:

```md
# Receipt Scanner UA — local rules

This repository inherits installed/global AI Dev Team rules.
Do not duplicate generic agents, hooks, MCP, Git workflow or common security roles.

## Project invariants
1. Local-first baseline.
2. Raw receipts never committed.
3. DB is canonical state; Excel is export.
4. Preserve raw OCR/provenance.
5. Money uses Decimal.
6. Low confidence creates review.
7. Product merges must be explainable.
8. CPU OCR path remains available.
9. Experimental tech requires flag + fallback + benchmark.
10. Retailer logic goes through adapters.
11. Inspect inherited AI Dev Team before adding agent/hook/MCP.
12. Never load whole PROMPTS/ROADMAP/fixtures for a local task.

## Canonical docs
- docs/ARCHITECTURE.md
- docs/DECISIONS.md
- docs/DESIGN.md
- docs/PROGRESS.md
- docs/CONTEXT_COMPATIBILITY.md
- docs/DATA_MODEL.md
- docs/OCR_PIPELINE.md
- docs/NORMALIZATION.md
- docs/QUALITY_METRICS.md

## Python
Use uv + project .venv + shared uv cache.

## Work discipline
Prompt → inspect target context → plan → implement small change → test →
benchmark when relevant → reviewer → docs → PROGRESS.
```

### 19.2. Rules

`rules/receipt-data.md`:
- immutable raw input;
- provenance;
- Decimal;
- unknown data preservation.

`rules/ocr-quality.md`:
- bbox/confidence mandatory;
- raw OCR preserved;
- preprocess profiles versioned;
- OCR backend abstraction;
- golden fixtures.

`rules/parser-invariants.md`:
- parser не мутирует OCR;
- unknown сохраняется;
- arithmetic reconciliation;
- adapter boundary.

`rules/normalization.md`:
- fuzzy score != truth;
- значимые product attributes;
- thresholds;
- manual review;
- alias provenance.

`rules/privacy.md`:
- raw gitignored;
- fixtures anonymized;
- cloud off by default;
- sensitive logs forbidden.

`rules/context-loading.md`:
- target docs only;
- no all-prompts/all-agents load;
- compatibility audit before new automation.

### 19.3. Project-specific subagents

Создавать только domain specialists:

1. `receipt-ocr-specialist`
   - imaging;
   - OCR;
   - layout;
   - OCR benchmark.

2. `receipt-parser-specialist`
   - store adapters;
   - parser;
   - numeric reconciliation.

3. `product-normalization-specialist`
   - aliases;
   - candidate generation;
   - scoring;
   - false merge/split analysis.

4. `receipt-data-quality-specialist`
   - labeled fixtures;
   - metrics;
   - error taxonomy;
   - regression dataset.

**Не создавать generic QA/architect/reviewer/security/docs agents локально, если они уже есть глобально.**

### 19.4. Skills

`receipt-ocr-investigation`:
- target fixture/image;
- compare preprocess variants;
- OCR boxes;
- error classification;
- minimal fix;
- regression fixture.

`receipt-parser-debug`:
- использовать, когда OCR хороший, но структура распарсилась неверно.

`product-normalization-review`:
- false merge/split;
- aliases;
- score explanation.

`receipt-quality-report`:
- OCR/parser/normalization metrics;
- failures by shop;
- regressions;
- top error classes;
- review rate;
- Markdown + JSON report.

Большие отчёты сохранять в файл; parent agent получает findings-first summary.

### 19.5. Hooks

Project hook по умолчанию не активируется.

Допустимый доменный hook:

```text
check_receipt_fixture_privacy.py
```

Он ищет в tracked fixtures потенциально реальные:
- телефоны;
- card-like последовательности;
- fiscal IDs/URLs;
- email;
- loyalty IDs.

Если глобальный DLP/privacy hook уже делает то же — локальный не регистрировать.

### 19.6. MCP

**Baseline: новых project-specific MCP нет.**

MCP можно добавить только через ADR:

```text
problem
→ почему обычных tools недостаточно
→ permissions/context cost/security
→ fallback
→ decision
```

---

---

## 54. Финальная модель контекста

```text
GLOBAL AI DEV TEAM
├─ generic roles
├─ Git workflow
├─ security baseline
├─ generic hooks
├─ global MCP
├─ global skills
└─ common DoD
        ↓
RECEIPT SCANNER PROJECT DELTA
├─ receipt invariants
├─ OCR rules
├─ parser rules
├─ normalization rules
├─ privacy rules
├─ domain specialists
└─ canonical project docs
        ↓
TASK-SPECIFIC CONTEXT
├─ one target module
├─ one relevant skill
├─ current stage
├─ relevant ADR only
└─ relevant fixtures only
```

Это позволяет не конфликтовать с уже установленной AI Dev Team и не перегружать контекст.

---

---

## 55. Pre-PR / Stage checklist

```text
[ ] protected branch workflow соблюдён
[ ] scope = current stage
[ ] global automation не продублирована
[ ] tests проходят
[ ] regression fixture добавлен при bugfix
[ ] quality metrics проверены
[ ] benchmark есть при optimization
[ ] raw receipts/secrets отсутствуют
[ ] money != float
[ ] OCR provenance сохранён
[ ] low-confidence не скрыт
[ ] DB остаётся canonical source
[ ] Excel остаётся export
[ ] ARCHITECTURE обновлена при boundary change
[ ] DECISIONS обновлён при ADR
[ ] DESIGN обновлён при UI change
[ ] PROGRESS обновлён
[ ] experimental feature имеет fallback
```

---

---

## 56. Первый промпт, который стоит дать Codex

```text
Выполни PROMPT 00 — Context Compatibility Audit.

У меня уже установлена глобальная AI Dev Team / архив «АВТОМАТИЗАЦИЯ КОНТЕКСТА».
Ничего глобального не переустанавливай и не дублируй.
Определи только локальные deltas, необходимые Receipt Scanner UA.
Обнови docs/CONTEXT_COMPATIBILITY.md и остановись после Stage 00.
```

---
