# Receipt Scanner UA - local instructions

Before working here, read `~/codex-workspace/AGENTS.md`. This project contains only receipt-processing-specific additions.

## Project invariants

- Windows-first, Python, and local-first; raw receipts and secrets are never committed.
- The database is canonical state; Excel is an export.
- Preserve raw OCR output and provenance. Low-confidence results require review.
- Use `Decimal` for money and make product merges explainable.
- Keep a CPU OCR path and require a flag, fallback, and benchmark for experimental technology.
- Put retailer-specific behavior behind adapters.

## Context routing

- Start with `docs/AI_STATUS.md`, then open one relevant architecture, data-model, OCR, normalization, or quality document.
- Use only the current stage prompt from `prompts/` when stage work is requested.
- Do not load the full roadmap, prompt collection, fixtures, rules tree, SPEC set, or `LEARNING_LOG.md` together.
