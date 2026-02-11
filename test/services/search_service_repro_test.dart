import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/services/live_database.dart' as live_db;
import 'package:meal_of_record/services/reference_database.dart' as ref_db;
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:meal_of_record/services/food_sorting_service.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';

class FakeOffApiService extends OffApiService {
  @override
  Future<List<model.Food>> searchFoodsByName(String query) async => [];
  @override
  Future<model.Food?> fetchFoodByBarcode(String barcode) async => null;
}

void main() {
  late DatabaseService databaseService;
  late live_db.LiveDatabase liveDatabase;
  late ref_db.ReferenceDatabase referenceDatabase;
  late FakeOffApiService mockOffApiService;
  late SearchService searchService;

  setUp(() {
    liveDatabase = live_db.LiveDatabase(connection: NativeDatabase.memory());
    referenceDatabase = ref_db.ReferenceDatabase(
      connection: NativeDatabase.memory(),
    );
    databaseService = DatabaseService.forTesting(
      liveDatabase,
      referenceDatabase,
    );
    mockOffApiService = FakeOffApiService();
    searchService = SearchService(
      databaseService: databaseService,
      offApiService: mockOffApiService,
      emojiForFoodName: (name) => '🍎',
      sortingService: FoodSortingService(),
    );
  });

  tearDown(() async {
    await liveDatabase.close();
    await referenceDatabase.close();
  });

  test(
    'Logged "contains" match should outrank unlogged "startsWith" match',
    () async {
      // Arrange

      // 1. A food that contains "extra" and IS logged (Live DB)
      await liveDatabase
          .into(liveDatabase.foods)
          .insert(
            live_db.FoodsCompanion.insert(
              id: const Value(1),
              name: 'Skippy Extra Crunchy',
              source: 'user_created',
              caloriesPerGram: 1.0,
              proteinPerGram: 0.1,
              fatPerGram: 0.1,
              carbsPerGram: 0.1,
              fiberPerGram: 0.1,
            ),
          );
      // Log it 10 times to ensure it has stats
      for (int i = 0; i < 10; i++) {
        await liveDatabase
            .into(liveDatabase.loggedPortions)
            .insert(
              live_db.LoggedPortionsCompanion.insert(
                foodId: const Value(1),
                logTimestamp: DateTime.now().millisecondsSinceEpoch,
                grams: 100,
                unit: 'g',
                quantity: 100,
              ),
            );
      }

      // 2. A food that starts with "extra" but is NOT logged (Reference DB)
      await referenceDatabase
          .into(referenceDatabase.foods)
          .insert(
            ref_db.FoodsCompanion.insert(
              id: const Value(100),
              name: 'Extra White Bread',
              source: 'reference',
              caloriesPerGram: 1.0,
              proteinPerGram: 0.1,
              fatPerGram: 0.1,
              carbsPerGram: 0.1,
              fiberPerGram: 0.1,
            ),
          );

      // 3. A recipe that starts with "extra" (should be EXCLUDED from searchLocal)
      await liveDatabase
          .into(liveDatabase.recipes)
          .insert(
            live_db.RecipesCompanion.insert(
              id: const Value(200),
              name: 'Extra Fancy Salad',
              createdTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );

      // Act
      final results = await searchService.searchLocal('extra');

      // Assert
      expect(
        results.length,
        2,
        reason: 'Recipes should be excluded from general search',
      );

      // 'Skippy Extra Crunchy' is Live/Logged, so it should be first
      expect(results.first.name, 'Skippy Extra Crunchy');
      expect(results.last.name, 'Extra White Bread');
    },
  );

  test(
    'Recipe search should return recipes and use weighted sorting',
    () async {
      // Arrange
      await liveDatabase
          .into(liveDatabase.recipes)
          .insert(
            live_db.RecipesCompanion.insert(
              id: const Value(200),
              name: 'Extra Fancy Salad',
              createdTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      // Log the recipe
      await liveDatabase
          .into(liveDatabase.loggedPortions)
          .insert(
            live_db.LoggedPortionsCompanion.insert(
              recipeId: const Value(200),
              logTimestamp: DateTime.now().millisecondsSinceEpoch,
              grams: 100,
              unit: 'g',
              quantity: 100,
            ),
          );

      await liveDatabase
          .into(liveDatabase.recipes)
          .insert(
            live_db.RecipesCompanion.insert(
              id: const Value(201),
              name: 'Extra Simple Toast',
              createdTimestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );

      // Act
      final results = await searchService.searchRecipesOnly('extra');

      // Assert
      expect(results.length, 2);
      // 'Extra Fancy Salad' is logged, so it should be first
      expect(results.first.name, 'Extra Fancy Salad');
      expect(results.last.name, 'Extra Simple Toast');
    },
  );
}
