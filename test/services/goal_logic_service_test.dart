import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/daily_macro_stats.dart';
import 'package:meal_of_record/models/weight.dart';
import 'package:meal_of_record/services/goal_logic_service.dart';

void main() {
  group('GoalLogicService', () {
    test('calculateTrendWeight should return 0 for empty history', () {
      expect(GoalLogicService.calculateTrendWeight([]), 0.0);
    });

    test('calculateTrendWeight should return single weight for one entry', () {
      final history = [Weight(weight: 70.0, date: DateTime(2023, 1, 1))];
      expect(GoalLogicService.calculateTrendWeight(history), 70.0);
    });

    test('calculateTrendWeight should calculate correct EMA', () {
      final history = [
        Weight(weight: 100.0, date: DateTime(2023, 1, 1)),
        Weight(weight: 110.0, date: DateTime(2023, 1, 2)),
      ];
      // alpha = 0.15
      // ema = 0.15 * 110 + (1 - 0.15) * 100
      // ema = 16.5 + 85 = 101.5
      expect(GoalLogicService.calculateTrendWeight(history), 101.5);
    });

    test('calculateTrendHistory should return history of EMAs', () {
      final history = [
        Weight(weight: 100.0, date: DateTime(2023, 1, 1)),
        Weight(weight: 110.0, date: DateTime(2023, 1, 2)),
      ];
      final trends = GoalLogicService.calculateTrendHistory(history);
      expect(trends.length, 2);
      expect(trends[0], 100.0);
      expect(trends[1], 101.5);
    });

    test('calculateMacrosFromProteinFat should derive carbs correctly', () {
      // Budget = 2000. P = 150 (600 cal). F = 60 (540 cal).
      // Remainder = 2000 - 600 - 540 = 860 cal.
      // Carbs = 860 / 4 = 215g.
      final macros = GoalLogicService.calculateMacrosFromProteinFat(
        targetCalories: 2000,
        proteinGrams: 150,
        fatGrams: 60,
      );
      expect(macros['carbs'], 215.0);
      expect(macros['protein'], 150.0);
      expect(macros['fat'], 60.0);
    });

    test('calculateMacrosFromProteinCarbs should derive fat correctly', () {
      // Budget = 2000. P = 150 (600 cal). C = 200 (800 cal).
      // Remainder = 2000 - 600 - 800 = 600 cal.
      // Fat = 600 / 9 = 66.66...g.
      final macros = GoalLogicService.calculateMacrosFromProteinCarbs(
        targetCalories: 2000,
        proteinGrams: 150,
        carbGrams: 200,
      );
      expect(macros['fat'], closeTo(66.66, 0.01));
      expect(macros['protein'], 150.0);
      expect(macros['carbs'], 200.0);
    });

    test(
      'calculateMacrosFromProteinFat: protein + fat > budget -> carbs = 0',
      () {
        // Budget = 1000. P = 200 (800 cal). F = 50 (450 cal).
        // Remainder = 1000 - 800 - 450 = -250 -> clamped to 0
        final macros = GoalLogicService.calculateMacrosFromProteinFat(
          targetCalories: 1000,
          proteinGrams: 200,
          fatGrams: 50,
        );
        expect(macros['carbs'], 0.0);
      },
    );

    test(
      'calculateMacrosFromProteinCarbs: protein + carbs > budget -> fat = 0',
      () {
        // Budget = 1000. P = 200 (800 cal). C = 100 (400 cal).
        // Remainder = 1000 - 800 - 400 = -200 -> clamped to 0
        final macros = GoalLogicService.calculateMacrosFromProteinCarbs(
          targetCalories: 1000,
          proteinGrams: 200,
          carbGrams: 100,
        );
        expect(macros['fat'], 0.0);
      },
    );
  });

  group('Kalman TDEE', () {
    test('stable weight + intake -> TDEE converges to intake', () {
      final weights = List.generate(30, (_) => 100.0);
      final intakes = List.generate(30, (_) => 2000.0);
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2000.0,
        initialWeight: 100.0,
      );

      expect(results.length, 30);
      expect(results.last.tdee, closeTo(2000.0, 10.0));
    });

    test('gaining weight -> TDEE < intake', () {
      final weights = List.generate(
        30,
        (i) => 100.0 + i * 0.1,
      ); // gaining 0.1lb/day
      final intakes = List.generate(30, (_) => 2500.0);
      // Gain of 0.1lb/day means surplus of 350cal.
      // If intake is 2500, TDEE should be ~2150.
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2500.0,
        initialWeight: 100.0,
      );

      expect(results.last.tdee, closeTo(2150.0, 100.0));
    });

    test('losing weight -> TDEE > intake', () {
      final weights = List.generate(
        30,
        (i) => 200.0 - i * 0.1,
      ); // losing 0.1lb/day
      final intakes = List.generate(30, (_) => 1800.0);
      // Loss of 0.1lb/day means deficit of 350cal.
      // If intake is 1800, TDEE should be ~2150.
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 1800.0,
        initialWeight: 200.0,
      );

      expect(results.last.tdee, closeTo(2150.0, 100.0));
    });

    test('missing weight data -> still converges', () {
      final weights = List.generate(30, (i) => i % 7 == 0 ? 100.0 : 0.0);
      final intakes = List.generate(30, (_) => 2000.0);
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2000.0,
        initialWeight: 100.0,
      );

      expect(results.length, 30);
      expect(results.last.tdee, closeTo(2000.0, 50.0));
    });

    test('missing intake (intakeIsValid=false) -> TDEE stays near initial',
        () {
      final weights = List.generate(30, (_) => 100.0);
      final intakes = List.generate(30, (_) => 0.0); // all zeros
      final intakeIsValid = List.generate(30, (_) => false); // all invalid

      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2000.0,
        initialWeight: 100.0,
        intakeIsValid: intakeIsValid,
      );

      expect(results.length, 30);
      // With all intake invalid, filter substitutes xTdee for intake,
      // so predict step has (xTdee - xTdee) = 0 surplus. TDEE should stay near initial.
      expect(results.last.tdee, closeTo(2000.0, 50.0));
    });

    test('mixed missing intake + weight -> reasonable estimate', () {
      // Some days have intake, some don't; some days have weight, some don't
      final weights = List.generate(30, (i) {
        if (i < 5) return 0.0; // no weight first 5 days
        return 100.0; // stable weight after that
      });
      final intakes = List.generate(30, (_) => 2000.0);
      final intakeIsValid = List.generate(30, (i) {
        return i % 3 != 0; // every 3rd day is invalid
      });

      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2000.0,
        initialWeight: 100.0,
        intakeIsValid: intakeIsValid,
      );

      expect(results.length, 30);
      expect(results.last.tdee, closeTo(2000.0, 100.0));
    });

    test('all intake missing -> TDEE ~ initialTDEE', () {
      final weights = List.generate(30, (_) => 100.0);
      final intakes = List.generate(30, (_) => 0.0);
      final intakeIsValid = List.generate(30, (_) => false);

      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2500.0,
        initialWeight: 100.0,
        intakeIsValid: intakeIsValid,
      );

      expect(results.last.tdee, closeTo(2500.0, 50.0));
    });

    test('metric vs imperial -> different due to C constant', () {
      final weights = List.generate(30, (i) => 80.0 + i * 0.05);
      final intakes = List.generate(30, (_) => 2500.0);

      final resultsImperial = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2500.0,
        initialWeight: 80.0,
        isMetric: false,
      );

      final resultsMetric = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 2500.0,
        initialWeight: 80.0,
        isMetric: true,
      );

      // With metric (kCalPerKg = 7716), the same weight change implies a
      // larger caloric surplus/deficit than imperial (kCalPerLb = 3500).
      // So the TDEE estimates should differ.
      expect(resultsImperial.last.tdee != resultsMetric.last.tdee, isTrue);
    });

    test('large surplus -> correct weight gain model', () {
      // 1000 cal surplus/day for 30 days at 3500 cal/lb
      // Expected gain: 1000/3500 = 0.286 lb/day
      final weights = List.generate(30, (i) => 150.0 + i * 0.286);
      final intakes = List.generate(30, (_) => 3000.0);

      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 3000.0,
        initialWeight: 150.0,
      );

      // TDEE should converge toward 2000 (intake 3000 - surplus 1000)
      expect(results.last.tdee, closeTo(2000.0, 200.0));
    });

    test('large deficit -> correct weight loss model', () {
      // 1000 cal deficit/day for 30 days at 3500 cal/lb
      // Expected loss: 1000/3500 = 0.286 lb/day
      final weights = List.generate(30, (i) => 200.0 - i * 0.286);
      final intakes = List.generate(30, (_) => 1500.0);

      final results = GoalLogicService.calculateKalmanTDEE(
        weights: weights,
        intakes: intakes,
        initialTDEE: 1500.0,
        initialWeight: 200.0,
      );

      // TDEE should converge toward 2500 (intake 1500 + deficit 1000)
      expect(results.last.tdee, closeTo(2500.0, 200.0));
    });

    test('covariance update correctness: 2-step hand-verified example', () {
      // Run exactly 2 steps with known values to verify the bug fix
      // Day 0: weight=100, intake=2000
      // Day 1: weight=100, intake=2000
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: [100.0, 100.0],
        intakes: [2000.0, 2000.0],
        initialTDEE: 2000.0,
        initialWeight: 100.0,
      );

      expect(results.length, 2);
      // With stable weight and matching intake, TDEE should stay at ~2000
      expect(results[0].tdee, closeTo(2000.0, 5.0));
      expect(results[1].tdee, closeTo(2000.0, 5.0));

      // Now verify the old bug would have given different results
      // by running with a scenario where covariance matters more:
      // one measurement with a large discrepancy
      final resultsDiscrepant = GoalLogicService.calculateKalmanTDEE(
        weights: [100.0, 105.0], // big jump
        intakes: [2000.0, 2000.0],
        initialTDEE: 2000.0,
        initialWeight: 100.0,
      );

      // The TDEE should adjust downward (weight gain implies TDEE < intake)
      expect(resultsDiscrepant[1].tdee, lessThan(2000.0));
    });

    test('empty inputs -> empty results', () {
      final results = GoalLogicService.calculateKalmanTDEE(
        weights: [],
        intakes: [],
        initialTDEE: 2000.0,
        initialWeight: 100.0,
      );
      expect(results, isEmpty);
    });
  });

  group('hasEnoughWeightData', () {
    test('0 weights -> false', () {
      expect(
        GoalLogicService.hasEnoughWeightData(
          [],
          windowDays: 28,
          now: DateTime(2024, 1, 15),
        ),
        isFalse,
      );
    });

    test('70% threshold: 19 of 28 -> false', () {
      final now = DateTime(2024, 1, 15);
      // 70% of 28 = 19.6, ceil = 20. So 19 is not enough.
      final weights = List.generate(
        19,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(weights, windowDays: 28, now: now),
        isFalse,
      );
    });

    test('70% threshold: 20 of 28 -> true', () {
      final now = DateTime(2024, 1, 15);
      // 70% of 28 = 19.6, ceil = 20
      final weights = List.generate(
        20,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(weights, windowDays: 28, now: now),
        isTrue,
      );
    });

    test('70% threshold: 10 of 14 -> true', () {
      final now = DateTime(2024, 1, 15);
      // 70% of 14 = 9.8, ceil = 10
      final weights = List.generate(
        10,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(weights, windowDays: 14, now: now),
        isTrue,
      );
    });

    test('70% threshold: 9 of 14 -> false', () {
      final now = DateTime(2024, 1, 15);
      final weights = List.generate(
        9,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(weights, windowDays: 14, now: now),
        isFalse,
      );
    });

    test('70% threshold: 42 of 60 -> true', () {
      final now = DateTime(2024, 1, 15);
      // 70% of 60 = 42
      final weights = List.generate(
        42,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(weights, windowDays: 60, now: now),
        isTrue,
      );
    });

    test('weights outside window do not count', () {
      final now = DateTime(2024, 1, 15);
      // 9 recent + 10 old (beyond 28 days)
      final recentWeights = List.generate(
        9,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: i)),
        ),
      );
      final oldWeights = List.generate(
        10,
        (i) => Weight(
          weight: 100.0,
          date: now.subtract(Duration(days: 30 + i)),
        ),
      );
      expect(
        GoalLogicService.hasEnoughWeightData(
          [...recentWeights, ...oldWeights],
          windowDays: 28,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('effectiveWindow', () {
    test('60d setting with 90 days of data -> 60', () {
      expect(GoalLogicService.effectiveWindow(60, 90), 60);
    });

    test('60d setting with 60 days of data -> 60', () {
      expect(GoalLogicService.effectiveWindow(60, 60), 60);
    });

    test('60d setting with 30 days of data -> 28', () {
      expect(GoalLogicService.effectiveWindow(60, 30), 28);
    });

    test('60d setting with 20 days of data -> 14', () {
      expect(GoalLogicService.effectiveWindow(60, 20), 14);
    });

    test('60d setting with 10 days of data -> 0 (not enough)', () {
      expect(GoalLogicService.effectiveWindow(60, 10), 0);
    });

    test('28d setting with 90 days of data -> 28', () {
      expect(GoalLogicService.effectiveWindow(28, 90), 28);
    });

    test('28d setting with 15 days of data -> 14', () {
      expect(GoalLogicService.effectiveWindow(28, 15), 14);
    });

    test('14d setting with 90 days of data -> 14', () {
      expect(GoalLogicService.effectiveWindow(14, 90), 14);
    });

    test('14d setting with 10 days of data -> 0', () {
      expect(GoalLogicService.effectiveWindow(14, 10), 0);
    });

    test('14d setting with 14 days of data -> 14', () {
      expect(GoalLogicService.effectiveWindow(14, 14), 14);
    });
  });

  group('computeTdeeAtDate', () {
    /// Helper: builds weightMap and statsMap for 28 days ending at [now].
    /// [makeStats] returns a DailyMacroStats for each day index (0 = oldest).
    /// All days get a weight of [weight].
    Map<String, dynamic> buildMaps({
      required DateTime now,
      required int days,
      required double weight,
      required DailyMacroStats Function(DateTime date, int index) makeStats,
    }) {
      final Map<DateTime, double> weightMap = {};
      final Map<DateTime, DailyMacroStats> statsMap = {};

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: days - i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        weightMap[dateOnly] = weight;
        statsMap[dateOnly] = makeStats(dateOnly, i);
      }
      return {'weightMap': weightMap, 'statsMap': statsMap};
    }

    test('seed=0 converges slowly (documents why UI uses 2000 default)', () {
      // With seed=0, the Kalman filter starts far from the true TDEE.
      // In 28 days it moves toward the truth but doesn't fully converge.
      // This documents WHY the UI now defaults to 2000 instead of 0.
      final now = DateTime(2024, 3, 1);
      const days = 28;

      final maps = buildMaps(
        now: now,
        days: days,
        weight: 180.0,
        makeStats: (date, i) => DailyMacroStats(
          date: date,
          calories: 2700,
          logCount: 3,
        ),
      );

      final weightMap = maps['weightMap'] as Map<DateTime, double>;
      final statsMap = maps['statsMap'] as Map<DateTime, DailyMacroStats>;

      final estimateSeed0 = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 0.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      // Seed=0 still moves toward 2700 but undershoots significantly
      expect(estimateSeed0, isNotNull);
      expect(estimateSeed0!.tdee, greaterThan(1500));
      expect(estimateSeed0.tdee, lessThan(2700));
    });

    test('seed=2000 + zero-calorie logged days: fixed preview scenario', () {
      // After both fixes: seed defaults to 2000 (not 0), and
      // zero-calorie logged days are marked invalid (not treated as 0 intake).
      final now = DateTime(2024, 3, 1);
      const days = 28;

      final maps = buildMaps(
        now: now,
        days: days,
        weight: 180.0,
        makeStats: (date, i) {
          if (i % 3 == 0) {
            return DailyMacroStats(date: date, calories: 0, logCount: 1);
          }
          return DailyMacroStats(date: date, calories: 2700, logCount: 3);
        },
      );

      final weightMap = maps['weightMap'] as Map<DateTime, double>;
      final statsMap = maps['statsMap'] as Map<DateTime, DailyMacroStats>;

      final estimate = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 2000.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      expect(estimate, isNotNull);
      // With both fixes, TDEE should converge near 2700
      expect(estimate!.tdee, closeTo(2700, 400));
    });

    test('seed sensitivity: seed 2000 vs 2661 both converge to ~2700', () {
      final now = DateTime(2024, 3, 1);
      const days = 28;

      final maps = buildMaps(
        now: now,
        days: days,
        weight: 180.0,
        makeStats: (date, i) => DailyMacroStats(
          date: date,
          calories: 2700,
          logCount: 3,
        ),
      );

      final weightMap = maps['weightMap'] as Map<DateTime, double>;
      final statsMap = maps['statsMap'] as Map<DateTime, DailyMacroStats>;

      final estimateSeed2000 = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 2000.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      final estimateSeed2661 = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 2661.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      expect(estimateSeed2000, isNotNull);
      expect(estimateSeed2661, isNotNull);
      // Both should converge near 2700, not diverge wildly
      expect(estimateSeed2000!.tdee, closeTo(2700, 200));
      expect(estimateSeed2661!.tdee, closeTo(2700, 200));
      // And they should be close to each other
      expect(
        (estimateSeed2000.tdee - estimateSeed2661.tdee).abs(),
        lessThan(300),
      );
    });

    test('zero-calorie logged days: intakeIsValid filters them out', () {
      // Scenario: some days have logCount > 0 but calories == 0.
      // Before the fix, these were marked valid → filter used 0 as intake
      // → TDEE collapsed toward 0 (clamped to 800).
      // After the fix, these are marked invalid → filter substitutes xTdee
      // → TDEE stays reasonable.
      final now = DateTime(2024, 3, 1);
      const days = 28;

      final maps = buildMaps(
        now: now,
        days: days,
        weight: 180.0,
        makeStats: (date, i) {
          if (i % 3 == 0) {
            // Every 3rd day: logged something but 0 calories
            return DailyMacroStats(
              date: date,
              calories: 0,
              logCount: 1,
            );
          }
          // Other days: normal logging
          return DailyMacroStats(
            date: date,
            calories: 2700,
            logCount: 3,
          );
        },
      );

      final weightMap = maps['weightMap'] as Map<DateTime, double>;
      final statsMap = maps['statsMap'] as Map<DateTime, DailyMacroStats>;

      final estimate = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 2000.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      expect(estimate, isNotNull);
      // With the fix, TDEE should stay reasonable (near 2700), not collapse
      expect(estimate!.tdee, greaterThan(1500));
      expect(estimate.tdee, closeTo(2700, 400));
    });

    test('all-zero-calorie days with seed 2000: TDEE stays near seed', () {
      // When ALL days have logCount > 0 but calories == 0,
      // all are marked invalid → filter uses xTdee for every day → neutral.
      // TDEE should stay near the seed.
      final now = DateTime(2024, 3, 1);
      const days = 28;

      final maps = buildMaps(
        now: now,
        days: days,
        weight: 180.0,
        makeStats: (date, i) => DailyMacroStats(
          date: date,
          calories: 0,
          logCount: 1,
        ),
      );

      final weightMap = maps['weightMap'] as Map<DateTime, double>;
      final statsMap = maps['statsMap'] as Map<DateTime, DailyMacroStats>;

      final estimate = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: 28,
        tdeeDate: now,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: 2000.0,
        initialWeight: 180.0,
        isMetric: false,
      );

      expect(estimate, isNotNull);
      // All intake invalid → neutral predictions → TDEE stays near seed
      expect(estimate!.tdee, closeTo(2000, 100));
    });
  });
}
