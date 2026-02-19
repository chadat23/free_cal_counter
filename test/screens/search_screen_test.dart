import 'package:flutter/material.dart';
import 'package:meal_of_record/widgets/log_queue_top_ribbon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/screens/search_screen.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:meal_of_record/widgets/search_ribbon.dart';
import 'package:meal_of_record/models/search_mode.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:drift/native.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart' as live_db;
import 'package:meal_of_record/services/reference_database.dart' as ref_db;

import 'package:meal_of_record/models/search_config.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';

import 'search_screen_test.mocks.dart';

@GenerateMocks([
  LogProvider,
  NavigationProvider,
  SearchProvider,
  RecipeProvider,
  GoalsProvider,
])
void main() {
  late MockLogProvider mockLogProvider;
  late MockNavigationProvider mockNavigationProvider;
  late MockSearchProvider mockSearchProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockGoalsProvider mockGoalsProvider;

  setUpAll(() async {
    // Initialize DatabaseService with in-memory databases for testing
    final liveDb = live_db.LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ref_db.ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockNavigationProvider = MockNavigationProvider();
    mockSearchProvider = MockSearchProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockGoalsProvider = MockGoalsProvider();
    when(mockNavigationProvider.shouldFocusSearch).thenReturn(false);
    when(mockNavigationProvider.resetSearchFocus()).thenReturn(null);
    when(mockNavigationProvider.showConsumed).thenReturn(true);
    when(mockSearchProvider.searchResults).thenReturn([]);
    when(mockSearchProvider.isLoading).thenReturn(false);
    when(mockSearchProvider.errorMessage).thenReturn(null);
    when(mockSearchProvider.searchMode).thenReturn(SearchMode.text);
    when(mockSearchProvider.isBarcodeSearch).thenReturn(false);
    when(mockSearchProvider.lastScannedBarcode).thenReturn(null);
    when(mockSearchProvider.displayNotes).thenReturn({});

    // Default mocks for macros to avoid null errors in LogQueueTopRibbon
    when(mockLogProvider.totalCalories).thenReturn(0.0);
    when(mockLogProvider.totalProtein).thenReturn(0.0);
    when(mockLogProvider.totalFat).thenReturn(0.0);
    when(mockLogProvider.totalCarbs).thenReturn(0.0);
    when(mockLogProvider.totalFiber).thenReturn(0.0);
    when(mockLogProvider.queuedCalories).thenReturn(0.0);
    when(mockLogProvider.queuedProtein).thenReturn(0.0);
    when(mockLogProvider.queuedFat).thenReturn(0.0);
    when(mockLogProvider.queuedCarbs).thenReturn(0.0);
    when(mockLogProvider.queuedFiber).thenReturn(0.0);
    when(mockLogProvider.loggedCalories).thenReturn(0.0);
    when(mockLogProvider.loggedProtein).thenReturn(0.0);
    when(mockLogProvider.loggedFat).thenReturn(0.0);
    when(mockLogProvider.loggedCarbs).thenReturn(0.0);
    when(mockLogProvider.loggedFiber).thenReturn(0.0);

    // Default mocks for RecipeProvider
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);

    // Default mocks for GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<NavigationProvider>.value(
          value: mockNavigationProvider,
        ),
        ChangeNotifierProvider<SearchProvider>.value(value: mockSearchProvider),
        ChangeNotifierProvider<RecipeProvider>.value(value: mockRecipeProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
      ],
      child: const MaterialApp(
        home: SearchScreen(
          config: SearchConfig(
            context: QuantityEditContext.day,
            title: 'Food Search',
            showQueueStats: true,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'SearchScreen displays error message when errorMessage is not null',
    (WidgetTester tester) async {
      when(mockLogProvider.logQueue).thenReturn([]);
      when(mockLogProvider.totalCalories).thenReturn(0.0);
      when(mockSearchProvider.isLoading).thenReturn(false);
      when(mockSearchProvider.errorMessage).thenReturn('Test Error Message');

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Error Message'), findsOneWidget);
    },
  );

  testWidgets(
    'SearchScreen displays a CircularProgressIndicator when loading',
    (WidgetTester tester) async {
      when(mockLogProvider.logQueue).thenReturn([]);
      when(mockLogProvider.totalCalories).thenReturn(0.0);
      when(mockSearchProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('SearchScreen has a close button and LogQueueTopRibbon', (
    WidgetTester tester,
  ) async {
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.totalCalories).thenReturn(0.0);

    await tester.pumpWidget(createTestWidget());

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byType(LogQueueTopRibbon), findsOneWidget);
  });

  testWidgets('SearchScreen has a SearchRibbon', (WidgetTester tester) async {
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.totalCalories).thenReturn(0.0);

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(SearchRibbon), findsOneWidget);
  });

  testWidgets('tapping close button pops screen when queue is empty', (
    tester,
  ) async {
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.totalCalories).thenReturn(0.0);
    when(mockNavigationProvider.changeTab(any)).thenReturn(null);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    verify(mockNavigationProvider.goBack()).called(1);
  });

  testWidgets('shows discard dialog when queue is not empty', (tester) async {
    final food = Food(
      id: 1,
      name: 'Apple',
      calories: 52,
      protein: 0.3,
      fat: 0.2,
      carbs: 14,
      fiber: 0.0,
      emoji: '🍎',
      source: 'test',
      servings: [],
    );
    final serving = FoodPortion(food: food, grams: 1, unit: 'g');
    when(mockLogProvider.logQueue).thenReturn([serving]);
    when(mockLogProvider.totalCalories).thenReturn(52.0);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('tapping on a search result navigates to QuantityEditScreen', (
    tester,
  ) async {
    final food = Food(
      id: 1,
      name: 'Apple',
      calories: 52,
      protein: 0.3,
      fat: 0.2,
      carbs: 14,
      fiber: 0.0,
      emoji: '🍎',
      source: 'test',
      servings: [
        FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
      ],
    );
    when(mockSearchProvider.searchResults).thenReturn([food]);
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.totalCalories).thenReturn(0.0);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.byType(QuantityEditScreen), findsOneWidget);
  });

  testWidgets(
    'should display food icons in the top ribbon when queue is not empty',
    (tester) async {
      final food = Food(
        id: 1,
        name: 'Apple',
        calories: 52,
        protein: 0.3,
        fat: 0.2,
        carbs: 14,
        fiber: 0.0,
        emoji: '🍎',
        source: 'test',
        servings: [
          FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final serving = FoodPortion(food: food, grams: 1, unit: 'g');
      when(mockLogProvider.logQueue).thenReturn([serving]);
      when(mockLogProvider.totalCalories).thenReturn(52.0);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('🍎'), findsOneWidget);
    },
  );
}
