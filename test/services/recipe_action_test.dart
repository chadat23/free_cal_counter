import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/recipe.dart' as model;
import 'package:meal_of_record/models/recipe_item.dart' as model;
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/models/food_portion.dart' as model;
import 'package:meal_of_record/models/food_serving.dart' as model;
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:meal_of_record/services/reference_database.dart' as ref;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DatabaseService databaseService;
  late LiveDatabase liveDb;
  late ref.ReferenceDatabase refDb;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    liveDb = LiveDatabase(connection: NativeDatabase.memory());
    refDb = ref.ReferenceDatabase(connection: NativeDatabase.memory());
    databaseService = DatabaseService.forTesting(liveDb, refDb);
  });

  tearDown(() async {
    await liveDb.close();
    await refDb.close();
  });

  Future<model.Recipe> createTestRecipe({
    int id = 0,
    String name = 'Test Recipe',
  }) async {
    final ingredient = await databaseService.ensureFoodExists(
      model.Food(
        id: 0,
        name: 'Ingredient',
        source: 'foundation',
        calories: 1.0,
        protein: 0.1,
        fat: 0.1,
        carbs: 0.1,
        fiber: 0.0,
        database: model.FoodDatabase.reference,
        servings: [
          model.FoodServing(foodId: 0, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      ),
    );

    return model.Recipe(
      id: id,
      name: name,
      servingsCreated: 1.0,
      createdTimestamp: DateTime.now().millisecondsSinceEpoch,
      items: [model.RecipeItem(id: 0, food: ingredient, grams: 100, unit: 'g')],
    );
  }

  group('Recipe Actions', () {
    test('saveRecipe should insert a new recipe when id is 0', () async {
      final recipe = await createTestRecipe();
      final id = await databaseService.saveRecipe(recipe);
      expect(id, greaterThan(0));

      final saved = await databaseService.getRecipeById(id);
      expect(saved.name, 'Test Recipe');
    });

    test('saveRecipe should update in place when id > 0', () async {
      final id = await databaseService.saveRecipe(await createTestRecipe());
      final updatedRecipe = await createTestRecipe(
        id: id,
        name: 'Updated Name',
      );

      await databaseService.saveRecipe(updatedRecipe);

      final saved = await databaseService.getRecipeById(id);
      expect(saved.name, 'Updated Name');

      final allRecipes = await liveDb.select(liveDb.recipes).get();
      expect(allRecipes.length, 1);
    });

    test(
      'isRecipeLogged should return true if recipe has been logged',
      () async {
        final recipeId = await databaseService.saveRecipe(
          await createTestRecipe(),
        );
        final recipe = await databaseService.getRecipeById(recipeId);
        final food = recipe.toFood();

        await databaseService.logPortions([
          model.FoodPortion(food: food, grams: 100, unit: 'g'),
        ], DateTime.now());

        final isLogged = await databaseService.isRecipeLogged(recipeId);
        expect(isLogged, isTrue);
      },
    );

    test('deleteRecipe should hide recipe if it is logged', () async {
      final recipeId = await databaseService.saveRecipe(
        await createTestRecipe(),
      );
      final recipe = await databaseService.getRecipeById(recipeId);

      await databaseService.logPortions([
        model.FoodPortion(food: recipe.toFood(), grams: 100, unit: 'g'),
      ], DateTime.now());

      await databaseService.deleteRecipe(recipeId);

      final saved = await databaseService.getRecipeById(recipeId);
      expect(saved.hidden, isTrue);

      final allRecipes = await liveDb.select(liveDb.recipes).get();
      expect(allRecipes.length, 1);
    });

    test(
      'deleteRecipe should perform hard delete if not logged or used',
      () async {
        final recipeId = await databaseService.saveRecipe(
          await createTestRecipe(),
        );

        await databaseService.deleteRecipe(recipeId);

        final allRecipes = await liveDb.select(liveDb.recipes).get();
        expect(allRecipes.isEmpty, isTrue);
      },
    );

    test(
      'isRecipeUsedAsIngredient should return true if used in another recipe',
      () async {
        final ingredientId = await databaseService.saveRecipe(
          await createTestRecipe(name: 'Ingredient'),
        );
        final ingredient = await databaseService.getRecipeById(ingredientId);

        final mainRecipe = model.Recipe(
          id: 0,
          name: 'Main Recipe',
          items: [
            model.RecipeItem(id: 0, recipe: ingredient, grams: 50, unit: 'g'),
          ],
          createdTimestamp: DateTime.now().millisecondsSinceEpoch,
        );

        await databaseService.saveRecipe(mainRecipe);

        final isUsed = await databaseService.isRecipeUsedAsIngredient(
          ingredientId,
        );
        expect(isUsed, isTrue);
      },
    );
    group('RecipeProvider Actions', () {
      // Future: Add widget tests for RecipeProvider and UI interaction
    });
  });
}
