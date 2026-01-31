# Organized Feature Requests & Bugs
Sorted by complexity (least to most complicated) and grouped by functional area.

## 🟢 Low Complexity (Quick Wins)

1. **Refine Imperial/Metric Labels**
   - Update settings labels to "Use Imperial (lb)" and default the slider to "on".
   - Keep logic changes minimal to avoid regression risks.
   - *Complexity: 1*

Right now the app defaults to imperial units but in the settings it asks about metric, it seems mildly confusing, maybe, we just switch the default text to "Use Imperial (lb)" and then have the slider default to on. I don't care if the slider is on or off by default, I want to minimize how much logic is changed since there are associated risks, and I want to have pounds be in the label, so what I mentioned seems like a very simple way to achieve these goals but I'm open to other ideas.


2. **Standardize Decimal Formatting**
   - Replace redundant `toStringAsFixed(0)` calls with `package:intl` `NumberFormat('0')`.
   - Ensure consistent numeric display across the app.
   - *Complexity: 2*

While there may be exceptions, I want most if not all numeric values to default to showing zero decimal places. Right now there are tons of toStringAsFixed(0) calls and this seems messy. Is this an optimal solution? Would it be better to switch to package:intl.dart DumberFormat('0')? Is there a better way?


3. **Log Queue Edit Fix**
   - Fix the edit button for portions in the Log Queue when the food has never been logged before.
   - *Complexity: 3*

Once foods have been added to the Log Queue, the edit button on the side of the food/portion doesn't work if the food's never been logged before. I want to be able to still edit those portions in case I entered a wrong quantity or unit.


4. **Goal Update Synchronization**
   - Ensure the Overview screen targets update immediately when goals are modified in settings.
   - Currently, the goal page updates but the home screen requires a refresh/navigation.
   - *Complexity: 3*

When I update the goal, the goal page updates as expected and if I leave it and go back to it it is still updated, but the targets on the overview screen don't update.

5. **Recipe Ingredient Icons**
   - Fix the ingredient widgets in the Recipe Edit screen to show correct emojis/images instead of a generic icon.
   - *Complexity: 3*

When making recipes, the ingredient list ingredient widgets don't properly show emogies or pictures. They all just show a generic food icon. 

---

## 🟡 Medium Complexity (UI & UX)

6. **Extended Image Type Support**
   - Support common image types (PNG, etc.) from the internet.
   - Convert all non-JPEG inputs to JPEG during the downsizing/storage process.
   - *Complexity: 4*

I want to be able to handle more than just jpgs (I think that that's all we can do). This isn't worth dramatically complexifying things over, but it'd be nice to be able to handle all of the common image types found on the internet so that images can be downloaded and used without having to pay a lot of attention to format. And maybe that means we want to be able to display lots of image types, or maybe as part of the downsizing, we convert other image types to jpegs.


7. **Overview Chart Interaction**
   - Highlight the selected (tapped) day in the Overview bar charts.
   - Update the macro text column to reflect the selected day's data (default to today).
   - Ensure state is reset when leaving/returning to the screen.
   - *Complexity: 5*

Right now, on the overview screen, to the right of the bar charts there's the text, and I like it, but I'd like to make that whichever day's bar carts are selected, and the column that represents the selected (tapped on) day's bar charts should be somehow highlighted (maybe with a color behind them), that day should display in the text to the right. Also, it should default to today being highlighted and the selection state and be forgotten and reselected each time the overview screen is left/returned to.


8. **Food Image Update Persistence**
   - Fix the bug where food images sometimes stop updating once a food has been logged.
   - Ensure image updates propagate regardless of logging status.
   - *Complexity: 5*

While I haven't fully tracked down when it's fine and when it's not, pictures sometimes update but not always. It kind of seems like, if a food has not yet been logged, then updating its image works, but once it's logged, it no longer updates properly.

9. **Recipe Ingredient Reordering**
   - Implement drag-and-drop or position indices to reorder ingredients in the Recipe Edit screen.
   - Ensure this order is respected when "dumping" to the Log Queue.
   - *Complexity: 6*

I'd like to be able to reorder recipe ingredients, both on the recipe edit page as well as the order in which they get dumped into the Log Queue. I'm very open to how this could work, what the UI/UX should be (a position could be set in the ingredient update screen for something akin to a tab order, or they could be dragable on the recipe edit page), also I don't know how it'd be implemented. I suppose that two options could be to add an order field to the recipe table, or we could just resave the list of ingredients to the table, only with an updated order. Right now, there are times when ingredients are added in order A for any number of ingredients, when they're actually used in order B, and so it's nice to be able to rearrange them


10. **Smart Default Quantity/Unit**
    - Auto-populate the default quantity and unit for food search results based on the user's most recent log of that specific food.
    - *Complexity: 6*

For foods that have been logged as part of a portion, the next time they're a search result, the default quantity and unit should be the same as the what was last logged. So if food XYZ is logged as part of a portion for which the unit is "g" or "bars", and the quantity is 8 or 1.5, then the next time it's searched for, the default unit should be "g" or "bars" and the default quantity should be 8 or 1.5.


---

## 🟠 High Complexity (Logic & Systems)

11. **Unified Full Backup System**
    - Create a consistent backup mechanism (ZIP archive) containing the database AND the `app_images` folder.
    - Apply this to both manual exports and the Google Drive automated system.
    - *Complexity: 8*

Backups need to include everything to fully restore the state of the app, so the live db, images, image links/locations, goals/targets, recipes, etc. Off the top of my head, the state of the Consumed/Remaining buttons are all that I don't care about, and it's reasonable to have to reenable autobackups. And maybe I'm forgetting other stuff, but if anything's at all unclear, ask


12. **Robust TDEE & 14-Day Logic**
    - Reconcile maintenance calorie updates with a fixed 14-day window.
    - Implement "best fit estimation" (linear interpolation or averages) for missing data points in the window to prevent calculation fragility.
    - Centralize the window size constant (14 days).
    - *Complexity: 10*

I want to have the maintenance calories calculated based on 2 weeks of data, but right now TDEE stuff is being used to calculate targets after the first week, so somehow that needs to be reconciles. maybe we only start calculating goals based on it once we hit the monday that follows the collection of sufficient data for the calculations. Also, however many days we use (I previously said 14), that number needs to just be in one place so that if it's changed, the logic surrounding when to switch calculation methods always stays in line. also, we should have a way to override this stuff and just say "target these numbers" so even if the math's being dumb and not working right, the app will still be useful. Also, there's a lot of math here, we need a lot of thorough testing


13. **Barcode Integration**
    - Implement barcode scanning on the Search Screen.
    - Update Food Edit Screen and Models to support barcode storage/editing.
    - *Complexity: 11*

Implement the barcode based search on the Search screen. Related to this, there also needs to be an easy way to add a barcode to an existing food so the Food Edit screen needs to be update, not just the Search Screen (and maybe various models)


---

## 🔴 Very High Complexity (Large Features)

14. **Food Recommendation Engine**
    - Make macro-based recommendations for snacks/meals based on frequent history.
    - Initially focus on single items logged alone (snack-like behavior).
    - Design to respect typical ratios and allow for future "meal" expansion.
    - *Complexity: 12*

I want a food recommended, so ideally, the user would be able to enter some macro target that they want to hit for a snack/meal and the app would make a recommendation based on what the user frequently eats. I suppose, ideally the user would be also be able to select macros and based on what they have remaining, the app would make a recommendation of foods to eat to hit those macros. Also, from an implementation perspective, clearly just single food recommendations would be easiest but ideally in time it'd be able to recommend meals based on thing that are frequently eaten together, but if doing that, I suppose we'd need to respect the typical ratios in which stuff is eaten. I don't want to recommend tuna salad with more mayo than tuna. I want to just start with a system that will recommend single goods that are at times logged by themselves (not as part of a meal), but I want to be able to expand to recommend meals, so I don't want to bake assumptions about the number of foods into low lever aspects of the implementation


15. **AI Food Creation**
    - Multi-step flow: Take icons, macros, and barcode photos.
    - Use local OCR (e.g., `google_ml_kit`) or **OpenRouter** fallback to parse macro labels.
    - Integrate with barcode search to create complete food entries.
    - *Complexity: 14*

I want to be able to add or creates foods via AI. I think the process flow would be that under the Foods tab of the Search Screen, there'd be the option to do such a thing, then it'd have the user take a pic of the item for an icon, then another of the macros, then another of the bar code, then it's use AI (or some other OCR system) to pull the macros from the label (if AI is used, there'd obviously need to be a way to enter credentials for Openrouter or something like that and set up a model unless the model was preconfigured and the user just had to enter credentials), then some other system would read the barcode, and we have the image, so they'd be combined to make a food.
