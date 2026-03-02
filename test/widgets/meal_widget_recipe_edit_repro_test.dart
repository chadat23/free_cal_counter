import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/models/food_portion.dart' as model;
import 'package:meal_of_record/models/logged_portion.dart' as model;
import 'package:meal_of_record/models/meal.dart' as model;
import 'package:meal_of_record/models/recipe.dart' as model;
import 'package:meal_of_record/models/recipe_item.dart' as model;
import 'package:meal_of_record/widgets/meal_widget.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:meal_of_record/services/reference_database.dart' as ref;
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:meal_of_record/models/macro_goals.dart';

import 'package:meal_of_record/providers/navigation_provider.dart';

import 'meal_widget_recipe_edit_repro_test.mocks.dart';

@GenerateMocks([LogProvider, RecipeProvider, GoalsProvider, NavigationProvider])
void main() {
  late MockLogProvider mockLogProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockNavigationProvider mockNavigationProvider;
  late LiveDatabase liveDatabase;
  late ref.ReferenceDatabase referenceDatabase;

  setUp(() async {
    mockLogProvider = MockLogProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockNavigationProvider = MockNavigationProvider();
    liveDatabase = LiveDatabase(connection: NativeDatabase.memory());
    referenceDatabase = ref.ReferenceDatabase(
      connection: NativeDatabase.memory(),
    );
    DatabaseService.initSingletonForTesting(liveDatabase, referenceDatabase);

    // Stub LogProvider
    when(mockLogProvider.selectedPortionIds).thenReturn({});
    when(mockLogProvider.hasSelectedPortions).thenReturn(false);
    when(mockLogProvider.isPortionSelected(any)).thenReturn(false);
    when(mockLogProvider.totalCalories).thenReturn(0.0);
    when(mockLogProvider.totalProtein).thenReturn(0.0);
    when(mockLogProvider.totalFat).thenReturn(0.0);
    when(mockLogProvider.totalCarbs).thenReturn(0.0);
    when(mockLogProvider.totalFiber).thenReturn(0.0);

    // Stub RecipeProvider
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);

    // Stub GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(
      MacroGoals(calories: 2000, protein: 150, fat: 70, carbs: 250, fiber: 30),
    );
    when(mockGoalsProvider.targetFor(any)).thenReturn(MacroGoals.hardcoded());

    when(mockNavigationProvider.showConsumed).thenReturn(true);
  });

  tearDown(() async {
    await liveDatabase.close();
    await referenceDatabase.close();
  });

  testWidgets('Reproduction: Editing a recipe opens the wrong food if IDs overlap', (
    WidgetTester tester,
  ) async {
    // ... setup code ...
    // 1. Setup: A Recipe and a Food with the same ID
    const sameId = 5;

    // Insert Food item for recipe
    await liveDatabase
        .into(liveDatabase.foods)
        .insert(
          FoodsCompanion.insert(
            id: const Value(10),
            name: 'Ingredient',
            source: 'live',
            caloriesPerGram: 1.0,
            proteinPerGram: 0.1,
            fatPerGram: 0.1,
            carbsPerGram: 0.1,
            fiberPerGram: 0.1,
          ),
        );

    // Insert Recipe
    await liveDatabase
        .into(liveDatabase.recipes)
        .insert(
          RecipesCompanion.insert(
            id: const Value(sameId),
            name: 'My Special Recipe',
            servingsCreated: const Value(1.0),
            portionName: const Value('portion'),
            createdTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // Add item to recipe
    await liveDatabase
        .into(liveDatabase.recipeItems)
        .insert(
          RecipeItemsCompanion.insert(
            recipeId: sameId,
            ingredientFoodId: const Value(10),
            grams: 100,
            unit: 'g',
          ),
        );

    // Insert Food with same ID (the bug trigger)
    await liveDatabase
        .into(liveDatabase.foods)
        .insert(
          FoodsCompanion.insert(
            id: const Value(sameId),
            name: 'Overlap Food',
            source: 'live',
            caloriesPerGram: 2.0,
            proteinPerGram: 0.2,
            fatPerGram: 0.2,
            carbsPerGram: 0.2,
            fiberPerGram: 0.2,
          ),
        );

    final ingredient = model.Food(
      id: 10,
      name: 'Ingredient',
      source: 'live',
      calories: 1.0,
      protein: 0.1,
      fat: 0.1,
      carbs: 0.1,
      fiber: 0.1,
    );

    final recipe = model.Recipe(
      id: sameId,
      name: 'My Special Recipe',
      createdTimestamp: DateTime.now().millisecondsSinceEpoch,
      items: [model.RecipeItem(id: 1, food: ingredient, grams: 100, unit: 'g')],
    );

    final loggedPortion = model.LoggedPortion(
      id: 1,
      portion: model.FoodPortion(
        food: recipe.toFood(), // source is 'recipe'
        grams: 100,
        unit: 'portion',
      ),
      timestamp: DateTime.now(),
    );

    final meal = model.Meal(
      timestamp: DateTime.now(),
      loggedPortion: [loggedPortion],
    );

    // 2. Build MealWidget
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
          ChangeNotifierProvider<RecipeProvider>.value(
            value: mockRecipeProvider,
          ),
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<NavigationProvider>.value(
            value: mockNavigationProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MealWidget(meal: meal)),
        ),
      ),
    );

    // 3. Act: Click edit
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // 4. Assert: We expect My Special Recipe, but we get Overlap Food (the bug)
    // In the bug state, find.text('Overlap Food') will succeed.
    // In the fixed state, find.text('My Special Recipe') should be visible on QuantityEditScreen.

    // Verify it opened QuantityEditScreen
    expect(find.byType(QuantityEditScreen), findsOneWidget);

    // Check which food is displayed.
    // Fixed state: it should find 'My Special Recipe' because we now use getRecipeById.
    expect(find.text('My Special Recipe'), findsOneWidget);
    expect(find.text('Overlap Food'), findsNothing);
  });
}
