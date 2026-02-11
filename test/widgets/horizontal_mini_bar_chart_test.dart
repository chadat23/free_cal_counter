import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/widgets/horizontal_mini_bar_chart.dart';

void main() {
  testWidgets('HorizontalMiniBarChart renders correctly', (
    WidgetTester tester,
  ) async {
    const consumed = 50.0;
    const target = 100.0;
    const macroLabel = 'P';
    const unitLabel = 'g';
    const color = Colors.blue;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HorizontalMiniBarChart(
            consumed: consumed,
            target: target,
            color: color,
            macroLabel: macroLabel,
            unitLabel: unitLabel,
            notInverted: true,
          ),
        ),
      ),
    );

    expect(find.text('P 50 / 100g'), findsOneWidget);
  });

  testWidgets('HorizontalMiniBarChart renders inverted correctly', (
    WidgetTester tester,
  ) async {
    const consumed = 30.0;
    const target = 100.0;
    const macroLabel = 'P';
    const unitLabel = 'g';
    const color = Colors.blue;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HorizontalMiniBarChart(
            consumed: consumed,
            target: target,
            color: color,
            macroLabel: macroLabel,
            unitLabel: unitLabel,
            notInverted: false,
          ),
        ),
      ),
    );

    // Inverted: 100 - 30 = 70
    expect(find.text('P 70 / 100g'), findsOneWidget);
  });
}
