import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/widgets/slidable_portion_widget.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'slidable_portion_widget_test.mocks.dart';

@GenerateMocks([GoalsProvider])
void main() {
  late MockGoalsProvider mockGoalsProvider;

  setUp(() {
    mockGoalsProvider = MockGoalsProvider();
    when(mockGoalsProvider.useNetCarbs).thenReturn(false);
  });

  testWidgets(
    'SlidableServingWidget slides to reveal delete button and deletes on tap',
    (WidgetTester tester) async {
      // Given
      bool onDeleteCalled = false;
      final food = Food(
        id: 1,
        name: 'Apple',
        emoji: '🍎',
        calories: 52,
        protein: 0.3,
        fat: 0.2,
        carbs: 14,
        fiber: 2.4,
        source: 'test',
        servings: [
          FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
        ],
      );
      final serving = FoodPortion(food: food, grams: 100, unit: 'g');

      await tester.pumpWidget(
        ChangeNotifierProvider<GoalsProvider>.value(
          value: mockGoalsProvider,
          child: MaterialApp(
            home: Scaffold(
              body: SlidablePortionWidget(
                serving: serving,
                onDelete: () {
                  onDeleteCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // When - Slide to reveal
      await tester.fling(
        find.byType(SlidablePortionWidget),
        const Offset(-200, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Then
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // When - Tap delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Then
      expect(onDeleteCalled, isTrue);
    },
  );

  testWidgets('SlidableServingWidget calls onEdit when edit button is tapped', (
    WidgetTester tester,
  ) async {
    // Given
    bool onEditCalled = false;
    final food = Food(
      id: 1,
      name: 'Apple',
      emoji: '🍎',
      calories: 52,
      protein: 0.3,
      fat: 0.2,
      carbs: 14,
      fiber: 2.4,
      source: 'test',
      servings: [FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0)],
    );
    final serving = FoodPortion(food: food, grams: 100, unit: 'g');

    await tester.pumpWidget(
      ChangeNotifierProvider<GoalsProvider>.value(
        value: mockGoalsProvider,
        child: MaterialApp(
          home: Scaffold(
            body: SlidablePortionWidget(
              serving: serving,
              onDelete: () {},
              onEdit: () {
                onEditCalled = true;
              },
            ),
          ),
        ),
      ),
    );

    // When - Tap edit button (it's visible without sliding)
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Then
    expect(onEditCalled, isTrue);
  });
}
