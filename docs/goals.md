# Goals & Weight Tracking

Meal of Record uses a data-driven approach to help you reach your weight goals by adjusting your calorie targets based on your actual progress.

---

## Weight Tracking

Consistency is key. The app focuses on your **Weight Trend** rather than individual daily fluctuations.

- **Daily Entry**: Enter your weight once a day. If you enter it twice, the newer value overwrites the old one.
- **Missing Data**: If you miss a day, the app doesn't assume you weigh zero. It intelligently ignores gaps to maintain a clean trend line.
- **Trend Smoothing**: The Overview screen displays a smoothed trend line to help you visualize your true progress past the daily "noise" of water weight.

![[Screenshot: The Weight screen and the resulting Trend Line on the overview graph]](assets/weight_trend.png)

---

## The Calorie Calculation Loop

The app calculates your target intake using a simple but powerful formula:
`Target Intake = Maintenance Intake +/- Delta`

### 1. Maintenance Intake (TDEE)
When you start, you provide an estimated "Starting Maintenance" calorie amount. Over time, as you log food and weight, the app helps you refine this.

### 2. The Delta (Gain/Lose/Maintain)
Your goals are defined by one of three modes:

- **Lose Mode**: You set a *fixed* calorie deficit (e.g., -500 kcal per day).
- **Gain Mode**: You set a *fixed* calorie surplus (e.g., +500 kcal per day).
- **Maintain Mode**: This is the "Smart Mode." The app calculates a delta to correct any "drift" from your **Anchor Weight**. 
  - *Example:* If you are slightly above your anchor weight, the app will automatically suggest a small deficit for a 30-day window to bring you back to your goal.

---

## Weekly Updates

To avoid daily "target chasing," Meal of Record recalculates your active Macro Targets once per week (every Monday).

On the first open of the week, you'll see a notification with your updated targets for the coming seven days. This allows you to plan your week with a stable set of goals.

![[Screenshot: The weekly target update notification]](assets/weekly_update.png)

---

## Macro Splits

You specify your targets for **Protein** and **Fat** in grams. 
- **Carbs** are automatically calculated as the "remainder" of your daily calorie budget. 
- This ensures you hit your essential macro goals while allowing flexibility in your carb intake.
