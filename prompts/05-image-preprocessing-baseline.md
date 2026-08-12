# 30. PROMPT 05 — Image Preprocessing Baseline

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
- clean receipt.

### DoD
- profile version сохранён;
- clean fixture существенно не ухудшается;
- rebuild работает.

---
