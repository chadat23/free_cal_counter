import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/nutrition_target.dart';
import 'package:meal_of_record/widgets/log_header.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meal_of_record/providers/log_provider.dart';
import 'log_header_test.mocks.dart';

@GenerateMocks([NavigationProvider, LogProvider])
void main() {
  testWidgets('LogHeader displays date and navigates', (
    WidgetTester tester,
  ) async {
    DateTime selectedDate = DateTime.now();
    final List<NutritionTarget> nutritionTargets = [
      NutritionTarget(
        color: Colors.blue,
        thisAmount: 1500,
        targetAmount: 2000,
        macroLabel: '🔥',
        unitLabel: '',
        dailyAmounts: [],
      ),
      NutritionTarget(
        color: Colors.red,
        thisAmount: 100,
        targetAmount: 150,
        macroLabel: 'P',
        unitLabel: 'g',
        dailyAmounts: [],
      ),
      NutritionTarget(
        color: Colors.orange,
        thisAmount: 50,
        targetAmount: 70,
        macroLabel: 'F',
        unitLabel: 'g',
        dailyAmounts: [],
      ),
      NutritionTarget(
        color: Colors.green,
        thisAmount: 200,
        targetAmount: 250,
        macroLabel: 'C',
        unitLabel: 'g',
        dailyAmounts: [],
      ),
    ];

    final mockNavProvider = MockNavigationProvider();
    when(mockNavProvider.showConsumed).thenReturn(true);
    final mockLogProvider = MockLogProvider();
    when(mockLogProvider.isFasted).thenReturn(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NavigationProvider>.value(
            value: mockNavProvider,
          ),
          ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LogHeader(
              date: selectedDate,
              onDateChanged: (newDate) {
                selectedDate = newDate;
              },
              nutritionTargets: nutritionTargets,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(3));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    // expect(find.text('Yesterday'), findsOneWidget); // This will be checked in the stateful widget test

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    // expect(find.text('Tomorrow'), findsOneWidget);
  });
}
