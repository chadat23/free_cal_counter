import 'package:flutter/material.dart';
import 'package:meal_of_record/widgets/nutrition_targets_overview_chart.dart';
import 'package:meal_of_record/widgets/screen_background.dart';
import 'package:meal_of_record/widgets/search_ribbon.dart';
import 'package:meal_of_record/models/nutrition_target.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/models/daily_macro_stats.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/providers/weight_provider.dart';
import 'package:meal_of_record/widgets/weight_trend_chart.dart';
import 'package:meal_of_record/models/weight.dart';
import 'package:meal_of_record/services/goal_logic_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<NutritionTarget> _nutritionData = [];
  List<DateTime> _nutritionDates = [];
  List<Weight> _weightHistory = [];
  List<double> _maintenanceHistory = [];
  bool _isLoading = true;
  int _weightRangeDays = 7;
  String _weightRangeLabel = '1 wk';
  DateTime _weightRangeStart = DateTime.now();
  DateTime _weightRangeEnd = DateTime.now();
  bool _needsReload = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isDataLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when providers change
    // This will be called whenever LogProvider or GoalsProvider notifies
    Provider.of<LogProvider>(context);
    Provider.of<GoalsProvider>(context);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isDataLoading) {
      _needsReload = true;
      return;
    }
    _isDataLoading = true;
    _needsReload = false;
    if (!mounted) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6)); // Last 7 days

    try {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      final weightProvider = Provider.of<WeightProvider>(
        context,
        listen: false,
      );

      final stats = await logProvider.getDailyMacroStats(start, today);
      final goals = goalsProvider.currentGoals;

      final yesterday = today.subtract(const Duration(days: 1));
      final rangeStart = today.subtract(Duration(days: _weightRangeDays));
      final window = GoalLogicService.kTdeeWindowDays;
      final analysisStart = rangeStart.subtract(Duration(days: window));

      final analysisStats = await logProvider.getDailyMacroStats(
        analysisStart,
        yesterday,
      );
      // Ensure weights are loaded for the full analysis window (today's weight still counts)
      await weightProvider.loadWeights(analysisStart, today);
      final analysisWeights = weightProvider.weights;

      // Map data for Kalman
      final weightMap = {
        for (var w in analysisWeights)
          DateTime(w.date.year, w.date.month, w.date.day): w.weight,
      };

      final List<double> dailyWeights = [];
      final List<double> dailyIntakes = [];
      final List<bool> intakeIsValid = [];

      // Build a stats map for O(1) lookup
      final statsMap = {
        for (var s in analysisStats)
          DateTime(s.date.year, s.date.month, s.date.day): s,
      };

      var current = analysisStart;
      while (!current.isAfter(yesterday)) {
        final dateOnly = DateTime(current.year, current.month, current.day);
        dailyWeights.add(weightMap[dateOnly] ?? 0.0);

        final stat = statsMap[dateOnly];
        dailyIntakes.add(stat?.calories ?? 0.0);
        intakeIsValid.add(stat != null && stat.logCount > 0);

        current = DateTime(current.year, current.month, current.day + 1);
      }

      final initialWeight = goalsProvider.settings.anchorWeight > 0
          ? goalsProvider.settings.anchorWeight
          : (analysisWeights.isNotEmpty
                ? analysisWeights.first.weight
                : 0.0);

      final maintenanceTrend = GoalLogicService.calculateKalmanTDEE(
        weights: dailyWeights,
        intakes: dailyIntakes,
        initialTDEE: goalsProvider.settings.maintenanceCaloriesStart,
        initialWeight: initialWeight,
        isMetric: goalsProvider.settings.useMetric,
        intakeIsValid: intakeIsValid,
      );

      // Extract the portion corresponding to the displayed range
      final int displayCount = _weightRangeDays + 1;
      final displayMaintenance = maintenanceTrend.length >= displayCount
          ? maintenanceTrend.sublist(maintenanceTrend.length - displayCount)
          : maintenanceTrend;

      // Process stats into NutritionTargets
      if (mounted) {
        setState(() {
          _nutritionDates = stats.map((s) => s.date).toList();
          _nutritionData = _buildTargets(stats, goals);
          _weightHistory = weightProvider.weights.where((w) {
            final d = DateTime(w.date.year, w.date.month, w.date.day);
            return !d.isBefore(rangeStart);
          }).toList();
          _maintenanceHistory = displayMaintenance;
          _weightRangeStart = rangeStart;
          _weightRangeEnd = today;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading overview data: $e');
    } finally {
      _isDataLoading = false;
      if (_needsReload) {
        _loadData();
      }
    }
  }

  Widget _buildGoalsWarning() {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    if (goalsProvider.isGoalsSet) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Goals not set. Nutrient targets and trends may not be accurate.',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/goal_settings');
            },
            child: const Text('Set up Goals'),
          ),
        ],
      ),
    );
  }

  List<NutritionTarget> _buildTargets(
    List<DailyMacroStats> stats,
    MacroGoals goals,
  ) {
    // Extract daily lists (ensure 7 days, index 0 is oldest, index 6 is today)
    // DailyMacroStats.fromDTOS usually returns sorted by date
    // We already requested 7 days, so we should map them directly mostly.

    // Helper to map a field across the stats list
    List<double> mapField(double Function(DailyMacroStats) selector) {
      return stats.map(selector).toList();
    }

    final calories = mapField((s) => s.calories);
    final protein = mapField((s) => s.protein);
    final fat = mapField((s) => s.fat);
    final carbs = mapField((s) => s.carbs);
    final fiber = mapField((s) => s.fiber);

    // Get Today's values (last in the list)
    final todayStats = stats.last;

    return [
      NutritionTarget(
        color: Colors.blue,
        thisAmount: todayStats.calories,
        targetAmount: goals.calories,
        macroLabel: '🔥',
        unitLabel: '',
        dailyAmounts: calories,
      ),
      NutritionTarget(
        color: Colors.red,
        thisAmount: todayStats.protein,
        targetAmount: goals.protein,
        macroLabel: 'P',
        unitLabel: 'g',
        dailyAmounts: protein,
      ),
      NutritionTarget(
        color: Colors.yellow,
        thisAmount: todayStats.fat,
        targetAmount: goals.fat,
        macroLabel: 'F',
        unitLabel: 'g',
        dailyAmounts: fat,
      ),
      NutritionTarget(
        color: Colors.green,
        thisAmount: todayStats.carbs,
        targetAmount: goals.carbs,
        macroLabel: 'C',
        unitLabel: 'g',
        dailyAmounts: carbs,
      ),
      NutritionTarget(
        color: Colors.brown,
        thisAmount: todayStats.fiber,
        targetAmount: goals.fiber,
        macroLabel: 'Fb',
        unitLabel: 'g',
        dailyAmounts: fiber,
      ),
    ];
  }

  Widget _buildRangeSelector() {
    final ranges = {
      '1 wk': 7,
      '1 mo': 30,
      '3 mo': 90,
      '6 mo': 180,
      '1 yr': 365,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ranges.entries.map((entry) {
        final isSelected = _weightRangeLabel == entry.key;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextButton(
            onPressed: () {
              setState(() {
                _weightRangeLabel = entry.key;
                _weightRangeDays = entry.value;
                _isLoading = true;
              });
              _loadData();
            },
            style: TextButton.styleFrom(
              backgroundColor: isSelected ? Colors.white : Colors.transparent,
              foregroundColor: isSelected ? Colors.black : Colors.white,
              minimumSize: const Size(40, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(entry.key, style: const TextStyle(fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      appBar: AppBar(
        title: const Text('Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildGoalsWarning(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NutritionTargetsOverviewChart(
                          nutritionData: _nutritionData,
                          dates: _nutritionDates,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            WeightTrendChart(
                              weightHistory: _weightHistory,
                              maintenanceHistory: _maintenanceHistory,
                              timeframeLabel: _weightRangeLabel,
                              startDate: _weightRangeStart,
                              endDate: _weightRangeEnd,
                            ),
                            const SizedBox(height: 8),
                            _buildRangeSelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SearchRibbon(),
        ],
      ),
    );
  }
}
