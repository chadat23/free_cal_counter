import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/widgets/search/slidable_recipe_search_result.dart';
import 'package:meal_of_record/widgets/search/slidable_search_result.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:drift/native.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart' as live_db;
import 'package:meal_of_record/services/reference_database.dart' as ref_db;

void main() {
  setUpAll(() async {
    final liveDb = live_db.LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ref_db.ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });
  final testFood = Food(
    id: 1,
    name: 'Apple',
    calories: 0.52,
    protein: 0.003,
    fat: 0.002,
    carbs: 0.14,
    fiber: 0.024,
    source: 'recipe',
    servings: [FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0)],
  );

  group('SlidableRecipeSearchResult Alignment', () {
    testWidgets('reveals Edit, Copy, Dump when sliding to the right', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableRecipeSearchResult(
              food: testFood,
              onTap: (_) {},
              onEdit: () {},
              onCopy: () {},
              onDelete: () {},
              onDecompose: () {},
            ),
          ),
        ),
      );

      // Slide to the right (positive Offset) to reveal startActionPane
      await tester.drag(
        find.byType(SlidableRecipeSearchResult),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Dump'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('reveals Delete when sliding to the left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableRecipeSearchResult(
              food: testFood,
              onTap: (_) {},
              onEdit: () {},
              onCopy: () {},
              onDelete: () {},
              onDecompose: () {},
            ),
          ),
        ),
      );

      // Slide to the left (negative Offset) to reveal endActionPane
      await tester.drag(
        find.byType(SlidableRecipeSearchResult),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });
  });

  group('SlidableSearchResult Alignment', () {
    final foodItem = testFood.copyWith(source: 'logged_foods');

    testWidgets('reveals Edit, Copy when sliding to the right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableSearchResult(
              food: foodItem,
              onTap: (_) {},
              onEdit: () {},
              onCopy: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.drag(
        find.byType(SlidableSearchResult),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('reveals Delete when sliding to the left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableSearchResult(
              food: foodItem,
              onTap: (_) {},
              onEdit: () {},
              onCopy: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.drag(
        find.byType(SlidableSearchResult),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });
  });
}
