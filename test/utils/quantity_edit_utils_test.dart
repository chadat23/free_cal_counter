import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/utils/quantity_edit_utils.dart';

void main() {
  final mockFood = Food(
    id: 1,
    source: 'USDA',
    name: 'Apple',
    calories: 0.52,
    protein: 0.003,
    fat: 0.002,
    carbs: 0.14,
    fiber: 0.024,
    servings: [
      FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
      FoodServing(foodId: 1, unit: 'piece', grams: 182.0, quantity: 1.0),
    ],
  );

  group('QuantityEditUtils.calculateGrams', () {
    test('calculates grams for Unit target', () {
      final grams = QuantityEditUtils.calculateGrams(
        quantity: 2.0,
        food: mockFood,
        selectedUnit: 'piece',
        selectedTargetIndex: 0,
      );
      expect(grams, 364.0);
    });

    test('calculates grams for Calories target', () {
      final grams = QuantityEditUtils.calculateGrams(
        quantity: 52.0,
        food: mockFood,
        selectedUnit: 'piece', // Ignored for macro targets
        selectedTargetIndex: 1,
      );
      expect(grams, 100.0);
    });

    test('calculates grams for Protein target', () {
      final grams = QuantityEditUtils.calculateGrams(
        quantity: 3.0,
        food: mockFood,
        selectedUnit: 'g',
        selectedTargetIndex: 2,
      );
      // grams = target_protein (3.0) / protein_per_gram (0.003) = 1000.0
      expect(grams, 1000.0);
    });
  });

  group('QuantityEditUtils.calculatePortionMacros', () {
    test('calculates macros correctly with divisor 1.0', () {
      final macros = QuantityEditUtils.calculatePortionMacros(
        mockFood,
        100.0,
        1.0,
      );
      expect(macros['Calories'], closeTo(52.0, 0.01));
      expect(macros['Protein'], closeTo(0.3, 0.01));
      expect(macros['Fat'], closeTo(0.2, 0.01));
      expect(macros['Carbs'], closeTo(14.0, 0.01));
      expect(macros['Fiber'], closeTo(2.4, 0.01));
    });

    test('calculates macros correctly with divisor 2.0 (Per Serving)', () {
      final macros = QuantityEditUtils.calculatePortionMacros(
        mockFood,
        100.0,
        2.0,
      );
      expect(macros['Calories'], closeTo(26.0, 0.01));
      expect(macros['Protein'], closeTo(0.15, 0.01));
    });
  });

  group('QuantityEditUtils.calculateParentProjectedMacros', () {
    test('projects macros adding new item', () {
      final projected = QuantityEditUtils.calculateParentProjectedMacros(
        totalCalories: 500.0,
        totalProtein: 20.0,
        totalFat: 10.0,
        totalCarbs: 80.0,
        totalFiber: 10.0,
        food: mockFood,
        currentGrams: 100.0, // +52 cal, +2.4 fiber
        originalGrams: 0.0,
        divisor: 1.0,
      );
      expect(projected['Calories'], 552.0);
      expect(projected['Fiber'], 12.4);
    });

    test('projects macros updating existing item', () {
      final projected = QuantityEditUtils.calculateParentProjectedMacros(
        totalCalories: 552.0,
        totalProtein: 20.3,
        totalFat: 10.2,
        totalCarbs: 94.0,
        totalFiber: 12.4,
        food: mockFood,
        currentGrams:
            200.0, // +104 cal instead of 52, +4.8 fiber instead of 2.4
        originalGrams: 100.0, // -52 cal, -2.4 fiber
        divisor: 1.0,
      );
      expect(projected['Calories'], 604.0);
      expect(projected['Fiber'], 14.8);
    });
  });
}
