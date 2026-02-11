import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/recipe.dart' as model_recipe;
import 'package:meal_of_record/models/category.dart' as model_cat;
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:meal_of_record/services/reference_database.dart' as ref;
import 'package:drift/drift.dart' hide isNotNull;
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

  group('DatabaseService Phase 3 - Filtering and Search', () {
    test(
      'searchFoodsByName should filter out reference foods that have a live child',
      () async {
        // 1. Insert a food into reference DB
        await refDb
            .into(refDb.foods)
            .insert(
              ref.FoodsCompanion.insert(
                id: const Value(101),
                name: 'Original Apple',
                source: 'foundation',
                caloriesPerGram: 0.5,
                proteinPerGram: 0.01,
                fatPerGram: 0.01,
                carbsPerGram: 0.1,
                fiberPerGram: 0.02,
              ),
            );

        // 2. Insert a child food into live DB referencing the parent ID
        await liveDb
            .into(liveDb.foods)
            .insert(
              FoodsCompanion.insert(
                id: const Value(1),
                name: 'Edited Apple',
                source: 'live',
                caloriesPerGram: 0.6,
                proteinPerGram: 0.02,
                fatPerGram: 0.02,
                carbsPerGram: 0.12,
                fiberPerGram: 0.03,
                sourceFdcId: const Value(101),
              ),
            );

        // 3. Search for 'Apple'
        final results = await databaseService.searchFoodsByName('Apple');

        // 4. Should only find 'Edited Apple'
        expect(results.length, 1);
        expect(results.first.name, 'Edited Apple');
      },
    );

    test(
      'searchFoodsByName should filter out parent foods within the same live DB (recursive)',
      () async {
        // 1. Insert parent food
        final parentId = await liveDb
            .into(liveDb.foods)
            .insert(
              FoodsCompanion.insert(
                name: 'Version 1',
                source: 'live',
                caloriesPerGram: 1.0,
                proteinPerGram: 0.1,
                fatPerGram: 0.1,
                carbsPerGram: 0.1,
                fiberPerGram: 0.0,
              ),
            );

        // 2. Insert child food
        await liveDb
            .into(liveDb.foods)
            .insert(
              FoodsCompanion.insert(
                name: 'Version 2',
                source: 'live',
                caloriesPerGram: 1.1,
                proteinPerGram: 0.2,
                fatPerGram: 0.2,
                carbsPerGram: 0.2,
                fiberPerGram: 0.0,
                parentId: Value(parentId),
              ),
            );

        // 3. Search
        final results = await databaseService.searchFoodsByName('Version');

        // 4. Should only find 'Version 2'
        expect(results.length, 1);
        expect(results.first.name, 'Version 2');
      },
    );

    test('getRecipesBySearch should filter by category if provided', () async {
      // 1. Setup categories
      final catId1 = await databaseService.addCategory('Breakfast');
      final catId2 = await databaseService.addCategory('Dinner');

      // 2. Insert recipes
      await databaseService.saveRecipe(
        model_recipe.Recipe(
          id: 0,
          name: 'Eggs',
          categories: [model_cat.Category(id: catId1, name: 'Breakfast')],
          createdTimestamp: 1000,
        ),
      );
      await databaseService.saveRecipe(
        model_recipe.Recipe(
          id: 0,
          name: 'Steak',
          categories: [model_cat.Category(id: catId2, name: 'Dinner')],
          createdTimestamp: 2000,
        ),
      );

      // 3. Search with category filter
      final resultsBreakfast = await databaseService.getRecipesBySearch(
        '',
        categoryId: catId1,
      );
      expect(resultsBreakfast.length, 1);
      expect(resultsBreakfast.first.name, 'Eggs');

      final resultsDinner = await databaseService.getRecipesBySearch(
        '',
        categoryId: catId2,
      );
      expect(resultsDinner.length, 1);
      expect(resultsDinner.first.name, 'Steak');

      final resultsAll = await databaseService.getRecipesBySearch('');
      expect(resultsAll.length, 2);
    });

    test(
      'saveRecipe and getRecipeById should handle emoji and thumbnail',
      () async {
        final recipe = model_recipe.Recipe(
          id: 0,
          name: 'Custom Recipe',
          emoji: '🍰',
          thumbnail: 'local://image123',
          createdTimestamp: DateTime.now().millisecondsSinceEpoch,
        );

        final id = await databaseService.saveRecipe(recipe);
        final loaded = await databaseService.getRecipeById(id);

        expect(loaded, isNotNull);
        expect(loaded!.emoji, '🍰');
        expect(loaded.thumbnail, 'local://image123');
      },
    );
  });

  group('Recipe Model and Calculations', () {
    test('Recipe.toFood should use portionName as a serving unit', () {
      final recipe = model_recipe.Recipe(
        id: 1,
        name: 'Cookie',
        portionName: 'Cookie',
        servingsCreated: 10.0,
        createdTimestamp: 12345,
        items: [],
      );

      final food = recipe.toFood();
      expect(food.servings.any((s) => s.unit == 'Cookie'), isTrue);
    });

    test('Recipe.toFood should preserve emoji and thumbnail', () {
      final recipe = model_recipe.Recipe(
        id: 1,
        name: 'Cookie',
        emoji: '🍪',
        thumbnail: 'local://cookie.png',
        createdTimestamp: 12345,
      );

      final food = recipe.toFood();
      expect(food.emoji, '🍪');
      expect(food.thumbnail, 'local://cookie.png');
    });
  });
}
