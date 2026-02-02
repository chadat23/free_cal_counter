import 'package:free_cal_counter1/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:free_cal_counter1/widgets/vertical_mini_bar_chart.dart';
import 'package:free_cal_counter1/models/nutrition_target.dart';
import 'package:free_cal_counter1/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class NutritionTargetsOverviewChart extends StatefulWidget {
  final List<NutritionTarget> nutritionData;

  const NutritionTargetsOverviewChart({super.key, required this.nutritionData});

  @override
  State<NutritionTargetsOverviewChart> createState() =>
      _NutritionTargetsOverviewChartState();
}

class _NutritionTargetsOverviewChartState
    extends State<NutritionTargetsOverviewChart> {
  int _selectedDayIndex = 6; // Default to today (last day in 7-day array)

  @override
  Widget build(BuildContext context) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final showConsumed = navProvider.showConsumed;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.largeWidgetBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Nutrition & Targets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children:
                        List.generate(widget.nutritionData.length, (index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: SizedBox(height: 48),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            final isSelected = dayIndex == _selectedDayIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDayIndex = dayIndex),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5C1A1A) // Maroon highlight
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Column(
                                  children: List.generate(
                                      widget.nutritionData.length,
                                      (nutrientIndex) {
                                    final NutritionTarget data =
                                        widget.nutritionData[nutrientIndex];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: VerticalMiniBarChart(
                                        consumed: data.dailyAmounts[dayIndex],
                                        target: data.targetAmount,
                                        color: data.color,
                                        notInverted: showConsumed,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(weekdays.length, (index) {
                            final isSelected = index == _selectedDayIndex;
                            return Text(
                              weekdays[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white60,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.nutritionData.map((data) {
                      final selectedAmount =
                          data.dailyAmounts[_selectedDayIndex];
                      final displayAmount = showConsumed
                          ? selectedAmount
                          : (data.targetAmount - selectedAmount);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SizedBox(
                          height:
                              48, // Explicitly set height to match MiniBarChart
                          child: Transform.translate(
                            // Added Transform.translate
                            offset: const Offset(
                              0,
                              -10.0,
                            ), // Shift upwards by 10 pixels
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${displayAmount.isFinite ? displayAmount.toInt() : 0} ${data.macroLabel}\n of ${data.targetAmount.isFinite ? data.targetAmount.toInt() : 0}${data.unitLabel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => navProvider.setShowConsumed(true),
                    style: TextButton.styleFrom(
                      backgroundColor: showConsumed
                          ? Colors.white
                          : Colors.transparent,
                      foregroundColor: showConsumed
                          ? Colors.black
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Consumed'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => navProvider.setShowConsumed(false),
                    style: TextButton.styleFrom(
                      backgroundColor: !showConsumed
                          ? Colors.white
                          : Colors.transparent,
                      foregroundColor: !showConsumed
                          ? Colors.black
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Remaining'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
