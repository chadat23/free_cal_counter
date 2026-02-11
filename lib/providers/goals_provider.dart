import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/models/daily_macro_stats.dart';
import 'package:meal_of_record/services/goal_logic_service.dart';

class GoalsProvider extends ChangeNotifier {
  static const String _settingsKey = 'goal_settings';
  static const String _targetsKey = 'macro_targets';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';

  GoalSettings _settings = GoalSettings.defaultSettings();
  MacroGoals? _currentGoals;
  bool _isLoading = true;
  bool _showUpdateNotification = false;
  bool _hasSeenWelcome = false;

  final DatabaseService _databaseService;
  final DateTime Function() _clock;

  GoalsProvider({DatabaseService? databaseService, DateTime Function()? clock})
    : _databaseService = databaseService ?? DatabaseService.instance,
      _clock = clock ?? DateTime.now {
    _loadFromPrefs();
  }

  // Getters
  GoalSettings get settings => _settings;
  MacroGoals get currentGoals => _currentGoals ?? MacroGoals.hardcoded();
  bool get isLoading => _isLoading;
  bool get showUpdateNotification => _showUpdateNotification;
  bool get isGoalsSet => _settings.isSet;
  bool get hasSeenWelcome => _hasSeenWelcome;

  void dismissNotification() {
    _showUpdateNotification = false;
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _settings = GoalSettings.fromJson(jsonDecode(settingsJson));
      }

      // Load welcome seen state
      _hasSeenWelcome = prefs.getBool(_hasSeenWelcomeKey) ?? false;

      // For existing users who already have goals set, ensure they don't see the welcome
      if (_settings.isSet && !_hasSeenWelcome) {
        _hasSeenWelcome = true;
        await prefs.setBool(_hasSeenWelcomeKey, true);
      }

      final targetsJson = prefs.getString(_targetsKey);
      if (targetsJson != null) {
        _currentGoals = MacroGoals.fromJson(jsonDecode(targetsJson));
      } else {
        // Calculate initial goals from default settings
        final Map<String, double> macros;
        if (_settings.calculationMode == MacroCalculationMode.proteinFat) {
          macros = GoalLogicService.calculateMacrosFromProteinFat(
            targetCalories: _settings.maintenanceCaloriesStart,
            proteinGrams: _settings.proteinTarget,
            fatGrams: _settings.fatTarget,
          );
        } else {
          macros = GoalLogicService.calculateMacrosFromProteinCarbs(
            targetCalories: _settings.maintenanceCaloriesStart,
            proteinGrams: _settings.proteinTarget,
            carbGrams: _settings.carbTarget,
          );
        }
        _currentGoals = MacroGoals(
          calories: macros['calories']!,
          protein: macros['protein']!,
          fat: macros['fat']!,
          carbs: macros['carbs']!,
          fiber: _settings.fiberTarget,
        );
      }

      // After loading, check if a weekly update is due
      // Only check if goals are actually set
      if (_settings.isSet) {
        await checkWeeklyUpdate();
      }
    } catch (e) {
      debugPrint('Error loading goal settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(
    GoalSettings newSettings, {
    bool isInitialSetup = false,
  }) async {
    // Ensure we mark them as set when saving
    _settings = newSettings.copyWith(isSet: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));

    // Changing settings might require immediate recalculation of targets
    await recalculateTargets(isInitialSetup: isInitialSetup);
    notifyListeners();
  }

  Future<void> markWelcomeSeen() async {
    if (!_hasSeenWelcome) {
      _hasSeenWelcome = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenWelcomeKey, true);
      notifyListeners();
    }
  }

  /// Reloads settings from SharedPreferences. Call after backup restore.
  Future<void> reload() async {
    await _loadFromPrefs();
  }

  /// Checks if we need to update the weekly targets.
  /// Triggers on the first app open on or after the next Monday.
  Future<void> checkWeeklyUpdate() async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);

    // Find the most recent Monday (today if Monday, else look back)
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    final lastMonday = today.subtract(Duration(days: daysSinceMonday));

    final lastUpdate = DateTime(
      _settings.lastTargetUpdate.year,
      _settings.lastTargetUpdate.month,
      _settings.lastTargetUpdate.day,
    );

    // Trigger if the last update was before the most recent Monday
    if (lastMonday.isAfter(lastUpdate)) {
      await recalculateTargets(isInitialSetup: false);
      _showUpdateNotification = true;
    }
  }

  /// The core calculation engine for dynamic macro targets.
  Future<void> recalculateTargets({bool isInitialSetup = false}) async {
    double targetCalories = _settings.maintenanceCaloriesStart;

    // Use initial setup logic (manual calories) if requested OR if smart targets are disabled
    final useManualLogic = isInitialSetup || !_settings.enableSmartTargets;

    if (useManualLogic) {
      // Manual mode: maintenance ± delta
      if (_settings.mode == GoalMode.maintain) {
        targetCalories = _settings.maintenanceCaloriesStart;
      } else {
        double delta = _settings.fixedDelta;
        if (_settings.mode == GoalMode.lose) {
          delta = -delta.abs();
        } else {
          delta = delta.abs();
        }
        targetCalories = _settings.maintenanceCaloriesStart + delta;
      }

      _settings = _settings.copyWith(
        lastTargetUpdate: _getNextMonday(_clock()),
      );
    } else {
      // Smart mode: use Kalman TDEE
      final now = _clock();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final analysisStart = yesterday.subtract(const Duration(days: 90));

      // 1. Fetch weights
      final weights = await _databaseService.getWeightsForRange(
        analysisStart,
        now,
      );

      // 2. Cold boot check
      if (!GoalLogicService.hasEnoughWeightData(weights, now: now)) {
        // Fall back to manual mode
        if (_settings.mode == GoalMode.maintain) {
          targetCalories = _settings.maintenanceCaloriesStart;
        } else {
          double delta = _settings.fixedDelta;
          if (_settings.mode == GoalMode.lose) {
            delta = -delta.abs();
          } else {
            delta = delta.abs();
          }
          targetCalories = _settings.maintenanceCaloriesStart + delta;
        }
        _settings = _settings.copyWith(lastTargetUpdate: _clock());
      } else {
        // 3. Fetch intake data
        final dtos = await _databaseService.getLoggedMacrosForDateRange(
          analysisStart,
          now,
        );
        final dailyStats = DailyMacroStats.fromDTOS(dtos, analysisStart, yesterday);

        // 4. Build parallel arrays for the 90-day range
        final Map<int, DailyMacroStats> statsMap = {
          for (var s in dailyStats)
            DateTime(s.date.year, s.date.month, s.date.day)
                .millisecondsSinceEpoch: s,
        };
        final Map<int, double> weightMap = {
          for (var w in weights)
            DateTime(w.date.year, w.date.month, w.date.day)
                .millisecondsSinceEpoch: w.weight,
        };

        final List<double> dailyWeights = [];
        final List<double> dailyIntakes = [];
        final List<bool> intakeIsValid = [];

        var current = analysisStart;
        while (!current.isAfter(yesterday)) {
          final key = DateTime(current.year, current.month, current.day)
              .millisecondsSinceEpoch;
          dailyWeights.add(weightMap[key] ?? 0.0);
          final stat = statsMap[key];
          dailyIntakes.add(stat?.calories ?? 0.0);
          intakeIsValid.add(stat != null && stat.logCount > 0);
          current = current.add(const Duration(days: 1));
        }

        // 5. Run Kalman filter
        final initialWeight = _settings.anchorWeight > 0
            ? _settings.anchorWeight
            : (weights.isNotEmpty ? weights.first.weight : 70.0);

        final estimates = GoalLogicService.calculateKalmanTDEE(
          weights: dailyWeights,
          intakes: dailyIntakes,
          initialTDEE: _settings.maintenanceCaloriesStart,
          initialWeight: initialWeight,
          isMetric: _settings.useMetric,
          intakeIsValid: intakeIsValid,
        );

        if (estimates.isNotEmpty) {
          final kalmanTDEE = estimates.last.clamp(800.0, 6000.0);

          // Update maintenance baseline with Kalman result
          _settings = _settings.copyWith(
            maintenanceCaloriesStart: kalmanTDEE,
          );

          // Apply mode
          if (_settings.mode == GoalMode.maintain) {
            targetCalories = kalmanTDEE;
          } else {
            double delta = _settings.fixedDelta;
            if (_settings.mode == GoalMode.lose) {
              delta = -delta.abs();
            } else {
              delta = delta.abs();
            }
            targetCalories = kalmanTDEE + delta;
          }
        }

        _settings = _settings.copyWith(lastTargetUpdate: _clock());
      }
    }

    // Derive macros
    final Map<String, double> macros;
    if (_settings.calculationMode == MacroCalculationMode.proteinFat) {
      macros = GoalLogicService.calculateMacrosFromProteinFat(
        targetCalories: targetCalories,
        proteinGrams: _settings.proteinTarget,
        fatGrams: _settings.fatTarget,
      );
    } else {
      macros = GoalLogicService.calculateMacrosFromProteinCarbs(
        targetCalories: targetCalories,
        proteinGrams: _settings.proteinTarget,
        carbGrams: _settings.carbTarget,
      );
    }

    _currentGoals = MacroGoals(
      calories: macros['calories']!,
      protein: macros['protein']!,
      fat: macros['fat']!,
      carbs: macros['carbs']!,
      fiber: _settings.fiberTarget,
    );

    debugPrint(
      'Calculated goals: calories=${_currentGoals!.calories}, protein=${_currentGoals!.protein}, fat=${_currentGoals!.fat}, carbs=${_currentGoals!.carbs}, fiber=${_currentGoals!.fiber}',
    );

    // Persist results
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setString(_targetsKey, jsonEncode(_currentGoals!.toJson()));
    await prefs.reload();

    notifyListeners();
  }

  /// Calculates the next Monday from a given date.
  DateTime _getNextMonday(DateTime fromDate) {
    int daysUntilMonday = (DateTime.monday - fromDate.weekday + 7) % 7;
    if (daysUntilMonday == 0) {
      daysUntilMonday = 7; // If today is Monday, next Monday is 7 days away
    }
    return DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    ).add(Duration(days: daysUntilMonday));
  }
}
