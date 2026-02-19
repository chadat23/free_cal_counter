# Recipes & Templates

Recipes in Meal of Record come in two flavors, each designed for a different kind of meal. Understanding the difference will help you pick the right one.

## Regular Recipes

A regular recipe is a fixed formula — cookies, chili, protein bars, ice cream. You make it the same way each time, and when you log it, you log it as a single item ("2 cookies" or "1 bowl of chili").

**Best for:** Baked goods, meal prep, anything you make in a batch and eat in portions.

**How it works when logging:** The recipe appears as one item in your log. You pick how many servings you had, and the app calculates the macros.

!!! example "Example: Chocolate chip cookies"
    You create a recipe with flour, butter, sugar, eggs, and chocolate chips. You set the batch to 24 cookies. When you eat 3 cookies, you log "3" servings of the recipe.

## Dump Recipes (Templates)

A dump recipe is a template for meals that vary. A salad, a breakfast burrito, a smoothie — the core ingredients are the same, but you might add extra spinach today or skip the avocado tomorrow.

**Best for:** Meals you build from a flexible set of ingredients.

**How it works when logging:** Instead of logging the recipe as one item, the app "dumps" each ingredient separately into your Log Queue. You can then adjust quantities, remove items, or add extras before logging.

!!! example "Example: Lunch salad"
    You create a dump recipe with greens, chicken, tomatoes, feta, and dressing. When you use it, each ingredient lands in your queue individually. Today you skipped the feta and added extra chicken — just delete the feta and adjust the chicken weight.

## Which Type Should I Use?

| | Regular | Dump |
|---|---------|------|
| Logged as | One item | Individual ingredients |
| Adjustable per meal? | No (fixed portions) | Yes (tweak each ingredient) |
| Good for | Consistent recipes | Flexible, varying meals |

---

## Creating a Recipe

1. Open the **Recipe** tab on the Search screen and tap **Create Recipe**.
2. **Add ingredients** by searching for foods (or other recipes — recipes can be nested).
3. Set the **number of portions** the batch makes (e.g., 12 cookies, 4 servings of chili).
4. Enter the **total weight** of the finished batch if you know it. This improves accuracy when cooking changes the weight (water evaporates from chili, bread rises, etc.).
5. Choose whether the recipe is **Regular** or **Dump**.
6. Tap **Save**.

!!! tip "Nested recipes"
    You can add a recipe as an ingredient in another recipe. For example, if you have a "pizza dough" recipe, you can use it as an ingredient in a "pepperoni pizza" recipe.

---

## Sharing Recipes via QR Codes

You can share recipes with other Meal of Record users without needing an internet connection.

- **To share:** Open a saved recipe and tap the **Share** button. The app generates one or more QR codes.
- **To receive:** Tap **Scan** when creating a new recipe. Point your camera at the other person's screen as the app cycles through QR code chunks to reassemble the recipe.

For complex recipes with many ingredients, the data is split across multiple QR codes that auto-cycle. The receiver just keeps the camera pointed at the screen until all chunks are captured.

---

??? info "Under the Hood: Why Two Recipe Types?"
    The regular vs. dump distinction isn't just a UI convenience — it affects how your data is stored and versioned.

    **Regular recipes** are stored as a single entity with a version history. When you log "2 cookies," the app records a reference to that specific version of the recipe. If you later change the recipe (swap butter for oil), your past logs still reflect the original version. The trade-off is that each version takes a small amount of storage.

    **Dump recipes** don't have this versioning overhead because they're not logged as a unit. When you dump a template, the individual ingredients are logged as separate food entries. The template itself is just a convenience for populating your queue quickly. This means dump recipes can be updated freely without accumulating storage, but your log won't show "Lunch Salad" — it will show each ingredient separately.
