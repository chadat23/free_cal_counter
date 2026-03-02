import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/screens/weight_screen.dart';
import 'package:meal_of_record/providers/weight_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'weight_screen_test.mocks.dart';

@GenerateMocks([WeightProvider, GoalsProvider, NavigationProvider])
void main() {
  late MockWeightProvider mockWeightProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockNavigationProvider mockNavigationProvider;

  setUp(() {
    mockWeightProvider = MockWeightProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockNavigationProvider = MockNavigationProvider();

    when(mockWeightProvider.getWeightForDate(any)).thenReturn(null);
    when(mockWeightProvider.saveWeight(any, any)).thenAnswer((_) async => {});
    when(mockWeightProvider.loadWeights(any, any)).thenAnswer((_) async => {});

    when(mockGoalsProvider.settings).thenReturn(GoalSettings.defaultSettings());
    when(mockGoalsProvider.targetFor(any)).thenReturn(MacroGoals.hardcoded());
    when(mockNavigationProvider.changeTab(any)).thenReturn(null);
  });

  testWidgets('WeightScreen UI and interaction test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WeightProvider>.value(
            value: mockWeightProvider,
          ),
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<NavigationProvider>.value(
            value: mockNavigationProvider,
          ),
        ],
        child: const MaterialApp(home: WeightScreen()),
      ),
    );

    // Verify that the WeightScreen is rendered.
    expect(find.byType(WeightScreen), findsOneWidget);

    // Verify that the TextField is present.
    expect(find.byType(TextField), findsOneWidget);

    // Enter text into the TextField.
    await tester.enterText(find.byType(TextField), '75.5');

    // Tap the Save button (it's inside an IconButton or similar in some versions, but let's check)
    // Actually in WeightScreen there's an ElevatedButton to save.
    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start animation/dialog
    await tester.pump(
      const Duration(milliseconds: 1100),
    ); // Wait for dialog timer
    await tester.pumpAndSettle();

    // Verify that saveWeight was called
    verify(mockWeightProvider.saveWeight(75.5, any)).called(1);
  });
}
