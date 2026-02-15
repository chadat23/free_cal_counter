# Goals & Weig  UDDht Tracking

Meal of Record enables the use of either a data-driven approach to help you reach your weight goals by adjusting your calorie targets based on your actual progress, or a more traditional approach where you set a fixed daily calorie target.

---

## Weight Tracking

Consistency is key. The app focuses on your **Weight Trend** rather than individual daily fluctuations.

- **Daily Entry**: Enter your weight once a day. If you enter it twice, the newer value overwrites the old one.
- **Missing Data**: If you miss a day, the app doesn't assume you weigh zero. It intelligently ignores gaps to maintain a clean trend line.
- **Trend Smoothing**: The Overview screen displays a smoothed trend line to help you visualize your true progress past the daily "noise" of water weight.
- **Easy referencing**: By tapping on a weight point on the graph, you'll see the exact date and weight.

![[Screenshot: The Weight screen and the resulting Trend Line on the overview graph]](assets/weight_trend.png)

---

## The Calorie Calculation Loop

The app calculates your target intake using a simple but powerful formula:
`Target Intake = Maintenance Intake +/- Delta`

### 1. Maintenance Intake (TDEE)
When you start, you provide an estimated "Starting Maintenance" calorie amount. Over time, as you log food and weight, the app helps you refine this. This Standard Mantenance calory amount can be calculated via any number of websites, and while it'd obviously better to have a more accurate initial estimate, since the app learns and adjusts, there's no need to frett if it's a bit off.

### 2. The Delta (Gain/Lose/Maintain)
Your goals are defined by one of three modes:

- **Lose Mode**: You set a *fixed* calorie deficit (e.g., -500 kcal per day).
- **Gain Mode**: You set a *fixed* calorie surplus (e.g., +250 kcal per day).
- **Maintain Mode**: This is the "Smart Mode." The app calculates a delta to correct any "drift" from your **Anchor Weight**. 
  - *Example:* If you are slightly above your anchor weight, the app will automatically suggest a small deficit for a 30-day window to bring you back to your goal.

---

## Weekly Updates

To avoid daily "target chasing," Meal of Record recalculates your active Macro Targets once per week (every Monday).

On the first open of the week, you'll see a notification with your updated targets for the coming seven days. This allows you to plan your week with a stable set of goals.

![[Screenshot: The weekly target update notification]](assets/weekly_update.png)
---

## Macro Splits
Given the independent popularities of low carb diets and high carb diets there are two basic macro calculating strategies: specifying fat or carbs with the other being calculated as the remainder of the day's calories after protein is accounted for.
- **Protein**: Protein can either be a fix amount (convenient for individuals who aren't planning appreciable weight changes), or calculated via a weight multiplier (ideal for people targetting appreciable weight gain or loss) where 0.5-1.0 grams of protein per pound of bodyweight is typically recomended.
- **Fat**: Can be caluclated (a convenient approach for low carb diets), or specified for high carb diets (some say that typical men need 70-85g daily for homones or about 50-65g per day for women).
- **Carbs**: Can be calculated (cenvent for those following typical fulling stregeties for athletic performance), or specified for low carb diets.
