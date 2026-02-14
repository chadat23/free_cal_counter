### 7. Image Format Support
**Complexity:** Medium | **Risk:** Medium

**Summary:** Support common image formats beyond JPEG (PNG, WebP, GIF, etc.) from both internet downloads and camera roll. Preserve PNG transparency where applicable.

**Subtasks:**
- [ ] Audit current image handling in `ImageStorageService`
- [ ] Test which formats Flutter's Image widget already supports natively
- [ ] Determine if format conversion is needed or if multi-format storage works
- [ ] If converting: convert non-JPEG to JPEG on save (loses transparency)
- [ ] If preserving: store original format, update file extension handling
- [ ] Handle PNG transparency in display (ensure grey background doesn't show through)
- [ ] Test with: JPEG, PNG (with transparency), WebP, GIF (static)
- [ ] Update image picker to accept all common formats

---

### 12. Food Recommendations
**Complexity:** Very High | **Risk:** High

**Summary:** Recommend a single food from user's previously logged foods that would help hit a specific remaining macro target.

**Subtasks:**
- [ ] Define recommendation trigger UI:
  - Button: "Recommend food to finish my [macro]"
  - Macro selector (calories, protein, fat, carbs, fiber)
- [ ] Query logged foods:
  - Get distinct foods user has logged
  - Calculate each food's macro density (macro per gram or per typical serving)
- [ ] Recommendation algorithm:
  - Filter to foods that can meaningfully contribute to target macro
  - Rank by: macro density, frequency of use, recency
  - Avoid recommending huge quantities (cap at reasonable serving)
- [ ] Display recommendation:
  - Show food name, suggested quantity, resulting macro contribution
  - Allow user to accept (add to queue) or get another recommendation
- [ ] Handle edge cases:
  - No logged foods
  - No foods match macro need
  - Remaining macro is very small or negative
- [ ] Future consideration: structure for multi-food meal recommendations (don't bake single-food assumptions too deep)

---

### 13. AI Food Creation
**Complexity:** Very High | **Risk:** Very High

**Summary:** Use AI/OCR to create foods from photos of nutrition labels and barcodes. Requires camera integration, OCR, barcode scanning, and API credential management.

**Subtasks:**
- [ ] Research/decide on approach:
  - OpenRouter vs direct OpenAI API vs other
  - OCR: AI-based vs dedicated OCR library
  - Credential storage best practices (secure storage, not plain text)
- [ ] Settings screen for API credentials:
  - API key input (masked)
  - Model selection (if configurable)
  - Test connection button
- [ ] Photo capture flow:
  1. Take photo of product (for icon)
  2. Take photo of nutrition label
  3. Take photo of barcode
- [ ] OCR/AI processing:
  - Send nutrition label image to AI
  - Parse response for: serving size, calories, protein, fat, carbs, fiber
  - Handle parsing errors gracefully
- [ ] Barcode processing:
  - Scan barcode from image
  - Associate with created food
- [ ] Review/edit screen:
  - Show extracted values
  - Allow user to correct any mistakes
  - Confirm and save
- [ ] Error handling throughout (network errors, parsing failures, etc.)
- [ ] Consider: offline fallback? Queue for later processing?

---

## Completed Items (for reference)

- [x] Imperial/Metric Toggle - settings label update
- [x] Recipe Ingredient Images - FoodImageWidget now properly shows emojis/images
