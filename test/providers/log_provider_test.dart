import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/models/recipe.dart';
import 'package:meal_of_record/models/recipe_item.dart';

void main() {
  late LogProvider logProvider;

  setUp(() {
    logProvider = LogProvider();
  });

  group('LogProvider', () {
    test('should add a food serving to the queue and update calories', () {
      // Arrange
      final food = Food(
        id: 1,
        name: 'Apple',
        calories: 0.52, // per gram
        protein: 0.003,
        fat: 0.002,
        carbs: 0.14,
        fiber: 0.0,
        source: 'test',
        servings: [
          FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final portion = FoodPortion(food: food, grams: 100, unit: 'g');

      // Act
      logProvider.addFoodToQueue(portion);

      // Assert
      // 0.52 calories/g * 1.0 g/unit * 100 units = 52 calories
      expect(logProvider.logQueue.length, 1);
      expect(logProvider.logQueue.first, portion);
      expect(logProvider.queuedCalories, 52);
    });

    test('should remove a food serving from the queue and update calories', () {
      // Arrange
      final food = Food(
        id: 1,
        name: 'Apple',
        calories: 0.52, // per gram
        protein: 0.003,
        fat: 0.002,
        carbs: 0.14,
        fiber: 0.0,
        source: 'test',
        servings: [
          FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final portion = FoodPortion(food: food, grams: 100, unit: 'g');
      logProvider.addFoodToQueue(portion);

      // Act
      logProvider.removeFoodFromQueue(portion);

      // Assert
      expect(logProvider.logQueue.length, 0);
      expect(logProvider.queuedCalories, 0);
    });

    test('should clear the queue and reset calories', () {
      // Arrange
      final food = Food(
        id: 1,
        name: 'Apple',
        calories: 0.52, // per gram
        protein: 0.003,
        fat: 0.002,
        carbs: 0.14,
        fiber: 0.0,
        source: 'test',
        servings: [
          FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final serving = FoodPortion(food: food, grams: 100, unit: 'g');
      logProvider.addFoodToQueue(serving);

      // Act
      logProvider.clearQueue();

      // Assert
      expect(logProvider.logQueue.length, 0);
      expect(logProvider.queuedCalories, 0);
    });

    test(
      'should correctly calculate calories for a serving with a different unit',
      () {
        // Arrange
        final food = Food(
          id: 1,
          name: 'Apple',
          calories: 0.52, // per gram
          protein: 0.003,
          fat: 0.002,
          carbs: 0.14,
          fiber: 0.0,
          source: 'test',
          servings: [
            FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
            FoodServing(
              id: 2,
              foodId: 1,
              unit: 'slice',
              grams: 10.0,
              quantity: 1.0,
            ),
          ],
        );
        final serving = FoodPortion(food: food, grams: 20, unit: 'slice');

        // Act
        logProvider.addFoodToQueue(serving);

        // Assert
        // 2 slices * 10g/slice = 20g
        // 0.52 calories/g * 20g = 10.4 calories
        expect(logProvider.queuedCalories, 10.4);
      },
    );

    test(
      'addRecipeToQueue should add a recipe as a single item if not a template',
      () {
        // Arrange
        final food = Food(
          id: 1,
          name: 'Ingredient',
          calories: 1.0,
          protein: 0.1,
          fat: 0.1,
          carbs: 0.1,
          fiber: 0.0,
          source: 'test',
          servings: [
            FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
          ],
        );
        final recipe = Recipe(
          id: 10,
          name: 'Recipe',
          servingsCreated: 1.0,
          createdTimestamp: 0,
          items: [RecipeItem(id: 1, food: food, grams: 100, unit: 'g')],
        );

        // Act
        logProvider.addRecipeToQueue(recipe);

        // Assert
        expect(logProvider.logQueue.length, 1);
        expect(logProvider.logQueue.first.food.name, 'Recipe');
        expect(logProvider.logQueue.first.grams, 100);
        expect(logProvider.queuedCalories, 100);
      },
    );

    test('addRecipeToQueue should dump a recipe if it is a template', () {
      // Arrange
      final food = Food(
        id: 1,
        name: 'Ingredient',
        calories: 1.0,
        protein: 0.1,
        fat: 0.1,
        carbs: 0.1,
        fiber: 0.0,
        source: 'test',
        servings: [
          FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final recipe = Recipe(
        id: 10,
        name: 'Recipe',
        servingsCreated: 1.0,
        createdTimestamp: 0,
        isTemplate: true,
        items: [RecipeItem(id: 1, food: food, grams: 100, unit: 'g')],
      );

      // Act
      logProvider.addRecipeToQueue(recipe);

      // Assert
      expect(logProvider.logQueue.length, 1);
      expect(logProvider.logQueue.first.food.name, 'Ingredient');
      expect(logProvider.logQueue.first.grams, 100);
      expect(logProvider.queuedCalories, 100);
    });

    test(
      'dumpRecipeToQueue should force decomposition even if not a template',
      () {
        // Arrange
        final food = Food(
          id: 1,
          name: 'Ingredient',
          calories: 1.0,
          protein: 0.1,
          fat: 0.1,
          carbs: 0.1,
          fiber: 0.0,
          source: 'test',
          servings: [
            FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
          ],
        );
        final recipe = Recipe(
          id: 10,
          name: 'Recipe',
          servingsCreated: 1.0,
          createdTimestamp: 0,
          isTemplate: false,
          items: [RecipeItem(id: 1, food: food, grams: 100, unit: 'g')],
        );

        // Act
        logProvider.dumpRecipeToQueue(recipe);

        // Assert
        expect(logProvider.logQueue.length, 1);
        expect(logProvider.logQueue.first.food.name, 'Ingredient');
        expect(logProvider.logQueue.first.grams, 100);
        expect(logProvider.queuedCalories, 100);
      },
    );
  });
}
