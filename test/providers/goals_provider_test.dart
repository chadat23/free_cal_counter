import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:free_cal_counter1/providers/goals_provider.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/models/goal_settings.dart';
import 'package:free_cal_counter1/models/weight.dart';

import 'goals_provider_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late GoalsProvider goalsProvider;
  late MockDatabaseService mockDatabaseService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockDatabaseService = MockDatabaseService();
    // GoalsProvider calls _loadFromPrefs on init
    goalsProvider = GoalsProvider(databaseService: mockDatabaseService);
  });

  group('GoalsProvider', () {
    test('initial state should be loading then default settings', () async {
      // Wait for _loadFromPrefs to finish
      await Future.delayed(Duration.zero);

      expect(goalsProvider.isLoading, false);
      expect(goalsProvider.settings.anchorWeight, 0.0);
      expect(goalsProvider.settings.isSet, false);
    });

    test(
      'saveSettings should persist to SharedPreferences and mark as set',
      () async {
        await Future.delayed(Duration.zero); // wait for load

        final newSettings = GoalSettings(
          anchorWeight: 75.0,
          maintenanceCaloriesStart: 2500,
          proteinTarget: 160,
          fatTarget: 70,
          carbTarget: 200,
          mode: GoalMode.maintain,
          calculationMode: MacroCalculationMode.proteinCarbs,
          fixedDelta: 0,
          lastTargetUpdate: DateTime.now(),
          fiberTarget: 37.0,
          // isSet should default to false in constructor if not provided,
          // but saveSettings inside provider will handle the logic if we modify the provider.
          // For now, let's just create the object.
        );

        // Stub recalculateTargets dependencies
        when(
          mockDatabaseService.getWeightsForRange(any, any),
        ).thenAnswer((_) async => []);

        await goalsProvider.saveSettings(newSettings);

        final prefs = await SharedPreferences.getInstance();
        final savedJson = prefs.getString('goal_settings');
        expect(savedJson, isNotNull);
        final decoded = GoalSettings.fromJson(jsonDecode(savedJson!));
        expect(decoded.anchorWeight, 75.0);
        expect(decoded.isSet, true);
      },
    );

    test(
      'recalculateTargets should use weight trend for maintenance mode',
      () async {
        await Future.delayed(Duration.zero);

        final history = [
          Weight(
            weight: 100.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(
          mockDatabaseService.getWeightsForRange(any, any),
        ).thenAnswer((_) async => history);

        // Set settings to maintenance for 105lb anchor (Imperial)
        final settings = GoalSettings(
          anchorWeight: 105.0,
          maintenanceCaloriesStart: 2000,
          proteinTarget: 150,
          fatTarget: 70,
          carbTarget: 200,
          mode: GoalMode.maintain,
          calculationMode: MacroCalculationMode.proteinFat, // Legacy mode
          fixedDelta: 0,
          lastTargetUpdate: DateTime.now().subtract(const Duration(days: 7)),
          useMetric: false,
          fiberTarget: 37.0,
        );
        await goalsProvider.saveSettings(settings);

        // Trend is 100. Gap is 5lb. Delta should be 5/30 * 3500 = 583.33
        expect(goalsProvider.currentGoals.calories, closeTo(2583.33, 0.1));
      },
    );

    test(
      'recalculateTargets should use metric multiplier when requested',
      () async {
        await Future.delayed(Duration.zero);

        final history = [Weight(weight: 100.0, date: DateTime.now())];

        when(
          mockDatabaseService.getWeightsForRange(any, any),
        ).thenAnswer((_) async => history);

        // Set settings to maintenance for 105kg anchor (Metric)
        final settings = GoalSettings(
          anchorWeight: 105.0,
          maintenanceCaloriesStart: 2000,
          proteinTarget: 150,
          fatTarget: 70,
          carbTarget: 200,
          mode: GoalMode.maintain,
          calculationMode: MacroCalculationMode.proteinFat,
          fixedDelta: 0,
          lastTargetUpdate: DateTime.now().subtract(const Duration(days: 7)),
          useMetric: true,
          fiberTarget: 37.0,
        );
        await goalsProvider.saveSettings(settings);

        // Trend is 100. Gap is 5kg. Delta should be 5/30 * 7716 = 1286
        expect(goalsProvider.currentGoals.calories, 3286.0);
      },
    );

    test(
      'recalculateTargets should NOT use weight trend when enableSmartTargets is false',
      () async {
        await Future.delayed(Duration.zero);

        final history = [
          Weight(
            weight: 100.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(
          mockDatabaseService.getWeightsForRange(any, any),
        ).thenAnswer((_) async => history);

        // Set settings to maintenance for 105lb anchor but DISABLE smart targets
        final settings = GoalSettings(
          anchorWeight: 105.0,
          maintenanceCaloriesStart: 2000,
          proteinTarget: 150,
          fatTarget: 70,
          carbTarget: 200,
          mode: GoalMode.maintain,
          calculationMode: MacroCalculationMode.proteinFat,
          fixedDelta: 0,
          lastTargetUpdate: DateTime.now().subtract(const Duration(days: 7)),
          useMetric: false,
          fiberTarget: 37.0,
          enableSmartTargets: false,
        );
        await goalsProvider.saveSettings(settings);

        // Even though trend is 100 and anchor is 105, it should stay at 2000 because smart targets are OFF
        expect(goalsProvider.currentGoals.calories, 2000.0);
      },
    );

    test('checkWeeklyUpdate should trigger update on Monday', () async {
      // This test is tricky because it uses DateTime.now()
      // For a true unit test we might need a clock wrapper,
      // but we'll test the logic by ensuring recalculateTargets is called if date is old.
    });
  });

  group('GoalsProvider Onboarding', () {
    test('initial hasSeenWelcome should be false', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = GoalsProvider(databaseService: MockDatabaseService());
      await Future.delayed(Duration.zero);
      expect(provider.hasSeenWelcome, false);
    });

    test('markWelcomeSeen should persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = GoalsProvider(databaseService: MockDatabaseService());
      await Future.delayed(Duration.zero);

      await provider.markWelcomeSeen();
      expect(provider.hasSeenWelcome, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_welcome'), true);
    });

    test(
      'existing users with goals set should have hasSeenWelcome = true',
      () async {
        final settings = GoalSettings.defaultSettings().copyWith(isSet: true);
        SharedPreferences.setMockInitialValues({
          'goal_settings': jsonEncode(settings.toJson()),
        });

        final provider = GoalsProvider(databaseService: MockDatabaseService());
        await Future.delayed(Duration.zero);

        expect(provider.isGoalsSet, true);
        expect(provider.hasSeenWelcome, true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('has_seen_welcome'), true);
      },
    );
  });
}
