# Ranked Todo List
*Sorted from least to most complex (work + risk)*

---

## Tier 1 - Simple

### 1. Overview Screen Bar Chart Selection
**Complexity:** Low | **Risk:** Low

**Summary:** When tapping on a day's bar chart in the overview screen, highlight that day and update the existing text display to show that day's data instead of today's.

**Subtasks:**
- [ ] Add state variable to track selected day (default to today)
- [ ] Add tap gesture detector to each day's bar chart column
- [ ] Add visual highlight (background color) to selected day's column
- [ ] Update text display to read from selected day's data instead of hardcoded "today"
- [ ] Reset selection to today when leaving/returning to overview screen

---

### 2. Remember Last Logged Quantity/Unit
**Complexity:** Low | **Risk:** Low

**Summary:** When a food appears in search results, default its quantity and unit to whatever was last logged for that food. Code for remembering unit may already exist (`getLastLoggedUnit`) but needs verification/fixing. Quantity memory needs to be added.

**Subtasks:**
- [ ] Investigate why `getLastLoggedUnit` may not be working
- [ ] Fix unit memory if broken
- [ ] Add `getLastLoggedQuantity` to DatabaseService
- [ ] Store last logged quantity when logging a portion
- [ ] Update SearchResultTile to use last logged quantity as default
- [ ] Handle case where food has never been logged (use standard defaults)

---

### 3. Quick Macro Fill
**Complexity:** Low | **Risk:** Low

**Summary:** After selecting a food, provide a way to calculate exactly how many grams would hit the user's remaining quota for a specific macro (calories, protein, fat, carbs, or fiber).

**Subtasks:**
- [ ] Add UI element (button/menu) on quantity edit screen to trigger macro fill: maybe a button to the left of the Minus Container button
- [ ] Show picker for which macro to fill (calories, protein, fat, carbs, fiber): maybe just use the selected target that already exists below ("unit" doesn't make sense, so maybe if it's selected then nothing should happen? or maybe a popup saying to select a valid macro?)
- [ ] Calculate: `grams_needed = remaining_macro / food_macro_per_gram`
- [ ] Pre-fill the quantity field with calculated grams: seems like, we should also either auto select the grams unit, or prefill with the quantity that's right for the selected unit (if banana is selected, and a banana is 50 grams, and 25 grams are needed to hit target, then fill with 0.5 if banana is selected), I don't  know which is better, but forcing grams would be simpler to impliment so...
- [ ] Handle edge cases: macro is 0 per gram, remaining is negative

---

### 4. Manual Food Creation UX
**Complexity:** Low | **Risk:** Low

**Summary:** Improve the flow for manually creating foods from nutrition labels. Instead of requiring per-100g values, let user enter portion-based info and auto-calculate.

**Subtasks:**
- [ ] Redesign food creation flow:
  1. Enter portion name (e.g., "1 bar", "1 cup") (quantity and name should be seperate fields): maybe default to "1 serving"
  2. Enter grams per portion
  3. Enter macros per portion
  4. Auto-calculate and display per-100g values (is there actually any value in displaying these values to the user during the food creation process?)
- [ ] Add ability to define additional portion sizes after initial creation
- [ ] Update UI to make the flow clear and intuitive
- [ ] Ensure backwards compatibility with existing food editing

---

## Tier 2 - Moderate

### 5. Numeric Formatting
**Complexity:** Medium | **Risk:** Low

**Summary:** Replace scattered `toStringAsFixed(0)` calls with a cleaner, centralized solution. Need strategy for when decimals should appear (e.g., 0.5 apples should show decimal, but 52 calories shouldn't).

**Subtasks:**
- [ ] Audit all `toStringAsFixed` calls in codebase
- [ ] Define formatting rules:
  - Quantities with non-gram units: show 1 decimal if fractional
  - Gram quantities: no decimals
  - Macro totals (calories, protein, etc.): no decimals
  - Per-100g values: context-dependent
- [ ] Create utility function(s) or extension method for consistent formatting
- [ ] Consider `package:intl` NumberFormat vs custom solution
- [ ] Replace all scattered calls with centralized solution
- [ ] Test edge cases (0.5, 0.05, large numbers)

---

### 6. Calculator Inputs
**Complexity:** Medium | **Risk:** Medium

**Summary:** Allow basic math expressions (+, -, *, /) in all numeric input fields. Evaluate expression on blur (when focus leaves field).

**Subtasks:**
- [ ] Create or reuse math expression parser (note: `MathEvaluator` may already exist based on tests)
- [ ] Create wrapper widget or mixin for numeric TextFields
- [ ] On blur: parse input, evaluate if it's an expression, replace with result
- [ ] Handle invalid expressions gracefully (show error or revert)
- [ ] Apply to all numeric inputs (quantity, macros, serving sizes, etc.)
- [ ] Decide: should goals/targets screens also have this? (user said "maybe not setup page")
- [ ] Test with various expressions: `100+50`, `3*4`, `10/3`, `1+2*3`

---

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
- [ ] Database changes:
  - Add `display_order` column to recipe_items table
  - Add `dump_order` column to recipe_items table
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

**Summary:** Implement barcode scanning to search for foods. Also add ability to add/edit barcodes on existing foods.

**Subtasks:**
- [ ] Add barcode scanning library (e.g., `mobile_scanner` - already in pubspec?)
- [ ] Implement camera permission handling
- [ ] Create barcode scan UI on Search screen (replace placeholder tab)
- [ ] Integrate with food database API that supports barcode lookup (OpenFoodFacts?)
- [ ] Handle: barcode found, barcode not found, scan error
- [ ] Add barcode field to Food model (if not present)
- [ ] Add barcode input/edit to Food Edit screen
- [ ] Allow scanning to add barcode to existing food
- [ ] Consider: save barcode-to-food mapping locally for faster future lookups

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
