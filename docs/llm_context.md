# App usage summary

Meal of Record is to help people track calories, macros, and weight over time. 

At a high level, eventually, it should be able to do things like track calories, fat, carbs, and protein per meal, day, and week, enable visualizing, easy data entry and editing from sources such as the FDA as well as OpenFoodFacts (OFF). There should be a local Live Database (where user data and edits live) and a read-only Reference Database (parsed and pruned from FDA data). Generally, we want to prioritize local data since it's faster, but allow seamless integration with OFF and the Reference DB. Determining how to manage data versioning and history is critical: we want users to be able to fix input mistakes without rewriting history in a way that falsifies past logs.

# Terminology

To ensure consistency across the application and codebase, the following terms are defined:

- **Food**: The reference data for a specific item (e.g., "Apple" or "Chicken Breast"). It contains the master macro values (Calories, Protein, Fat, Carbs, Fiber) which are stored and calculated based on 1 gram of the food.
- **Serving**: A definition of a unit of measurement for a Food. It defines the name of the unit (e.g., "cup", "piece", "container") and how many grams that unit weighs. A Food can have many Servings defined.
- **Quantity**: The numeric value entered by the user (corresponds to "Amount" in the UI) or calculated by the app to specify how much of a unit or macro is being referred to (e.g., the "1.5" in "1.5 cups").
- **Portion**: A specific instance of a Food (or Recipe) being used, logged, or added as an ingredient. A Portion stores the reference, the total weight in grams, and the unit name used to define it. A Portion is what appears in the Log, Log Queue, and as Ingredients in a Recipe.

# 1 Screens Overview

## 1.1 Overview: basic summaries of the week's macros. The macros are to be in tables of bar charts as well as some text labels. Additionally, there should be buttons to toggle between showing the consumed macros and the remaining macros.
- 1.1.1 Each column of bar charts represents a day of the current week: Monday through Sunday, and each row represents a macro, one bar chart per day. 
- 1.1.2 There should also be a column of text, to the right of the bar charts, representing the current day's consumed or remaining (depending on button selection) macro amount for each macro as well as the day's target for said macro.
- 1.1.3 The Consumed/Remaining buttons should set a global state so that it'll be persistent even when the screen if left and returned to.
- 1.1.4 The below that should show a Weight Graph visualizing the user's weight history over the selected time period.
  - 1.1.4.1 **Missing Entry Indicator**: If no weight has been entered for "Today", the graph should indicate this in an obvious but unobtrusive way (e.g., a faint placeholder or dashed projection to a predicted point) without skewing the Y-axis to zero.
- 1.1.5 Below the graph should be a row of buttons: "Week", "Month", "3 Months", "6 Months", "Year" to change the graph's time scale.
- 1.1.6 The below that should show a Search bar, globe button representing an OpenFoodFacts (OFF) search, and then a Log button.
- 1.1.7 The Search bar should bring up the consolidated Search screen.
- 1.1.8 The OFF button performs a search using the external OpenFoodFacts database for the current query.
- 1.1.9 Below that should be a set of tabs: Overview, Log, Weight, and Settings which should bring the user to the Overview, Log, Weight, and Settings screens respectively.

## 1.2 Log: the person's logged foods. 
- 1.2.1 The top should have a label for the day: a date, "Yesterday", "Today", or "Tomorrow" with simple navigation to move between days.
  - 1.2.1.1 **Fasted Option**: To keep the UI clean, the option to mark the day as "Fasted" (explicit 0 calories) should be tucked away in a menu or non-primary location, rather than a prominent button, given its infrequent usage.
- 1.2.2 The navigation buttons should let the user switch to see what was logged on any given day by letting the user move one day at a time into the future or past relative to the currently selected day. It should default to today.
- 1.2.3 There should then be a row of bar charts representing the Consumed or Remaining macros for the selected day based on the global state.
- 1.2.4 Each set of foods that are logged together should have a timestamp above the group (Meal) as well as the total macros for the meal.
- 1.2.5 Each portion of each food item should be in its own little bubble (Slidable Portion Widget which contains a Portion Widget) and should contain the size of the portion, the unit of measure of the portion, the macros of the portion, and the image of the food. The image should be a thumbnail if available, and if not, should default back to the emoji, and only if there's no emoji for the food of the portion, should it fall back to a default emoji.
- 1.2.6 The Slidable Portion Widget combined with the contained Portion Widget should allow deleting, copying, and editing logged items. The Portion Widget should have an always visible edit button on the right side. Sliding the portion to the left should reveal the delete button, and having it work this way means that two actions are needed to help avoid accidental deletions.
- 1.2.7 Multiselect:
  - 1.2.7.1 Long pressing a portion should select it.
  - 1.2.7.2 Clicking elsewhere should unselect it but the particulars of what that mean needs to be sorted out so that it's done in a practical yet intuitive way.
  - 1.2.7.3 Once one portion is selected, tapping on additional portions should select them as well.
  - 1.2.7.4 Tapping a selected portion should unselect it.
  - 1.2.7.5 Again, if any portions are selected, tapping off of any portion should unselect them all.
  - 1.2.7.6 If any portions are selected, a context sensitive set of buttons should be brought up: Copy, Move, Delete, and Make Recipe.
    - 1.2.7.6.1 The Copy button should copy the selected portions to the Log Queue and open the Log Queue Screen
    - 1.2.7.6.2 The Move button should move the selected portions to a user specified date and time with the Log, so should update the logged time based on a calendar and time picker that should be presented to the user that should default to the present date and time. Also, once the date and time are selected, the Log Screen should be opened to the selected date.
    - 1.2.7.6.3 The Delete button should delete the selected portions and should leave the user on the current Log date.
    - 1.2.7.6.4 The Make Recipe button should open the recipe screen and prepopulate the ingredients with the selected portions. (Tapping an ingredient in the recipe screen should also bring up the Quantity Edit Screen).
- 1.2.8 The bottom buttons should show a Search bar, globe button representing an OpenFoodFacts search, and then a Log button.
- 1.2.9 The Search bar should bring up the Search screen.
- 1.2.10 The OFF button should either do nothing and be there for consistencies sake, or should search for whatever is in the search box, but clicking on the search box to enter text should open the Search screen so there shouldn't be anything in the search box so maybe the button should do nothing at that point to avoid empty searches?

## 1.3 Search: shows results from various search types (text, barcode, recipe) and sources (local, OFF).
- 1.3.0 The Search Screen is a consolidated, configurable component (`SearchScreen`) that adapts to different usage contexts (e.g., adding to a day log vs. adding a recipe ingredient) via a `SearchConfig`.
- 1.3.1 The top should have a row with an exit button that should bring the user back to the home screen (prompting the user that the Log Queue will be emptied if it isn't already so), a list of images showing what's in the Log Queue, and a down arrow button to navigate to the Log Queue screen.
- 1.3.2 Next are two rows of bar charts, one representing the day's macros (including what's in the Log Queue), one for the Log Queue's macros.
- 1.3.3 Below that are three buttons: a Text-based search button, a Barcode-based Search, and a Recipe tab, representing the three main forms of item lookup.
  - 1.3.3.1 The Text based search:
    - 1.3.3.1.1 Defaults to searching the local food databases.
    - 1.3.3.1.2 The OFF button can be used for additional data options. Pressing it should perform an OFF search for the text that's in the Search bar (handled by the `SearchRibbon`).
    - 1.3.3.1.3 Search results are to be color coded based on the original source of the data (USDA Foundation Foods, USDA SR Foods, OFF Foods, user entered). Recipes are excluded from this general search and have their own dedicated tab. Since once a portion is logged that refers to a food, said food needs to be added to the logged foods table, so there simultaneously needs to be a way to distinguish previously logged vs not logged foods. This should be achieved via a small icon or a "Note" section displayed on the food item; since space is at a premium, this should be subtle enough to not clutter the UI but still be identifiable (squinting is an acceptable tradeoff for density).
    - 1.3.3.1.4 For each food, there should be an icon/image, the name, a dropdown of proposed portion units and sizes, and the macros for the currently selected portion, as well as an add button.
      - 1.3.3.1.4.1 **Image Popup**: Tapping on the food image thumbnail should display a larger version of the image in a dialog. The popup should support pinch-to-zoom (0.5x to 4x scale) and can be dismissed by tapping the close button or tapping outside the image area.
    - 1.3.3.1.5 Selecting the add button should add the current portion to the Log Queue.
    - 1.3.3.1.6 Selecting other parts of a search result should bring up the Quantity Edit Screen.
    - 1.3.3.1.7 Kind of like with the Slidable Portion Widgets, the search results should be slidable. Each result is displayed using a `SearchResultTile`.
      - 1.3.3.1.7.1 The previous functionality can all be handled by the Search Result Widget, but that should be a child widget of the Slidable Search Result Widget.
      - 1.3.3.1.7.2 Sliding the search result to the left should reveal the delete button, and having it work this way means that two actions are needed to help avoid accidental deletions.
        - 1.3.3.1.7.2.1 Sliding the search result to the right should reveal the Edit and Copy buttons.
          - 1.3.3.1.7.2.1.1 The Edit button needs to bring up a yet to be implemented (or at least flushed out) Food Edit Screen that lets the user modify an existing food.
            - 1.3.3.1.7.2.1.1.1 If the search result is from the reference db, then at least upon submitting/entering the edit, the food needs to be copied to the live db `Foods` table with all of the user viewed data copied over. The new Live version should maintain a link to the original Reference item (if applicable) to avoid duplicate search results.
            - 1.3.3.1.7.2.1.1.2 If the parent food is in the reference db, then ideally, since foods point to the parent's id, the source data from the reference db would be able to be filtered out of search results. This is low priority and can be done later, especially if there aren't clear and high confidence ways to achieve this.
            - 1.3.3.1.7.2.1.1.3 In cases where the parent is already logged (referenced in `LoggedPortions`), all parents should be recursively filtered out of the search results so only the newest version of the food will be shown.
            - 1.3.3.1.7.2.1.1.4 By doing this we won't break old logs, yet we'll be able to update future search results.
          - 1.3.3.1.7.2.1.2 The Copy button should work about like the edit button, only a copied item seemingly won't have a parent.
            - 1.3.3.1.7.2.1.2.1 So unlike with the edit button, whatever its data's being copied from, won't be filtered out of the search results.
            - 1.3.3.1.7.2.1.2.2 When the Edit Food Screen opens, the food name should be the same as the source food, only with " - Copy" appended to the end of it.
        - 1.3.3.1.7.2.2 In theory, from the user's perspective, the Delete button will delete foods.
          - 1.3.3.1.7.2.2.1 Since the reference db is read only, if the user tries to delete a search result from the reference db, the user should be succinctly be prompted to let them know that the food can't be deleted and why.
          - 1.3.3.1.7.2.2.2 If the search result that's to be deleted is a user-created/live food, and isn't referenced by anything (log entries or recipes), then it can be deleted.
          - 1.3.3.1.7.2.2.3 If the search result that's to be deleted is referenced by something (log entries or recipes), then it can't be deleted; it should be soft-deleted ("hidden") so that it's filtered from future search results without breaking old logs or recipes.
  - 1.3.3.2 The Barcode search isn't to be worried about for now.
  - 1.3.3.3 The Recipe Search button is next.
    - 1.3.3.3.1 Below the row of 3 buttons (text search, barcode search, and recipe search) should be a Create New Recipe button to bring the user to the Edit Recipe Screen.
    - 1.3.3.3.2 Adjacent to the Create New Recipe button should be a dropdown to let the user select what Category of recipe they want to search.
    - 1.3.3.3.3 Below that should be the returned list of recipes.
      - 1.3.3.3.3.1 When the pace is initially loaded, when no search term has yet been entered, it should default to showing all of the latest versions of recipes, so if a recipe has been saved a number of times, only the latest version should be shown.
      - 1.3.3.3.3.2 Entering a search term at the bottom of the page should search recipes, not foods, and I suppose the OFF button shouldn't do anything since it doesn't seem like that'd make sense.
      - 1.3.3.3.3.3 Much like with the text based search, the results should be displayed in the Search Result Widget, and the Slidable Search Result Widget, but maybe the Slidable Search Widget needs a flag and configurability, or maybe it needs to be a different widget.
        - 1.3.3.3.3.3.1 Like with search results, sliding a recipe to the left should reveal a delete button, but like with the text based search results, in order to ensure data integrity, it should hide the recipe if it's ever been logged or added to another recipe as an ingredient.
        - 1.3.3.3.3.3.2 Sliding the recipe to the right should reveal the Edit, Copy, and Dump buttons.
          - 1.3.3.3.3.3.2.1 The Edit button should bring the user to the Edit Recipe Screen. The system must handle versioning logic (see Section 3.3) to ensure that past logs remain accurate if nutritional data is changed.
          - 1.3.3.3.3.3.2.2 The Copy button should bring the user to the Edit Recipe Screen with the recipe duplicated (new ID, no parent). The name should have " - Copy" appended.
          - 1.3.3.3.3.3.2.3 The Dump button should dump one serving's worth of ingredients into the Log Queue. The idea is that, while, for instance, if you were making a cookie recipe, you'd never make one cookie or only eat most of the ingredients, but you might, for instance, have a standard dinner salad recipe that you work from most nights, but where, unlike the cookie recipe, instead of making it exactly the same every time, each night will be a little different depending on what's on hand. So the user may create a generic Dinner Salad recipe, and then when making it, hit the Dump button to avoid having to add each individual ingredient/portion to the Log Queue, then they can switch over to the Log Queue, delete anything that they're not having that night, and update portion amounts/units for the remaining ingredients/portions. Also, there's to be an option to set in the Edit Recipe Screen to set that the recipe is only Dumpable (this will avoid accidentally adding the recipe as is and which would inhibit the ability to edit the recipe in place (with the salad recipe example, the recipe may be updated frequently depending on what's in season and ensuring that it's always dumped ensures that the user doesn't end up with a bunch of versions of it in the db)). If the recipe is only dumpable then hitting the plus button should dump the recipe into the Log Queue and tapping the recipe (such as to bring up the Quantity Edit Screen) should prompt the user that that isn't an option since the recipe is only dumpable.
        - 1.3.3.3.3.3.3 The plus button should add one portion (as specified by the dropdown of the Search Result Widget) to the Log Queue.
        - 1.3.3.3.3.3.4 Tapping elsewhere on the widget should bring up the Quantity Edit Screen so that the user can enter the exact Quantity and Unit of recipe that they're having.
- 1.3.4 **Quick Add**:
  - 1.3.4.1 A "Quick Add" button (e.g., adjacent to Search/Recipe buttons) allows the user to log a generic entry without searching.
  - 1.3.4.2 The user specifies Name, Calories, Protein, Fat, and Carbs directly.
  - 1.3.4.3 Implementation: Creates a new `Food` in the Live DB with `isHidden=true` so it doesn't clutter search results. The name should default to "Quick Add [Timestamp]" if not specified.
- 1.3.5 Selecting the Log button should log the Log Queue to the LoggedPortions table in the db and then navigate the user back to the Overview screen.
- 1.3.6 Some additional requirements are covered under 1.7.6 on how it must be made flexible for reuse for searching for and adding ingredient to recipes.

## 1.4 Quantity Edit Screen: a place for a user to edit how much of a particular food was eaten (Portion) or is in a recipe (Ingredient).
- 1.4.1 The top left is to have a back button that brings the user back to wherever they navigated from (Search Screen, Log Screen, Log Queue Screen, or Recipe Edit Screen) without making any changes.
- 1.4.2 Should have two rows of macros: the parent context's macros (Day's Macros or Recipe's Macros) and the item's macros (Portion or Ingredient). Both should update in real time.
- 1.4.3 If updating an existing item, the parent macros should subtract the old version and add the new version. Otherwise, just add the new version.
- 1.4.4 For recipes, an additional toggle for "Total" vs "Per Serving" should be available:
  - 1.4.4.1 Total (default): Recipe macros show sum of all ingredients. Item macros show macros for the entered Quantity.
  - 1.4.4.2 Per Serving: Recipe macros show one serving's worth. Item macros show 1/Nth of the Quantity's macros (where N is number of servings).
  - 1.4.4.3 The Quantity always represents the total physical amount added; the toggle only affects visualization.
- 1.4.5 Parent Macro Targets:
  - 1.4.5.1 For Day's Macros, the bar charts use the user's daily goals.
  - 1.4.5.2 For Recipe Macros, it is undecided if they should have a target; as such, not having a target for recipe bar charts is an acceptable simplification.
- 1.4.6 There should be a user editable Quantity and a user editable Unit (list of all available units for the food, e.g., grams, cups, pieces).
- 1.4.7 Target Selection: A row of buttons for "Unit" (default), Calories, Carbs, Protein, and Fat.
  - 1.4.7.1 If "Unit" is selected, the numeric input is treated as the Quantity of the selected Unit.
  - 1.4.7.2 If another target is selected (Calories, Carbs, Protein, or Fat), the selected Unit must automatically switch to "g" (grams). The food's macro values are used to calculate the number of grams required to achieve the target numeric value of the selected macro.
  - 1.4.7.3 If the user manually changes the Unit selection while a macro target (Calories, Carbs, Protein, or Fat) is active, the Target Selection must automatically switch back to "Unit".
- 1.4.8 Calculated Output: Below the targets, show the resulting number of grams required.
- 1.4.9 Pre-population: When the screen opens, the Quantity (Amount) and Unit fields must be pre-populated with the values from the source that triggered the screen (e.g., the selected unit in a search result or the current quantity/unit of a logged portion).
- 1.4.10 The Cancel button discards changes and returns the user to the previous screen.
- 1.4.10 The Action button:
  - 1.4.10.1 Label: Dynamically displays "Add" if adding a new item, or "Update" if modifying an existing one. 
  - 1.4.10.2 Behavior: Adds/updates the item in the appropriate collection (Log Queue, Logged Portions, or Recipe ingredients) and navigates back. Adding an ingredient to a recipe should NOT add it to the Log Queue.

## 1.5 Log Queue: A screen for viewing in process logging activities, what and how much food is being proposed to have been eaten.
- 1.5.1 The top should have a row with an exit button that should bring the user back to the home screen (prompting the user that the Log Queue will be emptied if it isn't already so), a list of images showing what's in the Log Queue, and then an up arrow button to navigate to the Search screen.
- 1.5.2 Next should be two rows of macros: the day's expected macro including the current proposed portion, and then the portion's macros. Both should update in real time.
- 1.5.3 Then should be a list of food bubbles, each with an image, name, quantity, unit, and macros.
- 1.5.4 There should be an edit button that brings the user to the Quantity Edit Screen so that it can be edited.
- 1.5.5 Sliding the portion to the left should reveal the delete button. 
  - 1.5.5.1 Clicking the delete button should delete the portion from the Log Queue
  - 1.5.5.2 Clicking on the slid portion somewhere other than the delete button should slide the portion back to its nominal position.
  - 1.5.5.3 This is achieved by having the text, image, macros, and edit button in the Portion Widget, and having that wrapped in a parent Slidable Portion Widget that handles the sliding stuff as well as the delete button and subsequent functionality.
- 1.5.6 The bottom has the standard Search bar, OFF button, and Log button.
- 1.5.7 Clicking the Log button will commit the Log Queue to the LoggedPortion table and then bring the user back to the Overview screen.
- 1.5.8 When the Log Queue is logged, everything in the log queue should receive the same, current, time as the timestamp for when the portions were logged, that said, said time should be passed into the logging function since that's what allows moving portions, editing their logged time.

## 1.6 Settings: configuration and data management.
- 1.6.1 The screen should provide access to app-wide settings and tools.
- 1.6.2 **Data Management**: A specific sub-screen for handling app data preservation.
  - 1.6.2.1 **Manual Backup**:
    - 1.6.2.1.1 **Export**: Users can manually export the entire live database to a file using the system's share sheet.
    - 1.6.2.1.2 **Import**: Users can restore the database from a file. This is a destructive action that replaces the current database, so a confirmation dialog is required.
  - 1.6.2.2 Automatic Cloud Backup
    - 1.6.2.2.1 Integration
      - 1.6.2.2.1.1 Automatic backups integrate directly with Google Drive using the Google Drive REST API.
      - 1.6.2.2.1.2 Backups are stored in the hidden appDataFolder to avoid cluttering the user’s Drive.
      - 1.6.2.2.1.3 No Firebase services are used for authentication or storage.
    - 1.6.2.2.2 Authentication Model
      - 1.6.2.2.2.1 Authentication is handled via Google Sign‑In (OAuth 2.0) using the Android app’s package name and signing certificate.
      - 1.6.2.2.2.2 This requires a one‑time configuration of an Android OAuth Client ID in Google Cloud Console.
      - 1.6.2.2.2.3 No API keys are embedded in the app.
      - 1.6.2.2.2.4 No credentials are stored or transmitted to any backend.
      - 1.6.2.2.2.5 This is a platform security requirement, not a Firebase dependency.
- 1.6.3 **Goals & Targets Logic**:
  - 1.6.3.1 **Configuration**:
    - 1.6.3.1.1 **Manual Maintenance Start**: Users manually enter an estimated starting Maintenance Calorie amount.
    - 1.6.3.1.2 **Target Weight**: Users manually set a specific Weight Goal (Anchor Weight).
    - 1.6.3.1.3 **Macro Split**: User sets specific targets for Protein (g) and Fat (g). Carbs (g) are calculated as the remainder of the calorie budget.
    - 1.6.3.1.4 **Maintenance Display**: The calculated daily Maintenance Calories (TDEE) should be displayed in the goals/settings area for user reference.
  - 1.6.3.2 **Calculation Loop**:
    - 1.6.3.2.1 Formula: `Target Intake = Maintenance Intake +/- Delta`.
    - 1.6.3.2.2 **Gain/Lose Mode**: `Delta` is a *fixed calorie amount* specified by the user (e.g., +500 or -500 per day).
    - 1.6.3.2.3 **Maintain Mode**: `Delta` is *calculated* to correct drift. Formula: `(Reference Anchor Weight - Current Trend Weight) / 30`. This measures the gap, assumes a 30-day correction window, calculates the daily mass change required, converts that to calories (approx 3500 cal/lb), and creates the Delta.
  - 1.6.3.3 **Updates & Trends**:
    - 1.6.3.3.1 **Weekly Updates**: Calculating and updating the active Macro Targets (Calories/Carbs) happens once per week (every Monday). On the first app open of the week, a popup or noticeable banner must inform the user of their new macro targets.
    - 1.6.3.3.2 **Data Gap Handling**:
      - Days with NO food entry or NO weight entry are **ignored** (assumed missing data), NOT treated as zero.
      - Days explicitly marked "Fasted" are treated as 0 calories.
      - Weight inputs assume one per day; entering a second time overwrites the first.
  - 1.6.3.4 **Estimation**: The "Current Trend Weight" is derived from a best-fit/average of recent weight entries to smooth out daily fluctuations.
  - 1.6.3.5 **Future Projection**: The screen displays a projection of what the user will weight in 1 month if they stick to the current plan (based on the gain/lose/maintain delta).

## 1.7 Recipe Edit: a screen for editing and creating recipes
- 1.7.1 The top row of the screen should have a back button that'll bring the user back to the Search Screen, the recipe name (if its previously been saved), a Share button, and a Save button.
  - 1.7.1.1 The Share button (visible only for saved recipes) opens the QR Sharing Screen, allowing the user to export the recipe as a series of QR codes.
  - 1.7.1.2 **Import/Scan Button**: Visible only when creating a new recipe (unsaved, no name, no ingredients). Allows the user to scan a recipe QR code to populate the screen.
  - 1.7.1.3 If there are unsaved changes, if the user hits the back button, they should get a succinct message asking if they want to discard unsaved changes.
- 1.7.2 Next down should be a place for the user to enter a recipe name
- 1.7.3 Next should be a row to allow the user to enter the number of portions as well as the name of what a portion is, for example Cookie, Slice, Piece, etc. 
- 1.7.4 Next should be a row with a Total Weight input. The total final weight must sometimes be updated to account for the addition or subtraction of calorie free stuff such as water that isn't tracked in the app (e.g., if making sugar water, identifying the final weight as 100g even if only 50g of sugar was added, so that a 50g serving correctly calculates as having 25g of sugar). Next to that should be a button to specify that the recipe is purely a dumpable template that is, that while the user should be able to "dump" the ingredients into the Log Queue, the user shouldn't be able to add the recipe itself to the Log Queue. This like like with the cookie vs salad example from 1.3.3.3.3.3.2.3. The Dump Only button/checkbox/whatever, should default to unselected since this is the exception to the rule.
- 1.7.5 Next should be two rows of bar charts. The top row should be labeled "Total Recipe Macros" reflecting the sum of all ingredients. The bottom row should be labeled "Macros per [Portion Unit Name]" (e.g., "Macros per Cookie"), representing the total divided by the number of portions.
- 1.7.6 Below the metadata and macros, there should be a Categories section:
  - 1.7.6.1 It should have a multi-select category picker that looks like a dropdown field.
  - 1.7.6.2 Tapping it opens a dialog with a checklist of all available categories and a (+) button to add new ones.
  - 1.7.6.3 Selected categories should be displayed as chips within the picker field for easy identification and removal.
- 1.7.7 Next should a button to add ingredients. this means a number of things must be configurable on the search screen:
  - 1.7.7.1 The exit icon at the top must bring the user back to the recipe screen.
  - 1.7.7.2 The navigation and visibility of UI elements (like the macro ribbon) are dynamically controlled via the `SearchConfig` passed to the `SearchScreen`.
  - 1.7.7.3 The down arrow in the top right should bring the user back to the recipe screen if that's where the search screen was reached from.
  - 1.7.7.4 The bar charts should show the total recipe's macros on the top line and the ingredient's macros on the second line and the labels should update accordingly.
  - 1.7.7.5 The plus button or `onSave` action needs to know to add the ingredient to the recipe but not the Log Queue and to go back to the Recipe Edit screen. This can be handled by an `onSaveOverride` in the `SearchConfig`.
  - 1.7.7.6 Clicking on the `SearchResultTile` needs to bring up the Quantity Edit Screen with the appropriate context.
  - 1.7.7.7 The log button should be hidden or inactive in this context if not needed.
- 1.7.8 Next should be a list of the ingredients in the recipe, with the ability to edit each one. They should use the same Portion Widget and Slidable Portion Widget as the Log and Log Queue. this may take some reworking and should be done so thoughtfully to ensure it still works as desired and expected for all use cases.

## 1.8 Weight Screen: A screen for tracking body weight
- 1.8.1 **Default View**: Opens to the current day ("Today").
- 1.8.2 **Display**:
  - 1.8.2.1 If a weight has been entered for the selected day, show the value.
  - 1.8.2.2 If no weight has been entered, show a clear placeholder text like "Weight".
- 1.8.3 **Navigation**:
  - 1.8.3.1 Users can scroll through past days to view or edit historical weight entries, similar to the date navigation on the Log Screen.
- 1.8.4 **Data Persistence**:
  - 1.8.4.1 Inputs are stored in a dedicated `Weights` table in the Live DB, recording the weight value and the date.
  - 1.8.4.2 Entering a weight for a given day overwrites any previous entry for that same day.
  - 1.8.4.3 This data feeds the Overview Graph and the Goals calculation logic.
  - 1.8.4.4 **Dynamic Units**: Display units ('kg' or 'lbs') are driven by the `useMetric` setting in `GoalSettings`.
  - 1.8.4.5 **Navigation**: Saving a weight entry automatically returns the user to the Home screen.

## 1.9 Data Management: a screen for handling app data preservation and backup.
- 1.9.1 The screen should provide access to both manual and automatic cloud backup options.
- 1.9.2 **Cloud Backup**:
  - 1.9.2.1 **Integration**: Seamless integration with Google Drive (specifically the hidden App Data folder to avoid clutter).
  - 1.9.2.2 **Configuration**: Users can toggle this feature on/off and sign in/out of their Google account. The screen displays the currently signed-in Google account email.
  - 1.9.2.3 **Retention Policy**: Users can configure the retention count (defaulting to 7 days, adjustable from 1 to 30 days) via a slider. The system automatically deletes old backups from Drive to save space.
  - 1.9.2.4 **Smart Scheduling**: Backups are scheduled to run daily in the background. A "dirty flag" mechanism ensures backups only occur if the database has actually changed since the last successful backup, conserving data and battery.
  - 1.9.2.5 **Status Display**: The screen displays the timestamp of the last successful backup to inform the user when their data was last saved to the cloud.
- 1.9.3 **Manual Backup**:
  - 1.9.3.1 **Export**: Users can manually export the entire live database to a file using the system's share sheet. The exported file is the live database file.
  - 1.9.3.2 **Import**: Users can restore the database from a file. This is a destructive action that replaces the current database, so a confirmation dialog is required warning the user that this will overwrite all current logs and recipes and cannot be undone unless they have another backup.
  - 1.9.3.3 **User Guidance**: A note should be displayed informing users that restoring data will replace their current recipes and food logs, and they should ensure they have a backup of their current data if they still need it.

## 1.10 Food Edit: a screen for creating new foods or editing existing food definitions.
- 1.10.1 The top should have a back button that brings the user back to the previous screen without making any changes, and a save button (checkmark icon) to save the food.
- 1.10.2 **Context Types**: The screen can be accessed from different contexts:
  - 1.10.2.1 **Search Context**: Accessed from the Search Screen via the Edit or Copy buttons on a search result. In this context, an additional "Save & Use Immediately" button is available, which saves the food and immediately adds it to the Log Queue or uses it in the appropriate context.
  - 1.10.2.2 **Edit Definition Context**: Accessed when editing a food's definition directly. In this context, only the save button is available.
- 1.10.3 **Metadata Section**:
  - 1.10.3.1 An emoji field for selecting or entering an emoji to represent the food.
  - 1.10.3.2 A food name field (required) for entering the name of the food.
  - 1.10.3.3 A notes field (optional) for entering any additional notes about the food.
  - 1.10.3.4 When copying a food, the name should have " - Copy" appended to the end of it.
- 1.10.4 **Nutrition Section**:
  - 1.10.4.1 A dropdown to toggle between entering nutrition values "Per 100g" or "Per Serving".
  - 1.10.4.2 When "Per Serving" is selected, an additional dropdown appears to select which serving definition the macro values are based on.
  - 1.10.4.3 Input fields for Calories (kcal), Protein (g), Fat (g), Carbs (g), and Fiber (g).
  - 1.10.4.4 All macro values are stored internally as per-gram values, regardless of the input mode selected.
- 1.10.5 **Servings/Units Section**:
  - 1.10.5.1 A list of all serving definitions for the food, excluding the base 'g' (gram) unit which is always available.
  - 1.10.5.2 Each serving definition displays the quantity, unit name, and equivalent weight in grams.
  - 1.10.5.3 Users can add new servings, edit existing servings, or delete servings.
  - 1.10.5.4 When adding or editing a serving, users specify the unit name (e.g., "cup", "slice"), the quantity (e.g., 1.0), and the weight in grams for that quantity.
  - 1.10.5.5 If no servings are defined beyond the base 'g' unit, a message should indicate that defaults to grams only.
- 1.10.6 **Save Behavior**:
  - 1.10.6.1 When saving a new food or a copied food, a new record is created in the Live Database with `source` set to 'user'.
  - 1.10.6.2 When editing an existing food, the system must check if the food is "Used" (referenced in log entries or recipes). If macro-affecting changes are made and the food is used, versioning logic should be triggered (see Section 3.3). If only macro-neutral changes are made (name, emoji, notes), the changes can be applied in-place.
  - 1.10.6.3 If the original food is from the Reference Database, it must be copied to the Live Database upon saving, with all user-viewed data copied over. The new Live version should maintain a link to the original Reference item to avoid duplicate search results.

## 1.11 Goal Settings: a screen for configuring weight goals and macro targets.
- 1.11.1 The top should have a back button that brings the user back to the Settings screen without making any changes, and a save button to save the settings.
- 1.11.2 **Goal Mode Selection**:
  - 1.11.2.1 A segmented button selector to choose between "Lose", "Maintain", and "Gain" modes.
  - 1.11.2.2 The selected mode determines how the daily calorie delta is calculated.
- 1.11.3 **Weight Settings**:
  - 1.11.3.1 An anchor weight field for entering the target or baseline weight. This is the reference point for calculating drift in Maintain mode.
  - 1.11.3.2 A toggle for "Use Metric Units (kg)" which affects how weight is displayed and how calorie drift is calculated (approx 3500 cal/lb vs 7700 cal/kg).
- 1.11.4 **Calorie Settings**:
  - 1.11.4.1 An initial maintenance calories field for entering the estimated TDEE (Total Daily Energy Expenditure). This serves as the baseline for calculating daily calorie targets.
  - 1.11.4.2 In "Lose" or "Gain" modes, a fixed delta field appears for entering the daily calorie adjustment (e.g., -500 for losing, +500 for gaining).
  - 1.11.4.3 In "Maintain" mode, the delta is calculated automatically based on the difference between the anchor weight and the current trend weight, so no fixed delta field is shown.
- 1.11.5 **Macro Split Settings**:
  - 1.11.5.1 A protein target field for entering the daily protein goal in grams.
  - 1.11.5.2 A fat target field for entering the daily fat goal in grams.
  - 1.11.5.3 Carbs are calculated as the remainder of the calorie budget after accounting for protein and fat, so no direct carb input is needed.
- 1.11.6 **Save Behavior**:
  - 1.11.6.1 Saving updates the `GoalSettings` in the database.
  - 1.11.6.2 The `lastTargetUpdate` timestamp is preserved when saving to ensure weekly updates continue to work correctly.
  - 1.11.6.3 After saving, a confirmation message should be displayed to the user.
  - 1.11.6.4 The calculated daily maintenance calories (TDEE) should be displayed in the goals/settings area for user reference.

## 1.12 QR Sharing: a screen for sharing recipes via QR codes or scanning QR codes to import recipes.
- 1.12.1 The screen has two modes: Export (sharing a recipe) and Import (scanning a recipe).
- 1.12.2 **Export Mode**:
  - 1.12.2.1 The screen displays a QR code containing the recipe data.
  - 1.12.2.2 If the recipe data is small enough to fit in a single QR code, only one QR code is displayed.
  - 1.12.2.3 If the recipe data is too large for a single QR code, it is split into multiple chunks (approximately 600 characters per chunk), and the QR codes cycle through automatically.
  - 1.12.2.4 Each QR code chunk includes a header in the format "index/total|data" (e.g., "1/3|...") to indicate which part of the recipe it contains.
  - 1.12.2.5 A progress indicator shows which part is currently being displayed (e.g., "Part 2 of 3").
  - 1.12.2.6 Users can pause/resume the automatic cycling of QR codes using a play/pause button.
  - 1.12.2.7 A message informs the recipient that they need to keep scanning until all parts are captured.
- 1.12.3 **Import Mode**:
  - 1.12.3.1 The screen displays a camera view for scanning QR codes.
  - 1.12.3.2 As QR codes are scanned, the chunks are collected and reassembled.
  - 1.12.3.3 A status message shows the progress (e.g., "Received part 2 of 3").
  - 1.12.3.4 A progress bar indicates how many chunks have been received out of the total expected.
  - 1.12.3.5 Once all chunks are received, the recipe is processed and imported into the Live Database.
  - 1.12.3.6 If the import is successful, a confirmation message is displayed and the user is returned to the previous screen with the new recipe ID.
  - 1.12.3.7 If the import fails, an error message is displayed and the user can retry scanning.
- 1.12.4 **Data Format**:
  - 1.12.4.1 Recipe data is exported as JSON, including all recipe metadata, ingredients, and images (converted to Base64).
  - 1.12.4.2 Images are embedded in the JSON as Base64 strings for cross-device transfer.
  - 1.12.4.3 When importing, Base64 images are decoded and saved as new files with new GUIDs, and the database is updated with the new GUIDs.
- 1.12.5 **Access**:
  - 1.12.5.1 The Export mode is accessed from the Recipe Edit Screen via the Share button (visible only for saved recipes).
  - 1.12.5.2 The Import mode is accessed from the Recipe Edit Screen via the Import/Scan button (visible only when creating a new recipe).

# 2 Search Functionality and Behavior
- 2.1 Text Based Search
  - 2.1.1 All text based data sources (Reference DB, Live DB, and OFF API) should generally act as a unified search experience using similar fuzzy filtering/sorting logic where appropriate, though implementation details may vary by source.
  - 2.1.2 OFF API data doesn't need any additional filtering/sorting since it's never displayed with other data and is innately always unlogged.
  - 2.1.3 Reference db and live db data should be displayed simultaneously and should be processed as such:
    - 2.1.3.1 Live db data should be sorted based on weighted considerations of: frequency of logging, time since last logging, and present time vs typical time of day of logging.
    - 2.1.3.2 Since live db data is already in the live db and has subsequently already been eaten, it's more likely to be what the user is looking for, so all live db data should be displayed above reference db data within the search results.
    - 2.1.3.3 Duplicate Hiding: Given that many things in the Live DB will have been copied from the Reference DB, anything that exists in both should be filtered out of the Reference results. The Live version (user's version) always takes precedence.
    - 2.1.3.4 Legacy Filtering: Once it's been sufficiently long since an item has been logged, it may make sense to drop it from the live data results. If this is done, we must ensure we're not re-entering stuff into the live db to prevent search results from being cluttered with stuff that was last eaten years ago.
- 2.2 Barcode Based Search: TBD
- 2.3 Recipe Search
  - 2.3.1 By default, all recipes should be displayed. No user action should be needed in order to scroll through recipes other than clicking to the Recipe Search tab.
  - 2.3.2 Should use a basic fuzzy search algorithm to filter recipes based on the search query.

# 3 Data Persistence & Architecture

## 3.1 Database Strategy
The app uses two databases:
- **Reference Database**: A read-only SQLite database containing USDA Foundation Foods. This is an asset packaged with the app and is never modified.
- **Live Database**: A read-write SQLite database storing all user data, including:
  - User-created foods and recipes.
  - Foods copied from the Reference Database (when logged or edited).
  - Logs (Portions).
  - Settings and other user state.

## 3.2 Unified Food Storage
- 3.2.1 There is a single schema for `Food` items in the Live Database. All foods that the user interacts with (searches, logs, edits) are stored here.
- 3.2.2 **No Separate Logged Foods Table**: We do NOT maintain a separate `LoggedFoods` table. When a food or recipe is logged, the log entry (Portion) points directly to the `Food` or `Recipe` record in the Live Database.
- 3.2.3 **Importing from Reference**:
  - When a user logs a food from the Reference Database for the first time, it is eagerly copied into the Live Database `Foods` table.
  - The log entry points to this new Live `Food` record, not the Reference one.
  - This ensures the user can later edit "their" version of the food without affecting the Reference DB (which is read-only anyway).
  - The Live copy retains a "soft link" (e.g., `sourceFdcId`) to the Reference item to allow for potential future updates or conflict resolution, but it is effectively a distinct entity.

## 3.3 Versioning & Data Integrity
To preserve historical accuracy while allowing food improvements, we implement a Versioning System:
- 3.3.1 **Immutability of Logged Data**: If a generic food (e.g., "Apple") or Recipe has been logged in the past, its nutritional values at that time must be preserved for that log entry. We cannot simply change the definition in place if it would alter historical macro counts.
- 3.3.2 **Edit Logic**:
  - **Macro-Neutral Changes**: If the user only updates fields that do NOT affect calculated macros (e.g., Name, Brand, Notes, Emoji), these changes can always be applied **in-place** to the existing record, instantly updating all past logs (which is desired).
  - **Macro-Affecting Changes**: If the user updates fields that affect nutrition (Calories, Macros, Serving Sizes, Ingredient list, Ingredient quantities), we must check if the item is "Used" (logged or part of another recipe):
    - **Unused**: Update in-place.
    - **Used**: Trigger Versioning:
      - 1. Create a NEW `Food` or `Recipe` record with the updated values.
      - 2. Set a `parentId` on the NEW record pointing to the OLD record (or a common root) to establish a lineage.
      - 3. The OLD record continues to exist (unchanged) to satisfy existing foreign keys (past logs).
      - 4. Search logic filters out any record that is referenced as a `parentId` by another record, effectively superseding it.
- 3.3.3 **Search & Filtering**:
  - The Search Logic must be aware of versioning.
  - It should filter out superseded or "old" versions of foods/recipes so the user only sees the latest version.
  - It should filter out Reference Database items if a "newer" version exists in the Live Database.

## 3.4 Image Storage & Management
- 3.4.1 **Overview**: Foods and Recipes support custom thumbnail images. Users can add images via camera or gallery, with optional cropping and automatic resizing to 200x200 pixels (preserving aspect ratio).
- 3.4.2 **Storage Strategy**:
  - **File Storage**: Images are stored as JPEG files in the app's documents directory: `{app_documents}/app_images/{guid}.jpg`
  - **Database Reference**: The database stores a prefixed GUID (e.g., `local:550e8400-e29b-41d4-a716-446655440000`) to distinguish local images from URLs
  - **Runtime Resolution**: At runtime, the prefix is checked. If `local:`, the GUID is extracted and the full path is constructed: `File('${appDir}/app_images/$guid.jpg')`
  - **Image Processing**: Images are optionally cropped by the user, then resized to fit within 200x200 pixels at 85% quality (~5-15KB per image), preserving aspect ratio
- 3.4.3 **Display Logic**:
  - **Priority Order**: Custom local image (`local:GUID`) > OFF thumbnail URL > Emoji > Default placeholder
  - **Local Images**: Displayed using `Image.file(File(thumbnail))` for user-uploaded images
  - **Remote Images**: Displayed using `CachedNetworkImage` for Open Food Facts URLs
  - **Fallback**: If no thumbnail is available, display the emoji; if no emoji, display a default emoji
- 3.4.4 **User Interface**:
  - **Image Picker**: Users can select images from camera or gallery via `image_picker` package
  - **Crop Tool**: Users can optionally crop images using `image_cropper` package before saving. Cropping is optional - users can skip cropping and use the whole image.
  - **Resize**: After optional cropping, the image (either whole or cropped area) is resized to fit within 200x200 pixels at 85% quality (~5-15KB per image), preserving aspect ratio
  - **Edit Screens**: Food Edit Screen and Recipe Edit Screen include an image picker button in the metadata section
  - **Image Popup**: Tapping on a food image thumbnail displays a larger version in a dialog with pinch-to-zoom (0.5x to 4x scale)
- 3.4.5 **Backup & Restore**:
  - **Backup**: The backup process creates a zip archive containing: database.db + only referenced images from app_images/ directory
  - **Garbage Collection**: During backup, scan the database for all referenced image GUIDs, identify unreferenced images in app_images/, and delete them
  - **Consistency**: Before backup, check for active write operations. If writes are in progress, wait or abort. Use a read transaction to get a consistent snapshot of referenced images.
  - **Restore**: The restore process extracts the zip to a temp directory, copies database.db to the live location, and copies app_images/ to the app documents directory (overwrites existing)
  - **GUID Validity**: GUIDs remain valid across devices and app reinstalls since they're device-agnostic
- 3.4.6 **Cross-Device Transfer**:
  - **QR Sharing**: Recipes can be shared via QR codes. Images are converted to Base64 and embedded in the recipe JSON for transfer.
  - **Import**: When importing a recipe via QR, Base64 images are decoded and saved as new files with new GUIDs, and the database is updated with the new GUIDs.
  - **Performance**: Base64 conversion is slower but acceptable for occasional transfers (e.g., 30 seconds for a recipe with images).
- 3.4.7 **Cleanup & Maintenance**:
  - **Orphaned Images**: On backup, scan the database for all thumbnail GUIDs and delete any image files in app_images/ that are not referenced (garbage collection)
  - **Deletion**: When a food or recipe is deleted, its associated image file is also deleted. When replacing an image, the old image is deleted as the last step (after the new image is saved).
- 3.4.8 **Versioning & Image Changes**:
  - **Macro-Neutral Changes**: If user only updates image, name, or notes (fields that do NOT affect calculated macros), these changes can always be applied **in-place** to the existing record.
  - **Macro-Affecting Changes**: If user updates macros, serving sizes, or ingredient quantities, versioning logic is triggered (see Section 3.3).
- 3.4.9 **Implementation Details**:
  - **Dependencies**: `image_picker`, `image_cropper`, `image`, `archive`, `uuid` packages
  - **Complexity**: Moderate (~400 lines of code)
  - **Risk**: Low (standard file operations)
- 3.4.10 **Benefits**:
  - Fast queries (no Base64 in database)
  - Efficient storage (~5-15KB per image)
  - Device-agnostic (GUIDs work across devices)
  - Cross-device transfer possible via QR
  - Automatic backup/restore with garbage collection
  - Scalable to thousands of images
  - Clear distinction between local and remote images via `local:` prefix

## 3.5 Cloud Backup Architecture (Google Drive, No Firebase)
- 3.5.1 Design Principles
  - Local‑first: The Live Database is always the source of truth.
  - Optional: Cloud backup is opt‑in and can be disabled at any time.
  - Stateless: No backend services are required.
  - User‑owned data: Backups live entirely in the user’s Google Drive.
- 3.5.2 Authentication & Identity
  - Uses google_sign_in for OAuth authentication.
  - Requires:
    - Android package name
    - SHA‑1 fingerprint of the signing certificate
  - This configuration exists outside the app binary and is required for:
    - Debug builds
    - Release builds (Play Store signing uses a different SHA‑1)
  - Important:
    - This is not Firebase authentication.
    - No google-services.json is required.
    - The app does not depend on any Firebase SDKs.
- 3.5.3 Backup Format
  - Each backup is a zip archive containing:
    - database.db
    - app_images/ (only referenced images)
  - Backups are named using an ISO‑8601 timestamp:
    - mealofrecord_backup_YYYY-MM-DDTHH-mm-ssZ.zip
  - Metadata (timestamp, app version) is stored in Drive file properties.
- 3.5.4 Retention & Cleanup
  - Retention count is user configurable (default: 7).
  - After a successful upload:
    - The app lists existing backups in appDataFolder
    - Deletes oldest backups beyond the retention count
  - Cleanup is best‑effort:
    - Failure to delete old backups must not fail the current backup.
- 3.5.5 Scheduling & Dirty Flag
  - A persistent dirtyFlag is set whenever:
    - The Live Database is modified
    - Images are added, replaced, or deleted
  - Daily background backup runs:
    - Skip execution if dirtyFlag == false
    - Clear flag only after successful upload
  - This conserves:
    - Battery
    - Network usage
    - Drive API quota
- 3.5.6 Failure Modes & UX
  - Backup failures must be:
    - Silent during background runs
    - Explicit when triggered manually
  - Common recoverable failures:
    - User signed out
    - Missing SHA‑1 configuration (Android)
    - Network unavailable