import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/screens/log_screen.dart';
import 'package:meal_of_record/widgets/search_ribbon.dart';
import 'package:meal_of_record/widgets/log_header.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/weight_provider.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:meal_of_record/services/reference_database.dart';
import 'package:drift/native.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/models/logged_portion.dart' as model;
import 'package:meal_of_record/models/food_portion.dart' as model;
import 'package:meal_of_record/models/food_serving.dart' as model_serving;
import 'package:meal_of_record/widgets/meal_widget.dart';
import 'package:meal_of_record/models/search_mode.dart';
import 'log_screen_test.mocks.dart';

@GenerateMocks([
  LogProvider,
  NavigationProvider,
  SearchProvider,
  DatabaseService,
  GoalsProvider,
  WeightProvider,
])
void main() {
  late MockLogProvider mockLogProvider;
  late MockNavigationProvider mockNavigationProvider;
  late MockSearchProvider mockSearchProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockWeightProvider mockWeightProvider;

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockNavigationProvider = MockNavigationProvider();
    mockSearchProvider = MockSearchProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockWeightProvider = MockWeightProvider();

    // Initialize in-memory databases for testing
    final liveDb = LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);

    // Stub actual LogProvider getters
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.totalCalories).thenReturn(0.0);
    when(mockLogProvider.totalProtein).thenReturn(0.0);
    when(mockLogProvider.totalFat).thenReturn(0.0);
    when(mockLogProvider.totalCarbs).thenReturn(0.0);
    when(mockLogProvider.totalFiber).thenReturn(0.0);
    when(mockLogProvider.loggedCalories).thenReturn(0.0);
    when(mockLogProvider.loggedProtein).thenReturn(0.0);
    when(mockLogProvider.loggedFat).thenReturn(0.0);
    when(mockLogProvider.loggedCarbs).thenReturn(0.0);
    when(mockLogProvider.loggedFiber).thenReturn(0.0);
    when(mockLogProvider.isFasted).thenReturn(false);
    // Stub loadLoggedFoodsForDate to avoid null errors if called
    when(
      mockLogProvider.loadLoggedPortionsForDate(any),
    ).thenAnswer((_) async {});
    when(mockLogProvider.loggedPortion).thenReturn([]);
    // Stub multiselect getters
    when(mockLogProvider.selectedPortionIds).thenReturn({});
    when(mockLogProvider.hasSelectedPortions).thenReturn(false);
    when(mockLogProvider.selectedPortionCount).thenReturn(0);
    // Stub multiselect methods
    when(mockLogProvider.togglePortionSelection(any)).thenAnswer((_) {});
    when(mockLogProvider.selectPortion(any)).thenAnswer((_) {});
    when(mockLogProvider.deselectPortion(any)).thenAnswer((_) {});
    when(mockLogProvider.clearSelection()).thenAnswer((_) {});
    when(mockLogProvider.isPortionSelected(any)).thenReturn(false);
    when(mockLogProvider.copySelectedPortionsToQueue()).thenAnswer((_) {});

    // Stub NavigationProvider
    when(mockNavigationProvider.changeTab(any)).thenAnswer((_) {});
    when(mockNavigationProvider.showConsumed).thenReturn(true);

    // Stub SearchProvider
    when(mockSearchProvider.errorMessage).thenReturn(null);
    when(mockSearchProvider.isLoading).thenReturn(false);
    when(mockSearchProvider.searchResults).thenReturn([]);
    when(mockSearchProvider.searchMode).thenReturn(SearchMode.text);

    // Stub GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
    when(mockGoalsProvider.targetFor(any)).thenReturn(MacroGoals.hardcoded());
    when(mockGoalsProvider.settings).thenReturn(GoalSettings.defaultSettings());

    // Stub WeightProvider
    when(mockWeightProvider.recentWeights).thenReturn([]);
    when(mockWeightProvider.loadWeights(any, any)).thenAnswer((_) async {});
    when(mockWeightProvider.getWeightForDate(any)).thenReturn(null);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<NavigationProvider>.value(
          value: mockNavigationProvider,
        ),
        ChangeNotifierProvider<SearchProvider>.value(value: mockSearchProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
        ChangeNotifierProvider<WeightProvider>.value(value: mockWeightProvider),
      ],
      child: const MaterialApp(home: LogScreen()),
    );
  }

  group('LogScreen', () {
    testWidgets('renders LogHeader and SearchRibbon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(LogHeader), findsOneWidget);
      expect(find.byType(SearchRibbon), findsOneWidget);
    });

    testWidgets('groups logs with identical timestamp into one meal', (
      tester,
    ) async {
      final time = DateTime(2023, 10, 20, 10, 20);

      final food = model.Food(
        id: 1,
        name: 'Apple',
        calories: 100,
        protein: 0,
        fat: 0,
        carbs: 20,
        fiber: 0,
        emoji: '🍎',
        source: 'test',
        servings: [
          model_serving.FoodServing(
            id: 1,
            foodId: 1,
            unit: 'g',
            grams: 1.0,
            quantity: 1.0,
          ),
        ],
      );

      final loggedPortion1 = model.LoggedPortion(
        id: 1,
        portion: model.FoodPortion(food: food, grams: 100, unit: 'g'),
        timestamp: time,
      );

      final loggedPortion2 = model.LoggedPortion(
        id: 2,
        portion: model.FoodPortion(food: food, grams: 100, unit: 'g'),
        timestamp: time,
      );

      when(
        mockLogProvider.loggedPortion,
      ).thenReturn([loggedPortion1, loggedPortion2]);

      await tester.pumpWidget(createTestWidget());

      // Should be 1 meal containing both
      expect(find.byType(MealWidget), findsOneWidget);
    });

    testWidgets(
      'separates logs with different timestamps into different meals',
      (tester) async {
        // 10:20
        final time1 = DateTime(2023, 10, 20, 10, 20);
        // 10:21 (Just 1 minute later)
        final time2 = DateTime(2023, 10, 20, 10, 21);

        final food = model.Food(
          id: 1,
          name: 'Apple',
          calories: 100,
          protein: 0,
          fat: 0,
          carbs: 20,
          fiber: 0,
          emoji: '🍎',
          source: 'test',
          servings: [
            model_serving.FoodServing(
              id: 1,
              foodId: 1,
              unit: 'g',
              grams: 1.0,
              quantity: 1.0,
            ),
          ],
        );

        final loggedPortion1 = model.LoggedPortion(
          id: 1,
          portion: model.FoodPortion(food: food, grams: 100, unit: 'g'),
          timestamp: time1,
        );

        final loggedPortion2 = model.LoggedPortion(
          id: 2,
          portion: model.FoodPortion(food: food, grams: 100, unit: 'g'),
          timestamp: time2,
        );

        when(
          mockLogProvider.loggedPortion,
        ).thenReturn([loggedPortion1, loggedPortion2]);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Should be 2 distinct meals
        expect(find.byType(MealWidget), findsNWidgets(2));
      },
    );
  });
}
