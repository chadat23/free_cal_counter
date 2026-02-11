import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/weight.dart';
import 'package:meal_of_record/widgets/weight_trend_chart.dart';

void main() {
  testWidgets('WeightTrendChart displays empty state message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightTrendChart(
            weightHistory: [],
            maintenanceHistory: [],
            timeframeLabel: '30d',
            startDate: DateTime(2023, 1, 1),
            endDate: DateTime(2023, 1, 31),
          ),
        ),
      ),
    );

    expect(find.text('No weight data for the last 30 days'), findsOneWidget);
  });

  testWidgets('WeightTrendChart renders CustomPaint with data', (tester) async {
    final history = [
      Weight(weight: 70.0, date: DateTime(2023, 1, 1)),
      Weight(weight: 71.0, date: DateTime(2023, 1, 2)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightTrendChart(
            weightHistory: history,
            maintenanceHistory: List.generate(31, (_) => 2000.0),
            timeframeLabel: '1 mo',
            startDate: DateTime(2023, 1, 1),
            endDate: DateTime(2023, 1, 31),
          ),
        ),
      ),
    );

    expect(find.text('Weight Trend (1 mo)'), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    expect(find.text('Jan 1'), findsOneWidget);
    expect(find.text('Jan 31'), findsOneWidget);
  });

  testWidgets('WeightTrendChart handles gaps in data with placeholder dots', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    // Data only for 2 days ago and yesterday, MISSING today
    final history = [
      Weight(weight: 80.0, date: twoDaysAgo),
      Weight(weight: 81.0, date: yesterday),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightTrendChart(
            weightHistory: history,
            maintenanceHistory: List.generate(3, (_) => 2000.0),
            timeframeLabel: '1 wk',
            startDate: twoDaysAgo,
            endDate: today,
          ),
        ),
      ),
    );

    expect(find.text('Weight Trend (1 wk)'), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));

    // We can't easily check the painter's private dots, but we can verify it renders.
    // Future: Add more specific checks if WeightTrendChart is refactored to expose point counts.
  });

  testWidgets('WeightTrendChart has GestureDetector for tap interaction', (
    tester,
  ) async {
    final history = [
      Weight(weight: 70.0, date: DateTime(2023, 1, 1)),
      Weight(weight: 71.0, date: DateTime(2023, 1, 15)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightTrendChart(
            weightHistory: history,
            maintenanceHistory: List.generate(31, (_) => 2000.0),
            timeframeLabel: '1 mo',
            startDate: DateTime(2023, 1, 1),
            endDate: DateTime(2023, 1, 31),
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
  });

  testWidgets('WeightTrendChart does not crash on tap', (tester) async {
    final history = [
      Weight(weight: 70.0, date: DateTime(2023, 1, 1)),
      Weight(weight: 71.0, date: DateTime(2023, 1, 15)),
      Weight(weight: 69.5, date: DateTime(2023, 1, 31)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightTrendChart(
            weightHistory: history,
            maintenanceHistory: List.generate(31, (_) => 2000.0),
            timeframeLabel: '1 mo',
            startDate: DateTime(2023, 1, 1),
            endDate: DateTime(2023, 1, 31),
          ),
        ),
      ),
    );

    // Tap in the chart area — should not throw
    await tester.tap(find.byType(CustomPaint).first);
    await tester.pump();

    // Tap again to toggle off — should not throw
    await tester.tap(find.byType(CustomPaint).first);
    await tester.pump();
  });

  group('findNearestRealPoint', () {
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 1, 31);
    final chartSize = const Size(400, 200);

    final realData = [
      Weight(weight: 70.0, date: DateTime(2023, 1, 1)),
      Weight(weight: 72.0, date: DateTime(2023, 1, 16)),
      Weight(weight: 71.0, date: DateTime(2023, 1, 31)),
    ];

    // Trends match 1:1 with realData (EMA values)
    final trends = [70.0, 70.3, 70.4];

    test('finds nearest point when tap is close', () {
      // Point 0 is at the left edge of the chart (x ≈ leftPadding=40)
      // Weight 70.0 is near the bottom of the chart
      final result = findNearestRealPoint(
        tapPosition: const Offset(40, 180),
        chartSize: chartSize,
        realData: realData,
        trends: trends,
        startDate: startDate,
        endDate: endDate,
      );
      expect(result, 0);
    });

    test('returns null when tap is far from all points', () {
      final result = findNearestRealPoint(
        tapPosition: const Offset(200, 10),
        chartSize: chartSize,
        realData: realData,
        trends: trends,
        startDate: startDate,
        endDate: endDate,
        threshold: 5.0,
      );
      expect(result, isNull);
    });

    test('returns null for empty data', () {
      final result = findNearestRealPoint(
        tapPosition: const Offset(100, 100),
        chartSize: chartSize,
        realData: [],
        trends: [],
        startDate: startDate,
        endDate: endDate,
      );
      expect(result, isNull);
    });

    test('handles single data point', () {
      final singleData = [Weight(weight: 70.0, date: DateTime(2023, 1, 16))];
      final singleTrends = [70.0];

      // The single point should be at center-x of the chart
      final result = findNearestRealPoint(
        tapPosition: const Offset(200, 100),
        chartSize: chartSize,
        realData: singleData,
        trends: singleTrends,
        startDate: startDate,
        endDate: endDate,
      );
      expect(result, 0);
    });

    test('picks closest point when multiple are nearby', () {
      // Point at index 1 is date Jan 16 — roughly at x = 40 + (15/30)*320 = 200
      final result = findNearestRealPoint(
        tapPosition: const Offset(200, 100),
        chartSize: chartSize,
        realData: realData,
        trends: trends,
        startDate: startDate,
        endDate: endDate,
        threshold: 200.0, // large threshold so all points qualify
      );
      // Index 1 (Jan 16) is closest to x=200
      expect(result, 1);
    });
  });
}
