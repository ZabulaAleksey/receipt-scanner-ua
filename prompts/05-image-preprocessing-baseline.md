# 30. PROMPT 05 — базовая предварительная обработка изображений

```text
Реализуй versioned profile receipt-default-v1.

orientation → boundary → perspective → crop → grayscale →
illumination → CLAHE → denoise → deskew → resize.

Сохраняй OCR-ready variants:
RAW / ENHANCED_GRAY / ADAPTIVE_THRESHOLD / HIGH_CONTRAST.

Каждый transform — отдельная тестируемая функция.
Processed/cache должен быть rebuildable.
```

### Tests
- rotation;
- perspective;
- low contrast;
- shadow;
- чистый чек.

### DoD
- версия профиля сохранена;
- clean fixture существенно не ухудшается;
- rebuild работает.

---
