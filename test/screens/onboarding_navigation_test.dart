import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/screens/goal_settings_screen.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/providers/weight_provider.dart';

import 'onboarding_navigation_test.mocks.dart';

import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/screens/navigation_container_screen.dart';

@GenerateMocks([GoalsProvider, NavigationProvider, WeightProvider, LogProvider])
void main() {
  late MockGoalsProvider mockGoalsProvider;
  late MockNavigationProvider mockNavigationProvider;
  late MockWeightProvider mockWeightProvider;
  late MockLogProvider mockLogProvider;

  setUp(() {
    mockGoalsProvider = MockGoalsProvider();
    mockNavigationProvider = MockNavigationProvider();
    mockWeightProvider = MockWeightProvider();
    mockLogProvider = MockLogProvider();

    when(mockGoalsProvider.settings).thenReturn(GoalSettings.defaultSettings());
    when(mockGoalsProvider.isGoalsSet).thenReturn(false);
    when(mockGoalsProvider.hasSeenWelcome).thenReturn(false);
    when(mockGoalsProvider.isLoading).thenReturn(false);
    when(
      mockGoalsProvider.saveSettings(
        any,
        isInitialSetup: anyNamed('isInitialSetup'),
      ),
    ).thenAnswer((_) async {});
    when(mockWeightProvider.getWeightForDate(any)).thenReturn(null);
    when(mockWeightProvider.weights).thenReturn([]);
    when(mockWeightProvider.loadWeights(any, any)).thenAnswer((_) async {});

    when(
      mockLogProvider.getDailyMacroStats(any, any),
    ).thenAnswer((_) async => []);
  });

  testWidgets('Saving initial goals should return to Overview screen (tab 0)', (
    tester,
  ) async {
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
          ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
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

    await fillField('Target Weight (lb)', '150');
    await fillField('Initial Maintenance Calories', '2340');
    await fillField('Protein (g)', '150');
    await fillField('Carbs (g)', '200');
    await fillField('Fiber (g)', '38');

    // Scroll to save button
    final saveButton = find.text('Save Settings');
    await tester.scrollUntilVisible(
      saveButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify it navigates to tab 0 (Overview), not tab 1 (Log)
    verify(mockNavigationProvider.changeTab(0)).called(1);
    verifyNever(mockNavigationProvider.changeTab(1));
  });

  testWidgets(
    'Welcome dialog should only show if goals not set AND welcome not seen',
    (tester) async {
      // Stage 1: Goals NOT set, Welcome NOT seen
      when(mockGoalsProvider.isGoalsSet).thenReturn(false);
      when(mockGoalsProvider.hasSeenWelcome).thenReturn(false);
      when(mockNavigationProvider.selectedIndex).thenReturn(0);
      when(mockGoalsProvider.showUpdateNotification).thenReturn(false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GoalsProvider>.value(
              value: mockGoalsProvider,
            ),
            ChangeNotifierProvider<NavigationProvider>.value(
              value: mockNavigationProvider,
            ),
            ChangeNotifierProvider<WeightProvider>.value(
              value: mockWeightProvider,
            ),
            ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
          ],
          child: MaterialApp(
            home: const NavigationContainerScreen(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) =>
                    Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
          ),
        ),
      );
      await tester.pump(); // Trigger post-frame callback

      // Should show welcome dialog
      expect(find.text('Welcome!'), findsOneWidget);
      verify(mockGoalsProvider.markWelcomeSeen()).called(1);

      // Stage 2: Re-pump with Welcome ALREADY seen (simulating next app open)
      when(mockGoalsProvider.hasSeenWelcome).thenReturn(true);

      // Close dialog
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Re-build navigation screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GoalsProvider>.value(
              value: mockGoalsProvider,
            ),
            ChangeNotifierProvider<NavigationProvider>.value(
              value: mockNavigationProvider,
            ),
            ChangeNotifierProvider<WeightProvider>.value(
              value: mockWeightProvider,
            ),
            ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
          ],
          child: MaterialApp(
            home: const NavigationContainerScreen(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) =>
                    Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Should NOT show welcome dialog again
      expect(find.text('Welcome!'), findsNothing);
    },
  );
}
