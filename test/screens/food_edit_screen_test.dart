import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/screens/food_edit_screen.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/live_database.dart';
import 'package:free_cal_counter1/services/reference_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LiveDatabase liveDb;
  late ReferenceDatabase refDb;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    liveDb = LiveDatabase(connection: NativeDatabase.memory());
    refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  tearDown(() async {
    await liveDb.close();
    await refDb.close();
  });

  testWidgets('renders create food form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoodEditScreen()));

    expect(find.text('Create Food'), findsOneWidget);
    expect(find.text('Food Name'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);

    // Scroll down to see bottom elements
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Additional Servings'), findsOneWidget);
  });

  testWidgets('validates required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoodEditScreen()));

    // Tap save without entering name
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('saves new food correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoodEditScreen()));

    // New foods default to per-serving mode, switch to 100g mode for this test
    await tester.tap(find.text('Serving'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('100g').last);
    await tester.pumpAndSettle();

    // Enter details
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Food Name'),
      'Test Banana',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes (Optional)'),
      'Yummy',
    );

    Finder findMacroField(String label) {
      return find.descendant(
        of: find.widgetWithText(Row, label),
        matching: find.byType(TextFormField),
      );
    }

    await tester.enterText(findMacroField('Calories'), '89');
    await tester.enterText(findMacroField('Protein'), '1.1');
    await tester.enterText(findMacroField('Fat'), '0.3');
    await tester.enterText(findMacroField('Carbs'), '22.8');
    await tester.enterText(findMacroField('Fiber'), '2.6');

    // Tap save
    await tester.ensureVisible(find.byIcon(Icons.check));
    await tester.tap(find.byIcon(Icons.check));

    // Wait for async save
    await tester.pumpAndSettle();

    // Verify it popped
    expect(find.byType(FoodEditScreen), findsNothing);

    // Verify DB
    final savedFood = await liveDb.select(liveDb.foods).getSingle();
    expect(savedFood.name, 'Test Banana');
    expect(savedFood.usageNote, 'Yummy');
    expect(savedFood.caloriesPerGram, closeTo(0.89, 0.001));
  });

  testWidgets('calculates per serving correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoodEditScreen()));

    // New foods now default to per-serving mode
    // The primary serving section should be visible with Qty, Unit, and Grams fields

    // Fill in the primary serving: 1 Slice = 30g
    // First, select a unit - tap on the unit dropdown
    await tester.tap(find.text('serving'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom...').last);
    await tester.pumpAndSettle();

    // Enter custom unit name
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unit name'),
      'Slice',
    );

    // Enter grams for the serving
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Grams'),
      '30',
    );

    // Enter 100 calories per Slice (30g)
    // So per gram: 100 / 30 = 3.333
    Finder findMacroField(String label) {
      return find.descendant(
        of: find.widgetWithText(Row, label),
        matching: find.byType(TextFormField),
      );
    }

    await tester.enterText(findMacroField('Calories'), '100');

    // Fill metadata - scroll up to find Food Name
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Food Name'),
      'Test Bread',
    );

    // Save
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    // Verify DB
    final savedFood = await liveDb.select(liveDb.foods).getSingle();
    expect(savedFood.name, 'Test Bread');
    expect(savedFood.caloriesPerGram, closeTo(3.333, 0.001));
  });
}
