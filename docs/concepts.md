# Core Concepts

To use Meal of Record effectively, it's helpful to understand the basic building blocks of how food data is structured.

## Terminology

- **Food**: This is the master record for an item (e.g., "Apple"). It contains the nutritional values (Calories, Protein, Fat, Carbs, Fiber) normalized to 1 gram.
- **Serving**: A named unit of measurement for a Food. For example, a "Medium Apple" might be defined as weighing 182 grams. A single Food can have many Servings (e.g., "1 cup", "1 piece", "100g").
- **Quantity** (or **Amount**): The number of units you are referring to. For example, the "1.5" in "1.5 cups".
- **Portion**: A specific instance of a Food being logged or used in a recipe. A Portion combines a Food, a Serving unit, and a Quantity to calculate total macros, and the date and time of when it was logged.

---

## Where Does Food Data Come From?

Meal of Record balances a massive library of standard foods with your own personal edits and creations. You can think of it as two separate "shelves" in your pantry:

### 1. The Global Library (Standard Foods)
This can be thought of as ingrediants, that is, stuff that doesn't have a recipe of it's own; carrots, berries, olive oil, etc. This is a huge collection of standard foods (from the USDA) that come built-in with the app. You can't change these master records, which ensures the "baseline" data always stays accurate. Something worth noting about this baseline set of foods is that things that you find in it that do have recipes (cookies, bread, yogert, etc.) are generally generic so while you're obviously welcome to use them, they'll yield less accurate tracking.

### 2. Your personal library of logged foods, recipes, and creations
This is your private space. It contains:
- **Custom Foods**: Things you've added yourself.
- **Your Recipes**: Complex meals you've designed.
- **Your Saved Foods and Versions**: If you find an "Apple" in the Global Library but want to adjust its calories or change its name for your own use, the app creates a personal copy for you, and even if you use the apple as is, that's remembered so in the future, it'll be easier to find that particular food.

### 3. OpenFoodFacts
This is a third-party database of food products that you can use to search for additional food.
- **Enormous**: It contains tons of packaged foods. It's a great way to find all the foods that come from "the center of the supermarket" where things tend to have proprietary recipies.
- **Fallback**: Given that it involved remotely accessing data, it's slower than the other data sources and thus treated as a fallback.

By separating these, the app ensures that your personal tweaks never get overwritten, while still giving you access to thousands of standard items, and seemingly infinite branded foods as well.

![[Screenshot: The Search screen showing color-coded results for different data sources]](assets/search_sources.png)
Here you can see some search results. The gray ones are from your personal library and always show at the top, the blue and red ones are from the Global Library with the blue being the USDA's gold standard data, and the red ones being the USDA's historic data.

---

## Protecting Your History

One of the most important things Meal of Record does is protect your past logs. 

If you log a meal today, and then next week you realize a food's calories were slightly wrong and you update it, the app is smart enough to handle it:

- **Simple Updates**: If you just change a food's name or its emoji, the app updates all your logs instantly.
- **Nutritional Updates**: If you change the calories or macros of a food or recipe, the app creates a "new version" for future use. This ensures your past logs, your record, stay exactly as they were when you ate the meal, while your future logs will use the new, more accurate data. Note: as a result, if you update the calories or macros of a food that's an ingrediant in a recipe, or a recipe that's an ingrediant in another recipe, the referncing recipe will continue to reference the old version until you edit the recipe and replace the ingrediant with the updated one.
