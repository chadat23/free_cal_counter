import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food_serving.dart';

void main() {
  group('FoodServing Math Helpers', () {
    test('gramsPerUnit calculates correctly', () {
      // 50g serving size with quantity 2 (e.g. 2 slices = 50g)
      const serving = FoodServing(
        foodId: 1,
        unit: 'slice',
        grams: 50.0,
        quantity: 2.0,
      );

      // 50 / 2 = 25g per unit
      expect(serving.gramsPerUnit, 25.0);
    });

    test('quantityFromGrams calculates correctly', () {
      // 50g serving size with quantity 2 (e.g. 2 slices = 50g)
      const serving = FoodServing(
        foodId: 1,
        unit: 'slice',
        grams: 50.0,
        quantity: 2.0,
      );

      // 25g should be 1 unit
      expect(serving.quantityFromGrams(25.0), 1.0);

      // 75g should be 3 units
      expect(serving.quantityFromGrams(75.0), 3.0);
    });

    test('gramsFromQuantity calculates correctly', () {
      // 50g serving size with quantity 2 (e.g. 2 slices = 50g)
      const serving = FoodServing(
        foodId: 1,
        unit: 'slice',
        grams: 50.0,
        quantity: 2.0,
      );

      // 1.5 units should be 37.5g (1.5 * 25)
      expect(serving.gramsFromQuantity(1.5), 37.5);
    });

    test('handles zero quantity gracefully', () {
      const serving = FoodServing(
        foodId: 1,
        unit: 'g',
        grams: 0.0,
        quantity: 0.0,
      );

      expect(serving.gramsPerUnit, isNaN); // 0/0 is NaN
      // If gramsPerUnit is NaN, subsequent calcs might be weird.
      // But typically quantity shouldn't be 0.
    });
  });
}
