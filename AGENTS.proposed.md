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
