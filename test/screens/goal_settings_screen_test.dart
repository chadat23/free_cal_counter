import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/screens/goal_settings_screen.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/providers/weight_provider.dart';

import 'package:meal_of_record/providers/navigation_provider.dart';

import 'goal_settings_screen_test.mocks.dart';

@GenerateMocks([GoalsProvider, WeightProvider, NavigationProvider])
void main() {
  late MockGoalsProvider mockGoalsProvider;
  late MockWeightProvider mockWeightProvider;
  late MockNavigationProvider mockNavigationProvider;

  setUp(() {
    mockGoalsProvider = MockGoalsProvider();
    mockWeightProvider = MockWeightProvider();
    mockNavigationProvider = MockNavigationProvider();

    // Stub the settings getter
    when(mockGoalsProvider.settings).thenReturn(GoalSettings.defaultSettings());
    when(mockGoalsProvider.isGoalsSet).thenReturn(false);

    // Stub weight provider
    when(mockWeightProvider.getWeightForDate(any)).thenReturn(null);
    when(mockWeightProvider.saveWeight(any, any)).thenAnswer((_) async {});
  });

  testWidgets('GoalSettingsScreen renders all fields and toggles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<WeightProvider>.value(
            value: mockWeightProvider,
          ),
        ],
        child: const MaterialApp(home: GoalSettingsScreen()),
      ),
    );

    expect(find.text('Goals & Targets'), findsOneWidget);
    expect(find.text('Goal Mode'), findsOneWidget);
    expect(
      find.text('Target Weight (lb)'),
      findsOneWidget,
    ); // Default is Imperial
    expect(find.text('Use Metric Units (kg)'), findsOneWidget);

    // Scroll to see the save button
    final saveButton = find.text('Save Settings');
    await tester.scrollUntilVisible(
      saveButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Check for save button
    expect(saveButton, findsOneWidget);
  });

  testWidgets('Toggling metric updates the target weight label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<WeightProvider>.value(
            value: mockWeightProvider,
          ),
        ],
        child: const MaterialApp(home: GoalSettingsScreen()),
      ),
    );

    expect(find.text('Target Weight (lb)'), findsOneWidget);

    // Tap the metric switch
    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Use Metric Units (kg)'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Target Weight (kg)'), findsOneWidget);
  });

  testWidgets('Saving settings saves settings', (tester) async {
    when(
      mockGoalsProvider.saveSettings(
        any,
        isInitialSetup: anyNamed('isInitialSetup'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<NavigationProvider>.value(
            value: mockNavigationProvider,
          ),
          ChangeNotifierProvider<WeightProvider>.value(
            value: mockWeightProvider,
          ),
        ],
        child: const MaterialApp(home: GoalSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Helper to fill a field by label
    Future<void> fillField(String label, String value) async {
      final finder = find.widgetWithText(TextField, label);
      await tester.scrollUntilVisible(
        finder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(finder, value);
      await tester.pump();
    }

    await fillField('Target Weight (lb)', '155.5');
    await fillField('Initial Maintenance Calories', '2340');
    await fillField('Protein Target (g)', '150');
    await fillField('Carbs (g)', '200');
    await fillField('Fiber (g)', '38');

    // Scroll to save
    final saveButton = find.text('Save Settings');
    await tester.scrollUntilVisible(
      saveButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(
      mockGoalsProvider.saveSettings(
        any,
        isInitialSetup: anyNamed('isInitialSetup'),
      ),
    ).called(1);
    verify(mockNavigationProvider.changeTab(0)).called(1);
  });

  testWidgets(
    'Estimated protein target is NOT displayed when using Multiplier mode',
    (tester) async {
      // Select Multiplier mode
      final settings = GoalSettings.defaultSettings().copyWith(
      proteinTargetMode: ProteinTargetMode.percentageOfWeight,
      proteinMultiplier: 1.0,
      anchorWeight: 155.5,
    );
    when(mockGoalsProvider.settings).thenReturn(settings);
    when(mockWeightProvider.recentWeights).thenReturn([]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
          ChangeNotifierProvider<WeightProvider>.value(
            value: mockWeightProvider,
          ),
        ],
        child: const MaterialApp(home: GoalSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Estimated Target:" is NOT present
    expect(find.textContaining('Estimated Target:'), findsNothing);
  });
}
