# Core Concepts

A quick guide to the building blocks you'll encounter throughout the app.

## Food

A food is any item you can log — an apple, a chicken breast, a protein bar, a tablespoon of olive oil. Each food has a set of nutritional values: calories, protein, fat, carbs, and fiber.

Foods come from three places:

- **Your Foods** — Things you've created, edited, or previously logged. These appear with a gray background in search and always show up first. Think of this as your personal pantry.
- **Standard Foods (USDA)** — A large, built-in library of common foods with high-quality nutritional data from the USDA. Blue backgrounds in search indicate gold-standard data; red backgrounds indicate older entries. Think of this as a reference cookbook that came with the app.
- **Open Food Facts** — A massive online database of packaged products from around the world. You search it by tapping the globe icon. Think of this as the nutrition label for everything at the supermarket.

## Serving

A serving is a **named portion size** with a gram weight. For example, an apple might have servings like "1 medium" (182g) and "1 cup sliced" (110g). A food can have as many serving definitions as you like.

Good serving definitions make logging faster — instead of remembering weights, you just pick "1 medium" from a dropdown.

## Quantity

The number of servings you had. If you ate one and a half medium apples, your quantity is `1.5` with the serving set to "1 medium."

## Portion

A portion is what actually gets recorded in your log: a specific food, at a specific serving size, in a specific quantity, on a specific date and time. It's the combination of all the above — "1.5 medium apples, logged at lunch on Tuesday."

---

## Where Does Food Data Come From?

When you search for something, the app checks three sources in order:

1. **Your Foods** — fast, local, always available
2. **Standard Foods** — fast, local, always available
3. **Open Food Facts** — requires internet, triggered by tapping the globe

The color coding in search results tells you which source each result came from, so you always know what you're looking at.

---

??? info "Under the Hood: How Your History Stays Accurate"
    One of the most important things the app does behind the scenes is protect your past logs.

    **The short version:** When you log a food, the app takes a snapshot of its nutritional data at that moment. Even if you later update the food's calories or macros, your past logs still reflect what you actually ate.

    **How it works:** If you change a food's name or emoji, the update applies everywhere instantly — that's a cosmetic change. But if you change the nutritional values (calories, protein, fat, carbs, or fiber), the app creates a new version of the food. Future logs use the new version; past logs keep the old one. You never have to worry about an edit rewriting your history.

    **One thing to know about recipes:** If you update the macros of a food that's used as an ingredient in a recipe, the recipe continues using the old version of that ingredient until you manually edit the recipe and swap in the updated food. This is intentional — it keeps your recipe stable until you decide to change it.
