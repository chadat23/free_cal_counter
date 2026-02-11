import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/models/food_portion.dart' as model;
import 'package:meal_of_record/models/food_serving.dart' as model;
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/screens/log_queue_screen.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:meal_of_record/services/reference_database.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'repro_log_queue_edit_bug_test.mocks.dart';

@GenerateMocks([OffApiService, SearchService, GoalsProvider, RecipeProvider])
void main() {
  late LogProvider logProvider;
  late NavigationProvider navigationProvider;
  late SearchProvider searchProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockOffApiService mockOffApiService;
  late MockSearchService mockSearchService;

  setUp(() {
    logProvider = LogProvider();
    navigationProvider = NavigationProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockOffApiService = MockOffApiService();
    mockSearchService = MockSearchService();

    searchProvider = SearchProvider(
      databaseService: DatabaseService.instance,
      offApiService: mockOffApiService,
      searchService: mockSearchService,
    );

    // Stub GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());

    // Stub RecipeProvider
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);

    // Initialize in-memory databases for testing
    final liveDb = LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  testWidgets(
    'edit button should open QuantityEditScreen even if food is not in live database',
    (WidgetTester tester) async {
      // Arrange
      final food = model.Food(
        id: 999, // Some ID not in DB
        name: 'Unlogged Food',
        calories: 1.0,
        protein: 0.1,
        fat: 0.1,
        carbs: 0.1,
        fiber: 0.0,
        source: 'off',
        servings: [
          const model.FoodServing(
            id: 1,
            foodId: 999,
            unit: 'g',
            grams: 1.0,
            quantity: 1.0,
          ),
        ],
      );
      final serving = model.FoodPortion(food: food, grams: 100, unit: 'g');
      logProvider.addFoodToQueue(serving);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: logProvider),
            ChangeNotifierProvider.value(value: navigationProvider),
            ChangeNotifierProvider.value(value: searchProvider),
            ChangeNotifierProvider<GoalsProvider>.value(
              value: mockGoalsProvider,
            ),
            ChangeNotifierProvider<RecipeProvider>.value(
              value: mockRecipeProvider,
            ),
          ],
          child: const MaterialApp(home: LogQueueScreen()),
        ),
      );

      // Act: Tap edit button
      final editButton = find.byIcon(Icons.edit_outlined);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      // Use pump instead of pumpAndSettle if there are animations that might not settle easily,
      // or if we just want to see the next frame where the screen is pushed.
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Allow for transition

      // Assert
      expect(find.byType(QuantityEditScreen), findsOneWidget);
    },
  );
}
