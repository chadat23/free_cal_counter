import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/models/food.dart' as model;
import 'package:free_cal_counter1/models/food_portion.dart' as model;
import 'package:free_cal_counter1/models/food_serving.dart' as model;
import 'package:free_cal_counter1/models/macro_goals.dart';
import 'package:free_cal_counter1/models/goal_settings.dart';
import 'package:free_cal_counter1/providers/goals_provider.dart';
import 'package:free_cal_counter1/providers/log_provider.dart';
import 'package:free_cal_counter1/providers/navigation_provider.dart';
import 'package:free_cal_counter1/providers/recipe_provider.dart';
import 'package:free_cal_counter1/providers/search_provider.dart';
import 'package:free_cal_counter1/providers/weight_provider.dart';
import 'package:free_cal_counter1/screens/navigation_container_screen.dart';
import 'package:free_cal_counter1/screens/search_screen.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/open_food_facts_service.dart';
import 'package:free_cal_counter1/services/search_service.dart';
import 'package:free_cal_counter1/models/search_config.dart';
import 'package:free_cal_counter1/models/quantity_edit_config.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:free_cal_counter1/services/live_database.dart';
import 'package:free_cal_counter1/services/reference_database.dart';

import 'clear_on_leave_test.mocks.dart';

@GenerateMocks([
  OffApiService,
  SearchService,
  GoalsProvider,
  RecipeProvider,
  WeightProvider,
])
void main() {
  late LogProvider logProvider;
  late NavigationProvider navigationProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockWeightProvider mockWeightProvider;
  late MockOffApiService mockOffApiService;
  late MockSearchService mockSearchService;

  setUp(() {
    logProvider = LogProvider();
    navigationProvider = NavigationProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockWeightProvider = MockWeightProvider();
    mockOffApiService = MockOffApiService();
    mockSearchService = MockSearchService();

    // Stub GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
    when(mockGoalsProvider.isLoading).thenReturn(false);
    when(mockGoalsProvider.hasSeenWelcome).thenReturn(true);
    when(mockGoalsProvider.isGoalsSet).thenReturn(true);
    when(mockGoalsProvider.showUpdateNotification).thenReturn(false);
    when(mockGoalsProvider.settings).thenReturn(GoalSettings.defaultSettings());

    // Stub RecipeProvider
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);

    // Stub WeightProvider
    when(mockWeightProvider.weights).thenReturn([]);

    // Initialize in-memory databases for testing to avoid DatabaseService errors
    final liveDb = LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: logProvider),
        ChangeNotifierProvider.value(value: navigationProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
        ChangeNotifierProvider<RecipeProvider>.value(value: mockRecipeProvider),
        ChangeNotifierProvider<WeightProvider>.value(value: mockWeightProvider),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            databaseService: DatabaseService.instance,
            offApiService: mockOffApiService,
            searchService: mockSearchService,
          ),
        ),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/food_search') {
            return MaterialPageRoute(
              builder: (context) => const SearchScreen(
                config: SearchConfig(
                  context: QuantityEditContext.day,
                  title: 'Food Search',
                  showQueueStats: true,
                ),
              ),
            );
          }
          return null;
        },
        home: child,
      ),
    );
  }

  testWidgets('switching tabs should clear the queue', (tester) async {
    // Start at Log tab (index 1)
    navigationProvider.changeTab(1);

    await tester.pumpWidget(
      createTestWidget(const NavigationContainerScreen()),
    );

    // Add something to the queue
    logProvider.addFoodToQueue(
      model.FoodPortion(
        food: model.Food(
          id: 1,
          name: 'Test',
          calories: 100,
          protein: 10,
          fat: 5,
          carbs: 20,
          fiber: 0,
          source: 'live',
          servings: [
            const model.FoodServing(
              id: 1,
              foodId: 1,
              unit: 'g',
              grams: 1,
              quantity: 1,
            ),
          ],
        ),
        grams: 100,
        unit: 'g',
      ),
    );
    expect(logProvider.logQueue, isNotEmpty);

    // Tap Overview tab (index 0)
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    expect(navigationProvider.selectedIndex, 0);
    expect(logProvider.logQueue, isEmpty);
  });

  testWidgets('popping SearchScreen should clear the queue', (tester) async {
    await tester.pumpWidget(
      createTestWidget(const Scaffold(body: Text('Home'))),
    );

    // Navigate to Search
    // Note: We need a way to trigger the push. Let's use a simple button.
    final context = tester.element(find.text('Home'));
    Navigator.pushNamed(context, '/food_search');
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);

    // Add something to the queue
    logProvider.addFoodToQueue(
      model.FoodPortion(
        food: model.Food(
          id: 1,
          name: 'Test',
          calories: 100,
          protein: 10,
          fat: 5,
          carbs: 20,
          fiber: 0,
          source: 'live',
          servings: [
            const model.FoodServing(
              id: 1,
              foodId: 1,
              unit: 'g',
              grams: 1,
              quantity: 1,
            ),
          ],
        ),
        grams: 100,
        unit: 'g',
      ),
    );
    expect(logProvider.logQueue, isNotEmpty);

    // Pop the SearchScreen (Simulator of back button)
    Navigator.pop(tester.element(find.byType(SearchScreen)));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsNothing);
    expect(logProvider.logQueue, isEmpty);
  });
}
