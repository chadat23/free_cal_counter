import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/logged_portion.dart';
import 'package:meal_of_record/models/meal.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/widgets/meal_widget.dart';
import 'package:meal_of_record/widgets/slidable_portion_widget.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'meal_widget_test.mocks.dart';

@GenerateMocks([LogProvider])
void main() {
  late MockLogProvider mockLogProvider;

  setUp(() {
    mockLogProvider = MockLogProvider();
    // Stub multiselect methods
    when(mockLogProvider.selectedPortionIds).thenReturn({});
    when(mockLogProvider.hasSelectedPortions).thenReturn(false);
    when(mockLogProvider.selectedPortionCount).thenReturn(0);
    when(mockLogProvider.togglePortionSelection(any)).thenAnswer((_) {});
    when(mockLogProvider.selectPortion(any)).thenAnswer((_) {});
    when(mockLogProvider.deselectPortion(any)).thenAnswer((_) {});
    when(mockLogProvider.clearSelection()).thenAnswer((_) {});
    when(mockLogProvider.isPortionSelected(any)).thenReturn(false);
  });

  testWidgets('Meal widget displays correctly', (WidgetTester tester) async {
    // Given
    final food1 = Food(
      id: 1,
      name: 'Apple',
      emoji: '🍎',
      calories: 0.52,
      protein: 0.0025,
      fat: 0.002,
      carbs: 0.14,
      fiber: 0.024,
      source: 'test',
      servings: [FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0)],
    );
    final serving1 = FoodPortion(food: food1, grams: 100, unit: 'g');
    final loggedPortion1 = LoggedPortion(
      portion: serving1,
      timestamp: DateTime.now(),
    );

    final food2 = Food(
      id: 2,
      name: 'Banana',
      emoji: '🍌',
      calories: 0.89,
      protein: 0.01,
      fat: 0.003,
      carbs: 0.23,
      fiber: 0.026,
      source: 'test',
      servings: [FoodServing(foodId: 2, unit: 'g', grams: 1.0, quantity: 1.0)],
    );
    final serving2 = FoodPortion(food: food2, grams: 150, unit: 'g');
    final loggedPortion2 = LoggedPortion(
      portion: serving2,
      timestamp: DateTime.now(),
    );

    final meal = Meal(
      timestamp: DateTime.now(),
      loggedPortion: [loggedPortion1, loggedPortion2],
    );

    // When
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ],
        child: MaterialApp(
          home: Scaffold(body: MealWidget(meal: meal)),
        ),
      ),
    );

    // Then
    expect(find.text(DateFormat.jm().format(meal.timestamp)), findsOneWidget);
    expect(find.text('🔥185'), findsOneWidget);
    expect(find.text('P: 2'), findsOneWidget);
    expect(find.text('F: 1'), findsOneWidget);
    expect(find.text('C: 49'), findsOneWidget);
    expect(find.text('Fb: 6'), findsOneWidget);
    expect(find.byType(SlidablePortionWidget), findsNWidgets(2));
  });

  testWidgets('Meal widget triggers onFoodDeleted', (
    WidgetTester tester,
  ) async {
    // Given
    bool deleteCalled = false;
    final food = Food(
      id: 1,
      name: 'Apple',
      emoji: '🍎',
      calories: 0.52,
      protein: 0.0025,
      fat: 0.002,
      carbs: 0.14,
      fiber: 0.024,
      source: 'test',
      servings: [FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0)],
    );
    final serving = FoodPortion(food: food, grams: 100, unit: 'g');
    final loggedPortion = LoggedPortion(
      portion: serving,
      timestamp: DateTime.now(),
    );
    final meal = Meal(
      timestamp: DateTime.now(),
      loggedPortion: [loggedPortion],
    );

    // When
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MealWidget(
              meal: meal,
              onFoodDeleted: (_) => deleteCalled = true,
            ),
          ),
        ),
      ),
    );

    // Act
    await tester.drag(
      find.byType(SlidablePortionWidget),
      const Offset(-500.0, 0.0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Then
    expect(deleteCalled, isTrue);
  });
}
