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

## Tier 3 - Complex

### 8. Recipe Ingredient Reordering
**Complexity:** High | **Risk:** Medium

**Summary:** Allow reordering recipe ingredients with TWO separate order concepts: display order (how they appear on edit screen) and dump order (order when dumping to log queue).

**Subtasks:**
- [ ] Migration for existing data (set both orders to current implicit order)
- [ ] Recipe edit screen UI:
  - Add drag-to-reorder for display order
  - Add separate control for dump order (could be a secondary drag list, or number inputs)
- [ ] Update recipe dump logic to use `dump_order`
- [ ] Update recipe display logic to use `display_order`
- [ ] Consider UX: maybe a toggle to "make dump order same as display order" for simplicity
- [ ] Test: reorder display, verify dump order unchanged; reorder dump, verify display unchanged

---

### 9. Complete Backups Audit
**Complexity:** High | **Risk:** Medium (unknown scope)

**Summary:** Audit the backup system to ensure ALL app state is captured for full restoration. Currently unknown what's missing.

**Subtasks:**
- [ ] List all app state that should be backed up:
  - [ ] Live database (foods, recipes, logs, portions)
  - [ ] Images (local storage)
  - [ ] Image references/paths
  - [ ] Goals/targets
  - [ ] User preferences/settings
  - [ ] Recipe data
  - [ ] Weight history
  - [ ] Any other persistent state
- [ ] Audit current backup implementation
- [ ] Identify gaps (what's NOT being backed up)
- [ ] Implement missing backup components
- [ ] Implement missing restore components
- [ ] Test full backup/restore cycle on fresh install
- [ ] Document backup format

---

### 10. Barcode Search
**Complexity:** High | **Risk:** High

**Summary:** Implement barcode scanning to search for foods. Also add ability to add/edit barcodes on existing foods and for new foods via picture.

**Subtasks:**
- [ ] Add a barcode scanning library (e.g., `mobile_scanner` - already in pubspec?)
- [ ] Implement camera permission handling
- [ ] Create barcode scan UI on Search screen (replace placeholder tab)
- [ ] Integrate with food database API that supports barcode lookup (OpenFoodFacts?)
    - should default to local first, then non-local
    - deally looks up food, but can just return a name
- [ ] Handle: barcode found, barcode not found, scan error
- [ ] Add barcode field to Food model (if not present)
- [ ] Add barcode input/edit to Food Edit screen
- [ ] Allow scanning to add barcode to existing food

---

## Tier 4 - Very Complex

### 11. TDEE/Maintenance Calculations
**Complexity:** Very High | **Risk:** High

**Summary:** Calculate maintenance calories based on 2 weeks of logged data. Handle cold boot (not enough data), dirty data (missed days), and Monday update boundaries. Override UI already exists.

**Subtasks:**
- [ ] Define data requirements:
  - Minimum days needed for calculation (14?)
  - How to handle gaps in logging: maybe we just estimate based on a best fit curve
  - What constitutes "sufficient" data for a day: we assume that the day's accurate unless it's empty with no "fasted" note
- [ ] Create constant for required days (single source of truth)
- [ ] Cold boot handling:
  - Use initial estimates until Monday after sufficient data collected
  - Track when sufficient data threshold is reached
- [ ] Dirty data handling:
  - Define "missed day" (no logs? partial logs?)
  - Strategy: skip missed days? use averages? require X of Y days?: we could also estimate based on a best fit curve if that works better depending on the behavior of the function/equation
- [ ] Monday boundary logic:
  - Only recalculate on Mondays
  - Store last calculation date
- [ ] TDEE calculation algorithm:
  - Average daily calories consumed
  - Weight change over period
  - Calculate actual TDEE from weight delta
- [ ] Extensive unit tests for all edge cases
- [ ] Integration tests for week-over-week scenarios

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
