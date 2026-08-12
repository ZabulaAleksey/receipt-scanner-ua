# 41. PROMPT 16 — экспорт Excel

```text
Реализуй openpyxl export.

Sheets:
Prices, Purchases, Receipts, Products, Aliases, Review, Errors, Quality, Metadata.

Prices: rows=products; columns=date+shop.
Same date/shop multiple receipts → #2/#3.

Добавь freeze panes, filters, number formats, widths,
low-confidence highlighting и export metadata.
```

### DoD
- workbook открывается;
- expected sheets/cells проверяются тестом;
- несколько наблюдений не теряются;
- Excel строится только из canonical data.

---
