import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/screens/log_queue_screen.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'log_queue_screen_test.mocks.dart';

@GenerateMocks([DatabaseService, OffApiService, SearchService])
void main() {
  late LogProvider logProvider;
  late NavigationProvider navigationProvider;
  late SearchProvider searchProvider;
  late MockDatabaseService mockDatabaseService;
  late MockOffApiService mockOffApiService;
  late MockSearchService mockSearchService;
  late GoalsProvider goalsProvider;

  setUp(() {
    logProvider = LogProvider();
    navigationProvider = NavigationProvider();
    mockDatabaseService = MockDatabaseService();
    mockOffApiService = MockOffApiService();
    mockSearchService = MockSearchService();
    searchProvider = SearchProvider(
      databaseService: mockDatabaseService,
      offApiService: mockOffApiService,
      searchService: mockSearchService,
    );
    goalsProvider = GoalsProvider();
  });

  testWidgets('should display food servings from the log queue', (
    WidgetTester tester,
  ) async {
    // Arrange
    final food = Food(
      id: 1,
      name: 'Apple',
      calories: 52,
      protein: 0.3,
      fat: 0.2,
      carbs: 14,
      fiber: 0.0,
      source: 'test',
      servings: [
        FoodServing(id: 1, foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
      ],
    );
    final serving = FoodPortion(food: food, grams: 100, unit: 'g');
    logProvider.addFoodToQueue(serving);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: logProvider),
          ChangeNotifierProvider.value(value: navigationProvider),
          ChangeNotifierProvider.value(value: searchProvider),
          ChangeNotifierProvider.value(value: goalsProvider),
        ],
        child: const MaterialApp(home: LogQueueScreen()),
      ),
    );

    // Assert
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('100 g'), findsOneWidget);
  });
}
