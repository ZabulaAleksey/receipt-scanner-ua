# Архитектура Receipt Scanner UA

## Текущее направление

Архитектура развивается тремя слоями зрелости: UX MVP на fixtures, Functional MVP с local persistence/camera/OCR и Production MVP с необязательными online services. Native client, processing core и optional cloud являются отдельными границами.

- Windows/Python — baseline processing core/CLI, не единственный client stack.
- Android/iOS shell R03 реализуется на Flutter по ADR-004; Windows runner используется только для локальной compile/visual verification. PWA не является целевым mobile client.
- OCR providers, включая Text Recognition Core и PaddleOCR, подключаются через port/adapter boundary.
- Украина реализуется Region Pack; merchant adapters улучшают generic pipeline, но неизвестный merchant не блокирует extraction.
- `LOCAL_ONLY` — полноценный baseline. Sync/account/cloud OCR не являются dependency consumer core.
- B2B — future extension и не влияет на consumer domain до отдельного approval.

## R03 mobile shell boundary

```text
bundled synthetic fixtures
→ FixtureScenarioPort / fixture adapter
→ use cases + prototype in-memory store
→ immutable app state
→ Flutter screens/navigation
```

R03 создаёт один `mobile/` package с Android/iOS product targets и Windows validation runner. UI не читает fixture JSON напрямую и не импортирует platform plugins. `CameraCapturePort`, `ReceiptRepository`, `ReviewQueuePort` и `SettingsPort` имеют только deterministic prototype adapters. Real camera, OCR, database, network, auth, billing и sync остаются за границей этапа.

Windows build подтверждает компилируемость общего Flutter shell, но не заменяет Android/iOS build или product E2E. Android остаётся `UNVERIFIED` до установки Android SDK, iOS — до macOS/Xcode.

## 1. Цели продукта

Система должна:

1. принимать десятки/сотни фотографий чеков;
2. находить дубликаты;
3. улучшать изображение перед OCR;
4. распознавать украинский/русский/смешанный текст;
5. сохранять OCR-текст, confidence и координаты;
6. определять магазин, дату, время, итог, скидки;
7. извлекать товары, количество/вес, цену за единицу и сумму строки;
8. проверять арифметическую согласованность;
9. сопоставлять один и тот же товар между разными чеками;
10. отправлять сомнительные совпадения на ручную проверку;
11. хранить историю цен как данные, а не только как Excel;
12. экспортировать Excel, где строки — товары, а новые даты/чеки — новые столбцы цен;
13. сохранять полный audit trail;
14. позже позволять подключить ONNX/NPU/локальные AI-модели без разрушения CPU baseline.

---

---

## 2. Архитектурные инварианты

- **Local-first:** облачный OCR/LLM не обязателен.
- **Raw receipts не коммитятся в Git.**
- **SQLite/PostgreSQL = каноническое изменяемое состояние.**
- **Excel = report/export, не база данных.**
- **Raw OCR никогда не перезаписывается нормализованным текстом.**
- **Деньги хранятся через Decimal/fixed precision, не float.**
- **Low-confidence результат не принимается молча.**
- **Специфичная для магазина логика находится в адаптерах.**
- **Базовый вариант на CPU обязателен. GPU/NPU — только как backend необязательных возможностей.**
- **Любое ускорение требует benchmark, теста корректности и fallback.**
- **Любое новое архитектурное решение: ADR в `docs/DECISIONS.md`.**
- **Любая OCR/parser/normalization ошибка после исправления по возможности превращается в regression fixture.**

---

---

## 5. Целевая структура Functional MVP

Блок ниже — планируемая структура поздних этапов, а не описание уже существующих файлов. R01 создаёт только project context; каталоги product code, dependencies, local agents/skills/hooks/config добавляются лишь отдельными одобренными этапами и только при подтверждённой необходимости.

```text
receipt-scanner-ua/
├─ AGENTS.md
├─ README.md
├─ pyproject.toml
├─ uv.lock
├─ .python-version
├─ .env.example
├─ .gitignore
│
├─ docs/
│  ├─ ARCHITECTURE.md
│  ├─ DECISIONS.md
│  ├─ DESIGN.md
│  ├─ AI_PLAN.md
│  ├─ AI_STATUS.md
│  ├─ PROGRESS.md
│  ├─ ROADMAP.md
│  ├─ PROMPTS.md
│  ├─ CONTEXT_COMPATIBILITY.md
│  ├─ DATA_MODEL.md
│  ├─ OCR_PIPELINE.md
│  ├─ NORMALIZATION.md
│  ├─ EXCEL_FORMAT.md
│  ├─ QUALITY_METRICS.md
│  ├─ SECURITY.md
│  ├─ PRIVACY.md
│  └─ PERFORMANCE.md
│
├─ rules/
│  ├─ receipt-data.md
│  ├─ ocr-quality.md
│  ├─ parser-invariants.md
│  ├─ normalization.md
│  ├─ privacy.md
│  └─ context-loading.md
│
├─ skills/
│  ├─ receipt-ocr-investigation/SKILL.md
│  ├─ receipt-parser-debug/SKILL.md
│  ├─ product-normalization-review/SKILL.md
│  └─ receipt-quality-report/SKILL.md
│
├─ agents/
│  ├─ receipt-ocr-specialist.toml
│  ├─ receipt-parser-specialist.toml
│  ├─ product-normalization-specialist.toml
│  └─ receipt-data-quality-specialist.toml
│
├─ hooks/
│  ├─ README.md
│  └─ check_receipt_fixture_privacy.py
│
├─ config/
│  ├─ default.toml
│  ├─ ocr.toml
│  ├─ normalization.toml
│  └─ stores/
│     ├─ atb.toml
│     ├─ silpo.toml
│     ├─ varus.toml
│     ├─ novus.toml
│     ├─ fora.toml
│     └─ generic.toml
│
├─ src/receipt_scanner/
│  ├─ cli.py
│  ├─ settings.py
│  ├─ domain/
│  ├─ ingestion/
│  ├─ imaging/
│  ├─ ocr/
│  ├─ stores/
│  ├─ parser/
│  ├─ normalization/
│  ├─ review/
│  ├─ persistence/
│  ├─ analytics/
│  ├─ export/
│  ├─ quality/
│  └─ observability/
│
├─ tests/
│  ├─ unit/
│  ├─ integration/
│  ├─ acceptance/
│  ├─ regression/
│  ├─ property/
│  └─ performance/
│
├─ fixtures/
│  ├─ synthetic/
│  ├─ anonymized/
│  ├─ expected/
│  └─ dictionaries/
│
├─ data/
│  ├─ raw/          # gitignored
│  ├─ processed/    # gitignored
│  ├─ cache/        # gitignored
│  ├─ db/           # gitignored
│  └─ exports/
│
└─ scripts/
   ├─ benchmark_ocr.py
   ├─ evaluate_dataset.py
   ├─ rebuild_alias_index.py
   └─ generate_synthetic_receipts.py
```

---

---

## 6. Подробный стек технологий

### Среда выполнения и зависимости

- Python;
- `uv` — окружение, зависимости и lockfile;
- `pyproject.toml`;
- `uv.lock`;
- отдельный `.venv` проекта + общий cache `uv`.

Не использовать одновременно Poetry/Pipenv/Conda как второй source of truth.

### Компьютерное зрение

- OpenCV (`opencv-python-headless`);
- Pillow;
- NumPy.

Задачи:
- orientation;
- граница чека;
- коррекция перспективы;
- crop;
- grayscale;
- нормализация освещения;
- CLAHE;
- denoise;
- deskew;
- варианты пороговой обработки;
- resize.

### OCR

**Первый Functional MVP candidate:** PaddleOCR с поддержкой украинского языка через общий OCR port. Конкретный provider не является зависимостью domain/application layers.<br>
OCR backend обязан возвращать:

```text
text
confidence
polygon/bbox
model/backend/version
runtime metadata
```

Абстракция:

```python
class OCRBackend(Protocol):
    def recognize(self, image, options) -> OCRResult: ...
```

Parser не должен импортировать PaddleOCR напрямую.

### Разбор и валидация

- Pydantic;
- `re`;
- `Decimal`;
- `datetime`;
- специфичные для магазина правила и адаптеры;
- арифметическая сверка.

### Сопоставление товаров

- нормализация Unicode;
- собственные правила единиц и сокращений;
- RapidFuzz как один из сигналов;
- словарь aliases;
- признаки бренда, размера и единицы;
- очередь ручной проверки.

### Persistence

MVP:
- SQLite;
- SQLAlchemy;
- Alembic.

Scale-out позже:
- PostgreSQL, если появятся сервер и конкурентная многопользовательская работа.

### Аналитический слой

- Apache Arrow / PyArrow;
- Parquet.

```text
SQLite/PostgreSQL = canonical mutable state
Arrow/Parquet     = analytical/cache/interchange
Excel             = report/export
```

### Excel

- openpyxl.

### CLI

- Typer;
- Rich.

### Тестирование и качество

- pytest;
- pytest-cov;
- Hypothesis;
- pytest-benchmark;
- эталонные fixtures;
- регрессионные fixtures;
- ruff;
- type checker — тот, который уже принят в глобальной AI Dev Team.

---

---

## 7. Domain model

### ReceiptImage

```text
id
original_path
content_hash
width
height
mime_type
preprocess_profile
created_at
```

### OCRRun

```text
id
image_id
backend
backend_version
model
language
config_hash
duration_ms
status
```

### OCRBlock

```text
id
ocr_run_id
text
confidence
polygon
reading_order
```

### Receipt

```text
id
image_id
shop_id
purchased_at
receipt_number?
fiscal_id?
currency
subtotal?
discounts_total?
total?
parse_status
parser_version
```

### RawItemLine

```text
id
receipt_id
source_block_ids
raw_text
parsed_name
quantity?
unit?
unit_price?
line_total?
discount?
parser_confidence
```

### CanonicalProduct

```text
id
canonical_name
brand?
size_value?
size_unit?
barcode?
category?
```

### ProductAlias

```text
id
canonical_product_id
normalized_alias
shop_id?
source
confidence
approved_by_user
```

### PurchaseItem / PriceObservation

```text
receipt_id
canonical_product_id?
raw_item_line_id
quantity
unit
unit_price
line_total
discount
normalization_confidence
review_status
```

### ReviewItem

```text
entity_type
entity_id
reason
candidate_payload
confidence
status
resolution
```

### Correction

```text
entity_type
entity_id
field
old_value
new_value
source=user|rule|migration
created_at
```

---

---

## 8. Основной pipeline

```text
Photo
  ↓
Ingestion
  ↓
SHA-256 / dedupe
  ↓
Image preprocessing profiles
  ↓
OCR + boxes + confidence
  ↓
Layout reconstruction
  ↓
Store detection
  ↓
Receipt parser
  ↓
Numeric reconciliation
  ↓
Product normalization
  ↓
confidence gate
  ├─ high → canonical DB
  └─ low  → review queue → correction/alias → canonical DB
  ↓
Price history
  ├─ Arrow/Parquet analytics
  └─ Excel export
```

---

---

## 9. Предварительная обработка изображений

Версионируемый профиль:

```text
receipt-default-v1
```

Не использовать один destructive output для всех чеков. Поддерживать варианты:

```text
RAW
ENHANCED_GRAY
ADAPTIVE_THRESHOLD
HIGH_CONTRAST
```

OCR evaluator может выбирать лучший вариант по нескольким сигналам.

Случаи отказа:
- blur;
- shadow;
- glare;
- perspective;
- cropped edge;
- long receipt;
- выцветание термобумаги;
- повёрнутое изображение.

---

---

## 10. OCR contract

```text
OCRResult
- backend
- model
- language
- blocks[]
- full_text
- mean_confidence
- duration_ms
- config_hash
```

Parser получает не только `full_text`, но и geometry.

Raw OCR сохраняется неизменно для audit/regression.

---

---

## 11. Восстановление layout

OCR blocks группируются по:
- y overlap;
- baseline;
- x coordinate;
- gaps;
- приблизительная высота текста;
- правила перенесённых строк.

Результат:

```text
LogicalLine
- source_block_ids
- raw_text
- x_min/x_max
- y_center
- line_confidence
```

---

---

## 12. Архитектура адаптеров магазинов

```python
class StoreAdapter(Protocol):
    def detect_score(self, document) -> float: ...
    def parse_header(self, document): ...
    def classify_line(self, line): ...
    def parse_item(self, lines): ...
```

Первый набор:
- ATB;
- Сільпо;
- VARUS;
- NOVUS;
- Фора;
- Generic.

Новый магазин должен добавляться без изменения core parser.

---

---

## 13. Parser чеков

Типы строк:

```text
HEADER
SHOP_INFO
DATE_TIME
ITEM_NAME
ITEM_PRICE
ITEM_QTY_WEIGHT
DISCOUNT
SUBTOTAL
TOTAL
PAYMENT
TAX
FISCAL
FOOTER
UNKNOWN
```

`UNKNOWN` не удаляется.

Поддержать:
- `12,50` / `12.50`;
- `1 234,56`;
- `0,742 x 89,90`;
- `2 x 34,50`;
- скидки;
- цену по акции;
- перенос названия;
- цену/количество на соседней строке.

---

---

## 14. Арифметическая сверка

После parsing:

```text
qty × unit_price ≈ line_total
sum(item totals) - discounts ≈ receipt total
```

Несовпадение:
- не переписывает OCR молча;
- создаёт проблему качества;
- может быть сигналом при выборе между OCR candidates.

Tolerance конфигурируемый.

---

---

## 15. Нормализация товаров

Порядок:

```text
Unicode
→ lowercase
→ whitespace
→ punctuation
→ OCR-confusables
→ units
→ store abbreviations
→ alias lookup
→ candidate generation
→ scoring
→ confidence gate
```

Нельзя терять значимые признаки:
- бренд;
- масса/объём;
- жирность;
- вкус;
- сорт;
- pack count;
- `без цукру` и подобные свойства.

Пример score:

```text
score =
  w_name   * fuzzy_name
+ w_brand  * brand_match
+ w_size   * size_match
+ w_unit   * unit_match
+ w_alias  * known_alias
+ w_barcode* barcode_match
```

Thresholds:

```text
AUTO_ACCEPT
REVIEW
UNRESOLVED
```

Пороги определяются на labeled dataset.

Главная метрика риска — **false merge** разных товаров.

---

---

## 16. Review loop

CLI review должен показывать:
- ссылка на исходное изображение;
- OCR text;
- raw item;
- разобранные поля;
- товары-кандидаты;
- уверенность и доказательства.

Действия:
- выбрать канонический товар;
- создать новый product;
- исправить поле;
- skip;
- создать alias.

Alias scope:

```text
receipt-only correction
shop-specific alias
global alias
```

Не превращать каждую ручную правку в global rule.

---

---

## 17. Excel

### `Prices`

```text
Product ID | Product | Brand | Size | 2026-08-01 · ATB | 2026-08-03 · Сільпо | ...
```

Если несколько чеков одного магазина в один день:

```text
2026-08-03 · ATB
2026-08-03 · ATB #2
```

### Другие листы

- `Purchases` — источник отчёта в длинном формате;
- `Receipts`;
- `Products`;
- `Aliases`;
- `Review`;
- `Errors`;
- `Quality`;
- `Metadata`.

---

---

## 18. Метрики качества

### OCR
- CER;
- WER;
- точность числовых tokens;
- полнота обнаружения строк.

### Parser
- точность, полнота и F1 товаров;
- точность даты;
- точность итога;
- точность количества;
- точность цены за единицу.

### Нормализация
- top-1 accuracy;
- точность автоматического принятия;
- доля ложных объединений;
- доля ложных разделений;
- review rate.

### End-to-end
- доля пригодных чеков;
- ручные исправления на чек;
- секунд на чек;
- доля неудачно обработанных чеков.

---

---

## 57. Главное архитектурное правило качества

Не пытаться получить надёжность одним OCR.

```text
image quality
+ OCR confidence
+ geometry/layout
+ store knowledge
+ parser rules
+ arithmetic reconciliation
+ product history
+ fuzzy matching
+ human review
+ regression dataset
```

Если один сигнал ошибается, остальные должны помочь обнаружить ошибку, а не скрыть её.
