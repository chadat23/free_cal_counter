import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/widgets/unit_select_field.dart';

void main() {
  testWidgets('UnitSelectField shows dropdown and updates value', (tester) async {
    String selectedValue = 'serving';
    final availableUnits = ['cup', 'bowl'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return UnitSelectField(
                label: 'Unit',
                value: selectedValue,
                availableUnits: availableUnits,
                onChanged: (val) {
                  setState(() {
                    selectedValue = val;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: dropdown showing 'serving'
    expect(find.text('serving'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Open dropdown
    await tester.tap(find.text('serving'));
    await tester.pumpAndSettle();

    // Select 'cup'
    await tester.tap(find.text('cup').last);
    await tester.pumpAndSettle();

    expect(selectedValue, 'cup');
  });

  testWidgets('UnitSelectField toggles to custom and back', (tester) async {
    String selectedValue = 'serving';
    final availableUnits = ['cup'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return UnitSelectField(
                label: 'Unit',
                value: selectedValue,
                availableUnits: availableUnits,
                onChanged: (val) {
                  setState(() {
                    selectedValue = val;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Open dropdown and select 'Custom...'
    await tester.tap(find.text('serving'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom...'));
    await tester.pumpAndSettle();

    // Should now show a text field
    expect(find.byType(TextField), findsOneWidget);

    // Type a custom unit
    await tester.enterText(find.byType(TextField), 'box');
    expect(selectedValue, 'box');

    // Click close icon
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Should be back to dropdown with 'serving'
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(selectedValue, 'serving');
    expect(find.text('serving'), findsOneWidget);
  });

  testWidgets('UnitSelectField starts in custom mode if value not in list', (tester) async {
    String selectedValue = 'bag';
    final availableUnits = ['cup', 'bowl'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnitSelectField(
            label: 'Unit',
            value: selectedValue,
            availableUnits: availableUnits,
            onChanged: (val) => selectedValue = val,
          ),
        ),
      ),
    );

    // Should start with text field containing 'bag'
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('bag'), findsOneWidget);
  });
}
