# Roadmap

# 24. Stage Map

```text
00 Context Compatibility Audit
01 Repository Foundation
02 Dataset + Privacy Baseline
03 Domain Model + DB Schema
04 Ingestion + Deduplication
05 Image Preprocessing Baseline
06 OCR Baseline
07 OCR Evaluation + Multi-Profile Selection
08 Layout Reconstruction
09 Store Detection + Adapter Framework
10 Receipt Parser Core
11 Numeric Parsing + Reconciliation
12 Product Normalization Baseline
13 Human Review + Alias Learning
14 Price History Persistence
15 Arrow/Parquet Analytical Layer
16 Excel Export
17 Quality Metrics + Regression Harness
18 CLI Workflow + Batch Processing
19 Performance / Caching / Parallelism
20 Optional Local Review UI
21 ONNX / NPU Research Path
22 Security / Failure Recovery / Backups
23 Packaging + Final Acceptance
```

---

---

## 50. Рекомендуемый порядок MVP

```text
00 compatibility
01 foundation
02 dataset
03 database
04 ingestion
05 preprocessing
06 OCR
08 layout
09 adapters
10 parser
11 reconciliation
12 normalization
13 review
14 history
16 Excel
17 quality
18 batch CLI
```

После этого уже есть полноценный полезный MVP.

Arrow/Parquet, UI, производительность и ONNX/NPU — после стабильного базового варианта.

---

---

## 51. Определение MVP

MVP готов, когда:

- можно положить локальную папку чеков;
- `receipt scan` регистрирует изображения;
- `receipt process` выполняет pipeline;
- минимум ATB + второй магазин имеют adapters;
- сомнительные строки идут в review;
- пользователь исправляет товар/цену;
- одинаковый товар связывается между несколькими датами;
- Excel содержит историю цен по новым столбцам;
- повторный запуск не создаёт duplicates;
- failures видны;
- отчёт о качестве строится;
- всё работает local-first.

---

---

## 52. Post-MVP

Не внедрять раньше времени:

- mobile app;
- объединение нескольких фотографий длинного чека;
- распознавание штрихкодов;
- проверка QR и фискальных данных;
- обнаружение аномалий цен;
- графики и dashboard;
- классификатор категорий;
- сопоставление товаров по embeddings;
- локальная нормализация LLM/VLM;
- ONNX/NPU;
- серверный режим PostgreSQL;
- импорт электронных чеков;
- зашифрованная облачная синхронизация.

Каждая новая технология:

```text
problem
→ baseline
→ measurable need
→ candidate
→ security/privacy
→ fallback
→ tests
→ benchmark
→ ADR
→ implementation
```

---

---

## 53. Статусы технологий

### BASELINE
- Python
- uv
- OpenCV
- Pillow
- NumPy
- PaddleOCR abstraction
- Pydantic
- RapidFuzz
- SQLite
- SQLAlchemy
- Alembic
- PyArrow / Parquet
- openpyxl
- Typer
- Rich
- pytest / Hypothesis
- structured logging

### НЕОБЯЗАТЕЛЬНО ПОДДЕРЖИВАЕТСЯ
- PostgreSQL
- второй backend OCR
- локальный UI проверки
- параллельная обработка чеков

### RESEARCH
- оптимизация ONNX Runtime
- NPU
- local VLM
- сопоставление товаров с помощью embeddings/ML
- обнаружение аномалий
- продвинутая предварительная обработка на GPU

---
