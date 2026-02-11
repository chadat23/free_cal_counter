import 'package:meal_of_record/models/food.dart';

class QuantityEditUtils {
  /// Calculates total grams based on quantity and selected target (Unit or Macro).
  static double calculateGrams({
    required double quantity,
    required Food food,
    required String selectedUnit,
    required int selectedTargetIndex,
  }) {
    if (selectedTargetIndex == 0) {
      // Unit target
      final serving = food.servings.firstWhere(
        (s) => s.unit == selectedUnit,
        orElse: () => food.servings.first,
      );
      return serving.gramsFromQuantity(quantity);
    } else {
      // Macro target (1: Cal, 2: Protein, 3: Fat, 4: Carbs, 5: Fiber)
      double perGram;
      switch (selectedTargetIndex) {
        case 1:
          perGram = food.calories;
          break;
        case 2:
          perGram = food.protein;
          break;
        case 3:
          perGram = food.fat;
          break;
        case 4:
          perGram = food.carbs;
          break;
        case 5:
          perGram = food.fiber;
          break;
        default:
          perGram = 1.0;
      }
      return perGram > 0 ? quantity / perGram : 0.0;
    }
  }

  /// Calculates macros for a specific portion size.
  static Map<String, double> calculatePortionMacros(
    Food food,
    double grams,
    double divisor,
  ) {
    return {
      'Calories': (food.calories * grams) / divisor,
      'Protein': (food.protein * grams) / divisor,
      'Fat': (food.fat * grams) / divisor,
      'Carbs': (food.carbs * grams) / divisor,
      'Fiber': (food.fiber * grams) / divisor,
    };
  }

  /// Calculates projected total macros for a parent context (Day or Recipe).
  static Map<String, double> calculateParentProjectedMacros({
    required double totalCalories,
    required double totalProtein,
    required double totalFat,
    required double totalCarbs,
    required double totalFiber,
    required Food food,
    required double currentGrams,
    required double originalGrams,
    required double divisor,
  }) {
    final double calories =
        (totalCalories -
            (food.calories * originalGrams) +
            (food.calories * currentGrams)) /
        divisor;
    final double protein =
        (totalProtein -
            (food.protein * originalGrams) +
            (food.protein * currentGrams)) /
        divisor;
    final double fat =
        (totalFat - (food.fat * originalGrams) + (food.fat * currentGrams)) /
        divisor;
    final double carbs =
        (totalCarbs -
            (food.carbs * originalGrams) +
            (food.carbs * currentGrams)) /
        divisor;
    final double fiber =
        (totalFiber -
            (food.fiber * originalGrams) +
            (food.fiber * currentGrams)) /
        divisor;

    return {
      'Calories': calories,
      'Protein': protein,
      'Fat': fat,
      'Carbs': carbs,
      'Fiber': fiber,
    };
  }
}
