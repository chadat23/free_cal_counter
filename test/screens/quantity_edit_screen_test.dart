import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'quantity_edit_screen_test.mocks.dart';

@GenerateMocks([LogProvider, RecipeProvider, GoalsProvider])
void main() {
  late MockLogProvider mockLogProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockGoalsProvider mockGoalsProvider;

  final mockFood = Food(
    id: 1,
    source: 'USDA',
    name: 'Apple',
    calories: 0.52,
    protein: 0.003,
    fat: 0.002,
    carbs: 0.14,
    fiber: 0.024,
    servings: [
      FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0),
      FoodServing(foodId: 1, unit: 'piece', grams: 182.0, quantity: 1.0),
    ],
  );

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockGoalsProvider = MockGoalsProvider();

    // Default mock behavior for LogProvider
    when(mockLogProvider.totalCalories).thenReturn(500.0);
    when(mockLogProvider.totalProtein).thenReturn(20.0);
    when(mockLogProvider.totalFat).thenReturn(10.0);
    when(mockLogProvider.totalCarbs).thenReturn(80.0);
    when(mockLogProvider.totalFiber).thenReturn(5.0);
    when(mockLogProvider.dailyTargetCalories).thenReturn(2000.0);
    when(mockLogProvider.dailyTargetProtein).thenReturn(150.0);
    when(mockLogProvider.dailyTargetFat).thenReturn(70.0);
    when(mockLogProvider.dailyTargetCarbs).thenReturn(250.0);
    when(mockLogProvider.dailyTargetFiber).thenReturn(30.0);

    // Default mock behavior for RecipeProvider
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);
    when(mockRecipeProvider.servingsCreated).thenReturn(1.0);

    // Default mock behavior for GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals.hardcoded());
  });

  Widget createTestWidget(QuantityEditConfig config) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<RecipeProvider>.value(value: mockRecipeProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
      ],
      child: MaterialApp(home: QuantityEditScreen(config: config)),
    );
  }

  testWidgets('Auto-focuses and selects quantity when isUpdate is true', (
    tester,
  ) async {
    final config = QuantityEditConfig(
      context: QuantityEditContext.day,
      food: mockFood,
      initialUnit: 'piece',
      initialQuantity: 1.5,
      isUpdate: true,
      onSave: (grams, unit, updatedFood) {},
    );

    await tester.pumpWidget(createTestWidget(config));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.focusNode!.hasFocus, true);
    expect(textField.controller!.selection.baseOffset, 0);
    expect(
      textField.controller!.selection.extentOffset,
      textField.controller!.text.length,
    );
  });

  testWidgets('Does not auto-focus quantity when isUpdate is false', (
    tester,
  ) async {
    final config = QuantityEditConfig(
      context: QuantityEditContext.day,
      food: mockFood,
      initialUnit: 'piece',
      initialQuantity: 1.5,
      isUpdate: false,
      onSave: (grams, unit, updatedFood) {},
    );

    await tester.pumpWidget(createTestWidget(config));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.focusNode!.hasFocus, false);
  });

  testWidgets('Pre-populates amount and unit from config', (tester) async {
    final config = QuantityEditConfig(
      context: QuantityEditContext.day,
      food: mockFood,
      initialUnit: 'piece',
      initialQuantity: 1.5,
      onSave: (grams, unit, updatedFood) {},
    );

    await tester.pumpWidget(createTestWidget(config));

    expect(find.text('1.5'), findsOneWidget);

    final pieceChip = tester.widget<ChoiceChip>(
      find.descendant(
        of: find.byType(Wrap),
        matching: find.widgetWithText(ChoiceChip, 'piece'),
      ),
    );
    expect(pieceChip.selected, true);
  });

  testWidgets('Interactive switching: Selecting macro switches unit to g', (
    tester,
  ) async {
    final config = QuantityEditConfig(
      context: QuantityEditContext.day,
      food: mockFood,
      initialUnit: 'piece',
      initialQuantity: 1.0,
      onSave: (grams, unit, updatedFood) {},
    );

    await tester.pumpWidget(createTestWidget(config));

    // Initially piece is selected
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'piece'))
          .selected,
      true,
    );

    // Click 'Calories' target (ensure it's visible first)
    await tester.ensureVisible(find.text('Calories'));
    await tester.tap(find.text('Calories'));
    await tester.pumpAndSettle();

    // Unit should switch to 'g'
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'g')).selected,
      true,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'piece'))
          .selected,
      false,
    );
  });

  testWidgets(
    'Interactive switching: Selecting unit switches target back to Unit',
    (tester) async {
      final config = QuantityEditConfig(
        context: QuantityEditContext.day,
        food: mockFood,
        initialUnit: 'g',
        initialQuantity: 100.0,
        onSave: (grams, unit, updatedFood) {},
      );

      await tester.pumpWidget(createTestWidget(config));

      // Select 'Calories' target (ensure it's visible first)
      await tester.ensureVisible(find.text('Calories'));
      await tester.tap(find.text('Calories'));
      await tester.pumpAndSettle();

      // Now tap 'piece' unit button
      await tester.tap(find.text('piece'));
      await tester.pumpAndSettle();

      // Target should be back to 'Unit' (index 0)
      final toggleButtons = tester.widget<ToggleButtons>(
        find.byType(ToggleButtons),
      );
      expect(toggleButtons.isSelected[0], true);
      expect(toggleButtons.isSelected[1], false);
    },
  );

  testWidgets('Saves correct grams and unit', (tester) async {
    double savedGrams = 0;
    String savedUnit = '';

    final config = QuantityEditConfig(
      context: QuantityEditContext.day,
      food: mockFood,
      initialUnit: 'piece',
      initialQuantity: 1.0,
      onSave: (grams, unit, updatedFood) {
        savedGrams = grams;
        savedUnit = unit;
      },
    );

    await tester.pumpWidget(createTestWidget(config));

    // Change quantity to 2.0
    await tester.enterText(find.byType(TextField), '2.0');
    // Ensure button is visible (it's in a scrollable view and might be off-screen)
    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(savedGrams, 364.0); // 2 * 182
    expect(savedUnit, 'piece');
  });
}
