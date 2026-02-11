# Meal of Record: Architectural Action Plan

## 1. Overview & Core Principles

This document outlines the data architecture and implementation plan for the Meal of Record application.

*   **Stability & Immutability:** A logged entry must never change. This is handled by creating "snapshots" of food data at the time of logging.
*   **Performance:** Local-first approach using `drift` for SQLite database management.
*   **Maintainability:** Deeply tied to the `llm_context.md` for functional requirements.

## 2. System Architecture: The "Live vs. Reference" Model

The app uses two separate databases to ensure reference data can be updated without affecting user history.

*   **`reference.db` (The Library):** Read-only, bundled as an asset. Contains curated USDA data.
*   **`live.db` (The User's Journal):** Writable, contains user foods, recipes, and **logged snapshots** of reference items.

## 3. Implementation Status (Database Schema)

| Table | Status | Notes |
|---|---|---|
| `foods` | [x] Implemented | Stores user-created and cached food items. |
| `food_portions` | [x] Implemented | Defines units (cups, grams, etc.) for foods. |
| `recipes` | [x] Implemented | Container for ingredients and recipe macros. |
| `recipe_items` | [x] Implemented | Link table for ingredients (food or other recipes). |
| `logged_foods` | [x] Implemented | **Immutability layer**. Stores snapshots of food macros at time of log. |
| `logged_food_servings`| [x] Implemented | Stores snapshots of unit definitions for logged foods. |
| `logged_portions` | [x] Implemented | The actual consumption logs linking to `logged_foods`. |
| `categories` | [x] Implemented | For grouping recipes. |

## 4. Current Implementation & Next Steps

Based on the refined `llm_context.md`, the next phase focuses on UI consolidation and logic accuracy.

### Phase 5: UI Consolidation & Logic Refinement (IN PROGRESS)

**Task 5.1: The Quantity Edit Screen**
*   **Goal:** Replace `PortionEditScreen` and `IngredientEditScreen` with a single, highly configurable `QuantityEditScreen`.
*   **Requirement:** Support "Day" context (Log/Log Queue) and "Recipe" context (Ingredients).
*   **Contextual Logic:** Dynamically switch between daily macro targets and recipe macro totals. Support the "Total" vs "Per Serving" toggle for recipes.

**Task 5.2: Recipe Logic Enhancements**
*   **Total Weight Override:** Add input for final cooked weight in Recipe Edit Screen to account for non-tracked additions (water).
*   **Recipe Macro targets:** Adjust visualization to allow for "no target" (optional bars).
*   **Dump Functionality:** (Refinement) Ensure "Dump" correctly populates the Log Queue with calculated servings.

**Task 5.3: Search UI Improvements**
*   **Log Indicators:** Add a subtle indicator (icon or note) to search results to distinguish items already in the user's `logged_foods` table.
*   **Dynamic Buttons:** Update search result buttons to show "Add" vs "Update" based on whether the item is already in the current context.

## 5. Deployment & Maintenance
*   **Migration Plan:** Future schema changes must use `drift` migration paths to preserve `live.db` data.
*   **Data Pruning:** (Future) Periodic cleanup of `live.db` for unused/unlogged cache items.
