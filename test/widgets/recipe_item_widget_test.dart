import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/models/food.dart';
import 'package:free_cal_counter1/models/recipe_item.dart';
import 'package:free_cal_counter1/widgets/recipe_item_widget.dart';
import 'package:free_cal_counter1/widgets/food_image_widget.dart';

void main() {
  final mockFoodWithEmoji = Food(
    id: 1,
    name: 'Apple',
    source: 'USDA',
    emoji: '🍎',
    calories: 0.52,
    protein: 0.003,
    fat: 0.002,
    carbs: 0.14,
    fiber: 0.024,
  );

  final mockFoodWithoutEmoji = Food(
    id: 2,
    name: 'Generic Food',
    source: 'USDA',
    calories: 1.0,
    protein: 0.1,
    fat: 0.1,
    carbs: 0.1,
    fiber: 0.01,
  );

  testWidgets('RecipeItemWidget displays emoji for food item', (tester) async {
    final item = RecipeItem(
      id: 1,
      food: mockFoodWithEmoji,
      grams: 100,
      unit: 'g',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecipeItemWidget(item: item)),
      ),
    );

    // Expecting to find FoodImageWidget which handles emojis
    expect(find.byType(FoodImageWidget), findsOneWidget);
    expect(find.text('🍎'), findsOneWidget);
    // Generic restaurant icon should NOT be there anymore (once fixed)
    // For now it might fail if we find Icon(Icons.restaurant_menu)
    expect(find.byIcon(Icons.restaurant_menu), findsNothing);
  });

  testWidgets(
    'RecipeItemWidget displays placeholder for food without emoji/image',
    (tester) async {
      final item = RecipeItem(
        id: 2,
        food: mockFoodWithoutEmoji,
        grams: 100,
        unit: 'g',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeItemWidget(item: item)),
        ),
      );

      expect(find.byType(FoodImageWidget), findsOneWidget);
      // FoodImageWidget internal placeholder is Icons.restaurant (not Icons.restaurant_menu)
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsNothing);
    },
  );
}
