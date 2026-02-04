import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/models/food.dart' as model;
import 'package:free_cal_counter1/models/food_portion.dart' as model_portion;
import 'package:free_cal_counter1/models/food_serving.dart' as model_unit;
import 'package:free_cal_counter1/models/search_config.dart';
import 'package:free_cal_counter1/models/quantity_edit_config.dart';
import 'package:free_cal_counter1/providers/log_provider.dart';
import 'package:free_cal_counter1/providers/search_provider.dart';
import 'package:free_cal_counter1/widgets/search/text_search_view.dart';
import 'package:free_cal_counter1/screens/quantity_edit_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/live_database.dart';
import 'package:free_cal_counter1/services/reference_database.dart';

import 'package:free_cal_counter1/providers/recipe_provider.dart';
import 'package:free_cal_counter1/providers/goals_provider.dart';
import 'package:free_cal_counter1/models/macro_goals.dart';

import 'search_edit_behavior_test.mocks.dart';

@GenerateMocks([LogProvider, SearchProvider, RecipeProvider, GoalsProvider])
void main() {
  setUpAll(() async {
    final liveDb = LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  group('SearchEditBehavior', () {
    late MockLogProvider mockLogProvider;
    late MockSearchProvider mockSearchProvider;
    late MockRecipeProvider mockRecipeProvider;
    late MockGoalsProvider mockGoalsProvider;

    setUp(() {
      mockLogProvider = MockLogProvider();
      mockSearchProvider = MockSearchProvider();
      mockRecipeProvider = MockRecipeProvider();
      mockGoalsProvider = MockGoalsProvider();

      when(mockLogProvider.logQueue).thenReturn([]);
      when(mockLogProvider.totalCalories).thenReturn(0.0);
      when(mockLogProvider.totalProtein).thenReturn(0.0);
      when(mockLogProvider.totalFat).thenReturn(0.0);
      when(mockLogProvider.totalCarbs).thenReturn(0.0);
      when(mockLogProvider.totalFiber).thenReturn(0.0);

      when(mockSearchProvider.isLoading).thenReturn(false);
      when(mockSearchProvider.errorMessage).thenReturn(null);
      when(mockSearchProvider.isBarcodeSearch).thenReturn(false);
      when(mockSearchProvider.lastScannedBarcode).thenReturn(null);
      when(mockRecipeProvider.totalCalories).thenReturn(0.0);
      when(mockRecipeProvider.totalProtein).thenReturn(0.0);
      when(mockRecipeProvider.totalFat).thenReturn(0.0);
      when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
      when(mockRecipeProvider.totalFiber).thenReturn(0.0);

      when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
    });

    testWidgets(
      'edit button in TextSearchView should open QuantityEditScreen for existing item',
      (tester) async {
        final food = model.Food(
          id: 1,
          name: 'Apple',
          calories: 0.52,
          protein: 0.003,
          fat: 0.002,
          carbs: 0.14,
          fiber: 0.024,
          source: 'test',
          servings: [
            model_unit.FoodServing(
              id: 1,
              foodId: 1,
              unit: 'g',
              grams: 1.0,
              quantity: 1.0,
            ),
          ],
        );

        final portion = model_portion.FoodPortion(
          food: food,
          grams: 100.0,
          unit: 'g',
        );

        when(mockSearchProvider.searchResults).thenReturn([food]);
        when(mockLogProvider.logQueue).thenReturn([portion]);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
              ChangeNotifierProvider<SearchProvider>.value(
                value: mockSearchProvider,
              ),
              ChangeNotifierProvider<RecipeProvider>.value(
                value: mockRecipeProvider,
              ),
              ChangeNotifierProvider<GoalsProvider>.value(
                value: mockGoalsProvider,
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: TextSearchView(
                  config: SearchConfig(
                    context: QuantityEditContext.day,
                    title: 'Search',
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify edit button is shown (due to isUpdate being true)
        // Note: There are 2 edit icons when isUpdate is true (slidable action + trailing button)
        expect(find.byIcon(Icons.edit), findsWidgets);

        // Tap the tile to open QuantityEditScreen (onTap callback handles this correctly)
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();

        // EXPECTED BEHAVIOR (FIXED): It should NOT call addFoodToQueue directly
        verifyNever(mockLogProvider.addFoodToQueue(any));
        // It should open QuantityEditScreen
        expect(find.byType(QuantityEditScreen), findsOneWidget);

        // Verify it opened with isUpdate: true and correct data
        final editScreen = tester.widget<QuantityEditScreen>(
          find.byType(QuantityEditScreen),
        );
        expect(editScreen.config.isUpdate, isTrue);
        expect(editScreen.config.initialQuantity, 100.0);
        expect(editScreen.config.initialUnit, 'g');
      },
    );

    testWidgets(
      'tap on tile in TextSearchView should open QuantityEditScreen for existing item with isUpdate: true',
      (tester) async {
        final food = model.Food(
          id: 1,
          name: 'Apple',
          calories: 0.52,
          protein: 0.003,
          fat: 0.002,
          carbs: 0.14,
          fiber: 0.024,
          source: 'test',
          servings: [
            model_unit.FoodServing(
              id: 1,
              foodId: 1,
              unit: 'g',
              grams: 1.0,
              quantity: 1.0,
            ),
          ],
        );

        final portion = model_portion.FoodPortion(
          food: food,
          grams: 100.0,
          unit: 'g',
        );

        when(mockSearchProvider.searchResults).thenReturn([food]);
        when(mockLogProvider.logQueue).thenReturn([portion]);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
              ChangeNotifierProvider<SearchProvider>.value(
                value: mockSearchProvider,
              ),
              ChangeNotifierProvider<RecipeProvider>.value(
                value: mockRecipeProvider,
              ),
              ChangeNotifierProvider<GoalsProvider>.value(
                value: mockGoalsProvider,
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: TextSearchView(
                  config: SearchConfig(
                    context: QuantityEditContext.day,
                    title: 'Search',
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap the tile
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();

        // EXPECTED BEHAVIOR (FIXED): It opens QuantityEditScreen with isUpdate: true
        final editScreen = tester.widget<QuantityEditScreen>(
          find.byType(QuantityEditScreen),
        );
        expect(editScreen.config.isUpdate, isTrue);
        expect(editScreen.config.initialQuantity, 100.0);
      },
    );
  });
}
