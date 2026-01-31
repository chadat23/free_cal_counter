import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:free_cal_counter1/models/goal_settings.dart';
import 'package:free_cal_counter1/models/macro_goals.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/goal_logic_service.dart';

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

  GoalsProvider({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance {
    _loadFromPrefs();
  }

  // Getters
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

  /// Checks if today is Monday and if we need to update the weekly targets.
  Future<void> checkWeeklyUpdate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (now.weekday == DateTime.monday) {
      final lastUpdate = DateTime(
        _settings.lastTargetUpdate.year,
        _settings.lastTargetUpdate.month,
        _settings.lastTargetUpdate.day,
      );

      if (today.isAfter(lastUpdate)) {
        await recalculateTargets(isInitialSetup: false);
        _showUpdateNotification = true;
      }
    }
  }

  /// The core calculation engine for dynamic macro targets.
  Future<void> recalculateTargets({bool isInitialSetup = false}) async {
    double targetCalories = _settings.maintenanceCaloriesStart;

    // Use initial setup logic (manual calories) if requested OR if smart targets are disabled
    final useManualLogic = isInitialSetup || !_settings.enableSmartTargets;

    if (useManualLogic) {
      // First week logic
      if (_settings.mode == GoalMode.maintain) {
        // Just maintenance for first week
        targetCalories = _settings.maintenanceCaloriesStart;
      } else {
        // Lose/Gain: maintenance ± delta for first week
        double delta = _settings.fixedDelta;
        if (_settings.mode == GoalMode.lose) {
          delta = -delta.abs();
        } else {
          delta = delta.abs();
        }
        targetCalories = _settings.maintenanceCaloriesStart + delta;
      }

      // Set lastTargetUpdate to next Monday for initial setup
      _settings = _settings.copyWith(
        lastTargetUpdate: _getNextMonday(DateTime.now()),
      );
    } else {
      // Normal weekly update logic
      // 1. Fetch weight history for trend calculation
      final now = DateTime.now();
      // We need at least some history. 30 days is the correction window.
      final history = await _databaseService.getWeightsForRange(
        now.subtract(
          const Duration(days: 90),
        ), // Get up to 90 days for stable EMA
        now,
      );

      if (history.isNotEmpty) {
        final trendWeight = GoalLogicService.calculateTrendWeight(history);

        double delta = 0.0;
        if (_settings.mode == GoalMode.maintain) {
          // Dynamic drift correction
          delta = GoalLogicService.calculateMaintenanceDelta(
            anchorWeight: _settings.anchorWeight,
            currentTrendWeight: trendWeight,
            isMetric: _settings.useMetric,
          );
          targetCalories += delta;
        } else {
          // For Lose/Gain: dynamically adjust maintenance calories based on trend weight
          // Calculate weight ratio and apply to baseline maintenance calories
          final weightRatio = _settings.anchorWeight > 0
              ? trendWeight / _settings.anchorWeight
              : 1.0;
          final adjustedMaintenanceCalories =
              _settings.maintenanceCaloriesStart * weightRatio;

          // Apply fixed delta to the adjusted maintenance calories
          delta = _settings.fixedDelta;
          if (_settings.mode == GoalMode.lose) {
            delta = -delta.abs();
          } else {
            delta = delta.abs();
          }

          targetCalories = adjustedMaintenanceCalories + delta;
        }
      }

      // Set lastTargetUpdate to today for weekly updates
      _settings = _settings.copyWith(lastTargetUpdate: DateTime.now());
    }

    // 2. Derive macros
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

    // 3. Persist results
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setString(_targetsKey, jsonEncode(_currentGoals!.toJson()));
    await prefs.reload(); // Ensure writes complete before reload

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
