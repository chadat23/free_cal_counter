import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/screens/food_edit_screen.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/live_database.dart';
import 'package:free_cal_counter1/services/reference_database.dart';
import 'package:free_cal_counter1/models/food_serving.dart';
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

    expect(find.text('Servings / Units'), findsOneWidget);
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

    // Switch to "Per Serving" - It uses a DropdownButton<bool>
    // Initially shows '100g' (value false)
    await tester.tap(find.text('100g'));
    await tester.pumpAndSettle();

    // Tap 'Serving' in the dropdown menu
    await tester.tap(find.text('Serving').last);
    await tester.pumpAndSettle();

    // Scroll down to find add button
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // The default serving is 100g (1 serving = 100g).
    // Let's add a custom serving to test non-100g math.
    // Now it should be visible/built
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    // Add "Slice" = 30g
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unit Name (e.g. cup, slice)'),
      'Slice',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight for Quantity (g)'),
      '30',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Scroll back up to see macro dropdown
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    // Select "Slice" in macro dropdown
    final dropdownFinder = find.byType(DropdownButtonFormField<FoodServing>);
    await tester.ensureVisible(
      dropdownFinder,
    ); // ensureVisible also scrolls if possible

    // Tap to open
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Select Slice
    await tester.tap(find.textContaining('Slice').last);
    await tester.pumpAndSettle();

    // Enter 100 calories per Slice (30g)
    // So per gram: 100 / 30 = 3.333
    Finder findMacroField(String label) {
      return find.descendant(
        of: find.widgetWithText(Row, label),
        matching: find.byType(TextFormField),
      );
    }

    await tester.ensureVisible(findMacroField('Calories'));
    await tester.enterText(findMacroField('Calories'), '100');

    // Fill metadata
    await tester.drag(find.byType(ListView), const Offset(0, 500)); // Scroll up
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
