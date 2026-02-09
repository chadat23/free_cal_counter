import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:free_cal_counter1/providers/goals_provider.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/models/goal_settings.dart';
import 'package:free_cal_counter1/models/weight.dart';
import 'package:free_cal_counter1/models/daily_macro_stats.dart';

import 'goals_provider_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockDatabaseService = MockDatabaseService();
  });

  /// Helper: creates a GoalsProvider with a fixed clock and waits for init.
  Future<GoalsProvider> createProvider({
    required DateTime now,
    GoalSettings? initialSettings,
  }) async {
    if (initialSettings != null) {
      SharedPreferences.setMockInitialValues({
        'goal_settings': jsonEncode(initialSettings.toJson()),
      });
    } else {
      SharedPreferences.setMockInitialValues({});
    }

    // Stub DB calls that happen during _loadFromPrefs -> checkWeeklyUpdate
    when(mockDatabaseService.getWeightsForRange(any, any))
        .thenAnswer((_) async => []);
    when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
        .thenAnswer((_) async => []);

    final provider = GoalsProvider(
      databaseService: mockDatabaseService,
      clock: () => now,
    );
    await Future.delayed(Duration.zero);
    return provider;
  }

  /// Helper: builds weight entries for N of the last 14 days.
  List<Weight> buildRecentWeights(DateTime now, int count,
      {double weight = 100.0}) {
    return List.generate(
      count,
      (i) => Weight(weight: weight, date: now.subtract(Duration(days: i))),
    );
  }

  group('GoalsProvider basic', () {
    test('initial state should be loading then default settings', () async {
      final provider = await createProvider(now: DateTime(2024, 1, 15));
      expect(provider.isLoading, false);
      expect(provider.settings.anchorWeight, 0.0);
      expect(provider.settings.isSet, false);
    });

    test('saveSettings should persist and mark as set', () async {
      final now = DateTime(2024, 1, 15); // Monday
      final provider = await createProvider(now: now);

      final newSettings = GoalSettings(
        anchorWeight: 75.0,
        maintenanceCaloriesStart: 2500,
        proteinTarget: 160,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: now,
        fiberTarget: 37.0,
      );

      await provider.saveSettings(newSettings);

      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('goal_settings');
      expect(savedJson, isNotNull);
      final decoded = GoalSettings.fromJson(jsonDecode(savedJson!));
      expect(decoded.anchorWeight, 75.0);
      expect(decoded.isSet, true);
    });
  });

  group('GoalsProvider cold boot', () {
    test('no weight data -> uses manual maintenance', () async {
      // Monday with old lastUpdate
      final now = DateTime(2024, 1, 15, 10); // Monday
      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 150.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1), // old
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Cold boot fallback: manual maintenance = 2000
      expect(provider.currentGoals.calories, 2000.0);
    });

    test('9 weight entries in 14 days -> still manual', () async {
      final now = DateTime(2024, 1, 15, 10); // Monday
      final weights = buildRecentWeights(now, 9);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2200,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Cold boot: only 9 weights, needs 10. Falls back to manual.
      expect(provider.currentGoals.calories, 2200.0);
    });
  });

  group('GoalsProvider warm start (Kalman)', () {
    /// Helper: sets up a provider with enough weight data for Kalman.
    Future<GoalsProvider> createWarmProvider({
      required DateTime now,
      required GoalSettings settings,
      int weightCount = 14,
      double weightValue = 100.0,
      List<LoggedMacroDTO>? dtos,
    }) async {
      final weights = buildRecentWeights(now, weightCount, weight: weightValue);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);
      when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
          .thenAnswer((_) async => dtos ?? []);

      return createProvider(now: now, initialSettings: settings);
    }

    GoalSettings baseSettings({
      GoalMode mode = GoalMode.maintain,
      double fixedDelta = 0,
      double maintenance = 2000,
    }) {
      return GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: maintenance,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: mode,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: fixedDelta,
        lastTargetUpdate: DateTime(2024, 1, 1), // old, forces recalc on Monday
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );
    }

    test('10+ weight entries with stable intake -> uses Kalman TDEE', () async {
      final now = DateTime(2024, 1, 15, 10); // Monday

      // Build DTOs for stable 2000 cal intake for 90 days
      final today = DateTime(now.year, now.month, now.day);
      final analysisStart = today.subtract(const Duration(days: 90));
      final dtos = <LoggedMacroDTO>[];
      var d = analysisStart;
      while (!d.isAfter(today)) {
        dtos.add(LoggedMacroDTO(
          logTimestamp: d,
          grams: 100.0,
          caloriesPerGram: 20.0, // 2000 cal total
          proteinPerGram: 1.5,
          fatPerGram: 0.7,
          carbsPerGram: 2.0,
          fiberPerGram: 0.38,
        ));
        d = d.add(const Duration(days: 1));
      }

      final provider = await createWarmProvider(
        now: now,
        settings: baseSettings(),
        weightCount: 14,
        weightValue: 100.0,
        dtos: dtos,
      );

      // Kalman with stable weight + 2000 cal intake -> TDEE near 2000
      expect(provider.currentGoals.calories, closeTo(2000.0, 100.0));
    });

    test('maintain mode: target = Kalman TDEE', () async {
      final now = DateTime(2024, 1, 15, 10);
      final provider = await createWarmProvider(
        now: now,
        settings: baseSettings(mode: GoalMode.maintain),
      );

      // With no logged intake DTOs, Kalman gets intakeIsValid=false everywhere,
      // so TDEE stays near initial (2000). Target = TDEE in maintain mode.
      expect(provider.currentGoals.calories, closeTo(2000.0, 100.0));
    });

    test('lose mode: target = Kalman TDEE - fixedDelta', () async {
      final now = DateTime(2024, 1, 15, 10);
      final provider = await createWarmProvider(
        now: now,
        settings: baseSettings(mode: GoalMode.lose, fixedDelta: 500),
      );

      // TDEE near 2000, lose mode subtracts 500
      expect(provider.currentGoals.calories, closeTo(1500.0, 100.0));
    });

    test('gain mode: target = Kalman TDEE + fixedDelta', () async {
      final now = DateTime(2024, 1, 15, 10);
      final provider = await createWarmProvider(
        now: now,
        settings: baseSettings(mode: GoalMode.gain, fixedDelta: 500),
      );

      // TDEE near 2000, gain mode adds 500
      expect(provider.currentGoals.calories, closeTo(2500.0, 100.0));
    });

    test('updates maintenanceCaloriesStart with Kalman result', () async {
      final now = DateTime(2024, 1, 15, 10);
      final provider = await createWarmProvider(
        now: now,
        settings: baseSettings(maintenance: 1800),
      );

      // After Kalman runs, maintenanceCaloriesStart should be updated
      // (it was 1800, Kalman with all-invalid intake stays near 1800)
      expect(
        provider.settings.maintenanceCaloriesStart,
        closeTo(1800.0, 100.0),
      );
    });
  });

  group('GoalsProvider smart targets toggle', () {
    test('smart targets off -> always manual regardless of data', () async {
      final now = DateTime(2024, 1, 15, 10);
      final weights = buildRecentWeights(now, 14);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);

      final settings = GoalSettings(
        anchorWeight: 105.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: false,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Smart targets off: uses manual maintenance = 2000
      expect(provider.currentGoals.calories, 2000.0);
    });
  });

  group('GoalsProvider weekly update with clock', () {
    test('Monday with old lastUpdate -> triggers recalc', () async {
      // Monday
      final now = DateTime(2024, 1, 15, 10);
      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 8), // last Monday
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Should have triggered recalc and notification
      expect(provider.showUpdateNotification, isTrue);
    });

    test('Monday with recent lastUpdate -> no recalc', () async {
      final now = DateTime(2024, 1, 15, 10); // Monday
      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 15), // today
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // lastUpdate is today, no recalc needed
      expect(provider.showUpdateNotification, isFalse);
    });

    test('Tuesday after missed Monday with old lastUpdate -> triggers recalc',
        () async {
      // Tuesday Jan 16, lastUpdate is Jan 8 (before Monday Jan 15)
      final now = DateTime(2024, 1, 16, 10); // Tuesday
      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 8), // before last Monday (Jan 15)
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Tuesday, but lastUpdate is before last Monday -> triggers recalc
      expect(provider.showUpdateNotification, isTrue);
    });

    test('Wednesday after already-updated Tuesday -> no recalc', () async {
      // Wednesday Jan 17, lastUpdate is Tuesday Jan 16 (after Monday Jan 15)
      final now = DateTime(2024, 1, 17, 10); // Wednesday
      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 16), // Tuesday, after last Monday
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // lastUpdate (Tue Jan 16) is after lastMonday (Mon Jan 15) -> no recalc
      expect(provider.showUpdateNotification, isFalse);
    });
  });

  group('GoalsProvider intake validity', () {
    test('day with 0 cal + logCount > 0 -> included as valid (fasted day)',
        () async {
      final now = DateTime(2024, 1, 15, 10); // Monday
      final weights = buildRecentWeights(now, 14);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);

      // Create a DTO with 0 grams (fasted day marker)
      final today = DateTime(now.year, now.month, now.day);
      final dtos = [
        LoggedMacroDTO(
          logTimestamp: today,
          grams: 0.0,
          caloriesPerGram: 0.0,
          proteinPerGram: 0.0,
          fatPerGram: 0.0,
          carbsPerGram: 0.0,
          fiberPerGram: 0.0,
        ),
      ];

      when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
          .thenAnswer((_) async => dtos);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Should complete without error; fasted day is valid intake
      expect(provider.currentGoals.calories, isNotNull);
    });

    test('partial-day intake (today) excluded from Kalman analysis', () async {
      final now = DateTime(2024, 1, 15, 14); // Monday 2pm
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final weights = buildRecentWeights(now, 14);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);

      // Build stable 2000 cal intake for past 90 days through yesterday
      final analysisStart = yesterday.subtract(const Duration(days: 90));
      final dtos = <LoggedMacroDTO>[];
      var d = analysisStart;
      while (!d.isAfter(yesterday)) {
        dtos.add(LoggedMacroDTO(
          logTimestamp: d,
          grams: 100.0,
          caloriesPerGram: 20.0, // 2000 cal total
          proteinPerGram: 1.5,
          fatPerGram: 0.7,
          carbsPerGram: 2.0,
          fiberPerGram: 0.38,
        ));
        d = d.add(const Duration(days: 1));
      }
      // Add today's partial intake: only 300 cal logged so far
      dtos.add(LoggedMacroDTO(
        logTimestamp: today,
        grams: 100.0,
        caloriesPerGram: 3.0, // 300 cal
        proteinPerGram: 0.5,
        fatPerGram: 0.2,
        carbsPerGram: 0.5,
        fiberPerGram: 0.1,
      ));

      when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
          .thenAnswer((_) async => dtos);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // Today's 300 cal partial log should NOT distort TDEE.
      // With stable weight + 2000 cal intake through yesterday, TDEE ~ 2000.
      expect(provider.currentGoals.calories, closeTo(2000.0, 150.0));
      // Specifically: TDEE should NOT be inflated by treating 300 cal as a full day
      expect(provider.settings.maintenanceCaloriesStart, greaterThan(1500.0));
    });

    test('day with 0 cal + logCount == 0 -> excluded from Kalman', () async {
      final now = DateTime(2024, 1, 15, 10);
      final weights = buildRecentWeights(now, 14);

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);
      // No DTOs at all = all days have logCount == 0
      when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
          .thenAnswer((_) async => []);

      final settings = GoalSettings(
        anchorWeight: 100.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // All intake excluded -> TDEE stays near initial 2000
      expect(provider.currentGoals.calories, closeTo(2000.0, 100.0));
    });
  });

  group('GoalsProvider TDEE clamp', () {
    test('Kalman returns extreme value -> clamped to [800, 6000]', () async {
      final now = DateTime(2024, 1, 15, 10);

      // Create weights that would cause Kalman to produce extreme TDEE
      // Rapidly losing weight with very high intake -> extreme TDEE
      final today = DateTime(now.year, now.month, now.day);
      final analysisStart = today.subtract(const Duration(days: 90));

      final weights = <Weight>[];
      var d = analysisStart;
      var i = 0;
      while (!d.isAfter(today)) {
        // Only add weight entries for last 14 days
        if (d.isAfter(today.subtract(const Duration(days: 14)))) {
          weights
              .add(Weight(weight: 200.0 - (i * 2.0), date: d)); // extreme loss
        }
        d = d.add(const Duration(days: 1));
        i++;
      }

      when(mockDatabaseService.getWeightsForRange(any, any))
          .thenAnswer((_) async => weights);

      // Very high intake DTOs
      final dtos = <LoggedMacroDTO>[];
      d = analysisStart;
      while (!d.isAfter(today)) {
        dtos.add(LoggedMacroDTO(
          logTimestamp: d,
          grams: 1000.0,
          caloriesPerGram: 10.0, // 10000 cal/day
          proteinPerGram: 1.0,
          fatPerGram: 1.0,
          carbsPerGram: 1.0,
          fiberPerGram: 0.1,
        ));
        d = d.add(const Duration(days: 1));
      }

      when(mockDatabaseService.getLoggedMacrosForDateRange(any, any))
          .thenAnswer((_) async => dtos);

      final settings = GoalSettings(
        anchorWeight: 200.0,
        maintenanceCaloriesStart: 2000,
        proteinTarget: 150,
        fatTarget: 70,
        carbTarget: 200,
        mode: GoalMode.maintain,
        calculationMode: MacroCalculationMode.proteinCarbs,
        fixedDelta: 0,
        lastTargetUpdate: DateTime(2024, 1, 1),
        useMetric: false,
        fiberTarget: 37.0,
        enableSmartTargets: true,
      );

      final provider =
          await createProvider(now: now, initialSettings: settings);

      // TDEE should be clamped to max 6000
      expect(provider.settings.maintenanceCaloriesStart, lessThanOrEqualTo(6000.0));
      expect(
          provider.settings.maintenanceCaloriesStart, greaterThanOrEqualTo(800.0));
    });
  });

  group('GoalsProvider Onboarding', () {
    test('initial hasSeenWelcome should be false', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = GoalsProvider(
        databaseService: MockDatabaseService(),
        clock: () => DateTime(2024, 1, 15),
      );
      await Future.delayed(Duration.zero);
      expect(provider.hasSeenWelcome, false);
    });

    test('markWelcomeSeen should persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = GoalsProvider(
        databaseService: MockDatabaseService(),
        clock: () => DateTime(2024, 1, 15),
      );
      await Future.delayed(Duration.zero);

      await provider.markWelcomeSeen();
      expect(provider.hasSeenWelcome, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_welcome'), true);
    });

    test('existing users with goals set should have hasSeenWelcome = true',
        () async {
      final settings = GoalSettings.defaultSettings().copyWith(isSet: true);
      SharedPreferences.setMockInitialValues({
        'goal_settings': jsonEncode(settings.toJson()),
      });

      final provider = GoalsProvider(
        databaseService: MockDatabaseService(),
        clock: () => DateTime(2024, 1, 15),
      );
      await Future.delayed(Duration.zero);

      expect(provider.isGoalsSet, true);
      expect(provider.hasSeenWelcome, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_welcome'), true);
    });
  });
}
