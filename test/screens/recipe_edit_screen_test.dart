import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/screens/recipe_edit_screen.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:meal_of_record/services/database_service.dart';

import 'package:meal_of_record/services/live_database.dart' as live_db;
import 'package:meal_of_record/services/reference_database.dart' as ref_db;
import 'package:drift/native.dart';

@GenerateMocks([DatabaseService])
void main() {
  setUpAll(() {
    final liveDb = live_db.LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ref_db.ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  testWidgets(
    'RecipeEditScreen should show portion unit name field and dual macro rows',
    (tester) async {
      final provider = RecipeProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RecipeProvider>.value(
            value: provider,
            child: const RecipeEditScreen(),
          ),
        ),
      );

      // Verify fields exist
      expect(find.text('Portions Count'), findsOneWidget);
      expect(find.text('Portion Unit Name'), findsOneWidget);
      expect(find.text('Total Recipe Macros'), findsOneWidget);
      expect(find.text('Macros per portion'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);

      // Enter portion unit name
      await tester.enterText(
        find.widgetWithText(TextField, 'Portion Unit Name'),
        'Muffin',
      );
      expect(provider.portionName, 'Muffin');

      await tester.pump();
      expect(find.text('Macros per Muffin'), findsOneWidget);
    },
  );
}
