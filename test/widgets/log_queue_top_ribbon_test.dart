import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/widgets/log_queue_top_ribbon.dart';
import 'package:meal_of_record/widgets/horizontal_mini_bar_chart.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'log_queue_top_ribbon_test.mocks.dart';

@GenerateMocks([LogProvider, GoalsProvider, NavigationProvider])
void main() {
  late MockLogProvider mockLogProvider;
  late MockGoalsProvider mockGoalsProvider;
  late MockNavigationProvider mockNavigationProvider;

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockGoalsProvider = MockGoalsProvider();
    mockNavigationProvider = MockNavigationProvider();

    // Default mock behavior for LogProvider
    when(mockLogProvider.logQueue).thenReturn([]);
    when(mockLogProvider.loggedCalories).thenReturn(1500.0);
    when(mockLogProvider.loggedProtein).thenReturn(100.0);
    when(mockLogProvider.loggedFat).thenReturn(50.0);
    when(mockLogProvider.loggedCarbs).thenReturn(200.0);
    when(mockLogProvider.loggedFiber).thenReturn(20.0);

    when(mockLogProvider.totalCalories).thenReturn(1500.0);
    when(mockLogProvider.totalProtein).thenReturn(100.0);
    when(mockLogProvider.totalFat).thenReturn(50.0);
    when(mockLogProvider.totalCarbs).thenReturn(200.0);
    when(mockLogProvider.totalFiber).thenReturn(20.0);

    when(mockLogProvider.queuedCalories).thenReturn(100.0);
    when(mockLogProvider.queuedProtein).thenReturn(10.0);
    when(mockLogProvider.queuedFat).thenReturn(5.0);
    when(mockLogProvider.queuedCarbs).thenReturn(10.0);
    when(mockLogProvider.queuedFiber).thenReturn(2.0);

    // Default mock behavior for GoalsProvider
    when(mockGoalsProvider.currentGoals).thenReturn(MacroGoals(
      calories: 2000.0,
      protein: 150.0,
      fat: 70.0,
      carbs: 300.0,
      fiber: 30.0,
    ));

    // Default mock behavior for NavigationProvider
    when(mockNavigationProvider.showConsumed).thenReturn(true);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: mockGoalsProvider),
        ChangeNotifierProvider<NavigationProvider>.value(value: mockNavigationProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: LogQueueTopRibbon(
              arrowDirection: Icons.arrow_drop_up,
              onArrowPressed: () {},
              logProvider: mockLogProvider,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Uses daily goals as target when showConsumed is true', (tester) async {
    when(mockNavigationProvider.showConsumed).thenReturn(true);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final charts = tester.widgetList<HorizontalMiniBarChart>(find.byType(HorizontalMiniBarChart));
    
    // Day's Macros (Projected) Calories Chart (first row)
    final dayChart = charts.first;
    expect(dayChart.target, 2000.0);
    
    // Queue's Macros Calories Chart (second row, starts at index 5)
    final queueChart = charts.skip(5).first;
    expect(queueChart.target, 2000.0);
  });

  testWidgets('Uses remaining budget as target when showConsumed is false', (tester) async {
    when(mockNavigationProvider.showConsumed).thenReturn(false);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final charts = tester.widgetList<HorizontalMiniBarChart>(find.byType(HorizontalMiniBarChart));
    
    // Day's Macros (Projected) Calories Chart still uses daily goal for context
    final dayChart = charts.first;
    expect(dayChart.target, 2000.0);
    
    // Queue's Macros Calories Chart uses remaining budget (2000 - 1500 = 500)
    final queueChart = charts.skip(5).first;
    expect(queueChart.target, 500.0);
    
    // Queue's Macros Protein Chart uses remaining budget (150 - 100 = 50)
    final queueProteinChart = charts.skip(6).first;
    expect(queueProteinChart.target, 50.0);
  });
}
