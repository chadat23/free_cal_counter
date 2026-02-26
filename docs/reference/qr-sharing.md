# QR Sharing

Share recipes and food portions with other Meal of Record users using QR codes — no internet required.

## How to Get Here

- **Recipe sharing:** Open a saved recipe and tap the **Share** button in the top right corner.
- **Recipe scanning:** On the Recipe Edit screen, tap the **Scan** button.
- **Portion sharing:** Tap **Share** from the Quantity Edit screen or the [Meal Portion](meal-portion.md) screen.

---

## Sharing a Recipe (Export)

1. Open the recipe you want to share.
2. Tap **Share**. The app generates one or more QR codes containing the recipe data.
3. Show your screen to the other person.

For simple recipes, this is a single QR code. For complex recipes with many ingredients, the data is split across multiple **chunks** that auto-cycle on screen.

## Receiving a Recipe (Import / Scan)

1. Tap **Scan** on the Recipe Edit screen.
2. Point your camera at the other person's screen.
3. Keep the camera steady as the QR code chunks cycle. The app reassembles the data as each chunk is captured.
4. Once all chunks are received, the recipe and its ingredients populate the Recipe Edit screen for you to review and save.

---

## Sharing Portions

Portion sharing lets you send a list of food portions — scaled ingredients from a recipe or a logged meal — to another device.

### Where You Can Share From

- **Quantity Edit screen** — Tap **Share** instead of **Add**. Works for plain foods, regular recipes, and dump-only recipes. For dump-only recipes the ingredients are scaled proportionally and shared individually.
- **Meal Portion screen** — Tap a meal header on the Log screen, enter a desired weight, then tap **Share**. All ingredients are scaled to that weight and shared.

### Sending Portions

1. Pick the amount you want on the Quantity Edit or Meal Portion screen.
2. Tap **Share**. The app generates QR codes containing the food definitions and portion data.
3. Show your screen to the other person.

### Include Images Toggle

A switch on the sharing screen controls whether food thumbnail images are embedded in the QR data:

- **On** — Images are included as base64 data. The QR payload is larger (more chunks), but the recipient gets your food images.
- **Off** — Local images are stripped. URL-based thumbnails (e.g., from Open Food Facts) are kept since the recipient can download them independently. Emojis are always included regardless of this setting.

The toggle remembers your last choice.

### Receiving Portions

1. Open the portion scanner (or the recipe scanner — it detects the format automatically).
2. Point your camera at the sender's screen.
3. The app imports the food definitions, saves any embedded images, and adds all portions to your Log Queue.
4. A confirmation tells you how many items were added.

---

!!! info "Multi-chunk QR codes"
    QR codes have a limited data capacity. When a recipe or portion list includes many ingredients or embedded images, the app automatically splits the data into numbered chunks (e.g., 1 of 3, 2 of 3, 3 of 3) that cycle on the sender's screen. The receiver's camera captures them in sequence.
