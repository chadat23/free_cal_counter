import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/widgets/search/text_search_view.dart';
import 'package:meal_of_record/models/search_config.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/models/search_mode.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'off_is_update_bug_test.mocks.dart';

@GenerateMocks([
  LogProvider,
  SearchProvider,
  NavigationProvider,
  RecipeProvider,
  GoalsProvider,
])
void main() {
  late MockLogProvider mockLogProvider;
  late MockSearchProvider mockSearchProvider;
  late MockNavigationProvider mockNavigationProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockGoalsProvider mockGoalsProvider;

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockSearchProvider = MockSearchProvider();
    mockNavigationProvider = MockNavigationProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockGoalsProvider = MockGoalsProvider();

    when(mockSearchProvider.isLoading).thenReturn(false);
    when(mockSearchProvider.errorMessage).thenReturn(null);
    when(mockSearchProvider.searchMode).thenReturn(SearchMode.text);
    when(mockSearchProvider.isBarcodeSearch).thenReturn(false);
    when(mockSearchProvider.lastScannedBarcode).thenReturn(null);
    when(mockNavigationProvider.showConsumed).thenReturn(true);
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<SearchProvider>.value(value: mockSearchProvider),
        ChangeNotifierProvider<NavigationProvider>.value(
          value: mockNavigationProvider,
        ),
        ChangeNotifierProvider<RecipeProvider>.value(value: mockRecipeProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: TextSearchView(
            config: SearchConfig(
              context: QuantityEditContext.day,
              title: 'Test Search',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Only the added OFF item should show edit icon', (
    WidgetTester tester,
  ) async {
    // Arrange: Two OFF items with same ID (0) but different barcodes
    final food1 = Food(
      id: 0,
      source: 'off',
      name: 'Peanut Butter A',
      calories: 6,
      protein: 0.3,
      fat: 0.5,
      carbs: 0.2,
      fiber: 0.1,
      sourceBarcode: '12345',
      servings: [
        FoodServing(id: 1, foodId: 0, unit: 'g', grams: 1.0, quantity: 1.0),
      ],
    );

    final food2 = Food(
      id: 0,
      source: 'off',
      name: 'Peanut Butter B',
      calories: 6,
      protein: 0.3,
      fat: 0.5,
      carbs: 0.2,
      fiber: 0.1,
      sourceBarcode: '67890',
      servings: [
        FoodServing(id: 2, foodId: 0, unit: 'g', grams: 1.0, quantity: 1.0),
      ],
    );

    when(mockSearchProvider.searchResults).thenReturn([food1, food2]);

    // Simulate food1 being in the queue
    final portion1 = FoodPortion(food: food1, grams: 28, unit: 'g');
    when(mockLogProvider.logQueue).thenReturn([portion1]);

    // Act
    await tester.pumpWidget(createTestWidget());

    // Assert
    // Find the icon for Peanut Butter A (should be edit)
    final tileA = find.ancestor(
      of: find.textContaining('Peanut Butter A'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: tileA, matching: find.byIcon(Icons.edit)),
      findsOneWidget,
    );

    // Find the icon for Peanut Butter B (should be add, but CURRENTLY FAILS and finds edit)
    final tileB = find.ancestor(
      of: find.textContaining('Peanut Butter B'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: tileB, matching: find.byIcon(Icons.add)),
      findsOneWidget,
    );
  });
}
