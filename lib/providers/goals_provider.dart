import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/models/macro_goals.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/models/daily_macro_stats.dart';
import 'package:meal_of_record/services/goal_logic_service.dart';
import 'package:meal_of_record/models/weight.dart';

class TargetRecalcResult {
  final GoalSettings settings;
  final MacroGoals goals;
  const TargetRecalcResult({required this.settings, required this.goals});
}

class GoalsProvider extends ChangeNotifier with WidgetsBindingObserver {
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
    // Use the binding only if it is initialized (it might not be in some unit tests)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for weekly update when app returns to foreground
      if (_settings.isSet && !_isLoading) {
        checkWeeklyUpdate();
      }
    }
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

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setString(_targetsKey, jsonEncode(_currentGoals!.toJson()));
    await prefs.reload();
  }

  Future<void> saveSettings(
    GoalSettings newSettings, {
    bool isInitialSetup = false,
  }) async {
    // Ensure we mark them as set when saving
    _settings = newSettings.copyWith(isSet: true);

    // Recalculate, apply result, persist once
    final result = await recalculateTargets(_settings, isInitialSetup: isInitialSetup);
    _settings = result.settings;
    _currentGoals = result.goals;
    await _saveToPrefs();
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
      final result = await recalculateTargets(_settings, isInitialSetup: false);
      _settings = result.settings;
      _currentGoals = result.goals;
      await _saveToPrefs();
      _showUpdateNotification = true;
      notifyListeners();
    }
  }

  /// The core calculation engine for dynamic macro targets.
  /// Pure computation: takes settings, returns result. Does NOT persist or notify.
  Future<TargetRecalcResult> recalculateTargets(GoalSettings settings, {bool isInitialSetup = false}) async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final userWindow = settings.tdeeWindowDays;
    // Use DateTime(y, m, d) to ensure midnight and avoid DST issues
    final rawAnalysisStart = today.subtract(Duration(days: userWindow));
    final analysisStart = DateTime(rawAnalysisStart.year, rawAnalysisStart.month, rawAnalysisStart.day);

    // Fetch weights if needed for Smart TDEE OR Dynamic Protein
    // We fetch a broad range to support both inputs
    List<Weight> weights = [];
    try {
      if (settings.enableSmartTargets ||
          settings.proteinTargetMode == ProteinTargetMode.percentageOfWeight) {
        weights = await _databaseService.getWeightsForRange(analysisStart, now);
      }
    } catch (e) {
      debugPrint('Error in recalculateTargets DB call: $e');
      rethrow;
    }

    double targetCalories = settings.maintenanceCaloriesStart;
    double? kalmanWeightEstimate;

    // Use initial setup logic (manual calories) if requested OR if smart targets are disabled
    final useManualLogic = isInitialSetup || !settings.enableSmartTargets;

    if (useManualLogic) {
      // Manual mode: maintenance ± delta
      if (settings.mode == GoalMode.maintain) {
        targetCalories = settings.maintenanceCaloriesStart;
      } else {
        double delta = settings.fixedDelta;
        if (settings.mode == GoalMode.lose) {
          delta = -delta.abs();
        } else {
          delta = delta.abs();
        }
        targetCalories = settings.maintenanceCaloriesStart + delta;
      }

      settings = settings.copyWith(
        lastTargetUpdate: _clock(),
      );
    } else {
      // Smart mode: use Kalman TDEE via shared function
      // Fetch intake data for the full window
      final dtos = await _databaseService.getLoggedMacrosForDateRange(
        analysisStart,
        now,
      );
      final dailyStats = DailyMacroStats.fromDTOS(dtos, analysisStart, yesterday);

      // Build maps for computeTdeeAtDate
      final Map<DateTime, double> weightMap = {
        for (var w in weights)
          DateTime(w.date.year, w.date.month, w.date.day): w.weight,
      };
      final Map<DateTime, DailyMacroStats> statsMap = {
        for (var s in dailyStats)
          DateTime(s.date.year, s.date.month, s.date.day): s,
      };

      final initialWeight = settings.anchorWeight > 0
          ? settings.anchorWeight
          : (weights.isNotEmpty ? weights.first.weight : 70.0);

      final estimate = GoalLogicService.computeTdeeAtDate(
        tdeeWindow: userWindow,
        tdeeDate: today,
        weightMap: weightMap,
        statsMap: statsMap,
        initialTDEE: settings.maintenanceCaloriesStart,
        initialWeight: initialWeight,
      );

      if (estimate == null) {
        // Fall back to manual mode
        if (settings.mode == GoalMode.maintain) {
          targetCalories = settings.maintenanceCaloriesStart;
        } else {
          double delta = settings.fixedDelta;
          if (settings.mode == GoalMode.lose) {
            delta = -delta.abs();
          } else {
            delta = delta.abs();
          }
          targetCalories = settings.maintenanceCaloriesStart + delta;
        }
        settings = settings.copyWith(lastTargetUpdate: _clock());
      } else {
        final kalmanTDEE = estimate.tdee.clamp(800.0, 6000.0).roundToDouble();
        final kalmanWeight = estimate.weight;
        kalmanWeightEstimate = kalmanWeight;

        // Update maintenance baseline with Kalman result
        settings = settings.copyWith(
          maintenanceCaloriesStart: kalmanTDEE,
        );

        // Apply mode
        if (settings.mode == GoalMode.maintain) {
          // Drift correction: adjust calories to steer weight back to anchor
          final double C = GoalLogicService.kCalPerLb;
          final drift = kalmanWeight - settings.anchorWeight;
          final correctionCals = drift * C /
              settings.correctionWindowDays;
          targetCalories = kalmanTDEE + correctionCals;
        } else {
          double delta = settings.fixedDelta;
          if (settings.mode == GoalMode.lose) {
            delta = -delta.abs();
          } else {
            delta = delta.abs();
          }
          targetCalories = kalmanTDEE + delta;
        }

        settings = settings.copyWith(lastTargetUpdate: _clock());
      }
    }

    // --- Dynamic Protein Calculation ---
    if (settings.proteinTargetMode == ProteinTargetMode.percentageOfWeight) {
      double referenceWeight = 0.0;

      // 1. Try Kalman weight estimate (smart mode, warm boot)
      if (kalmanWeightEstimate != null && kalmanWeightEstimate > 0) {
        referenceWeight = kalmanWeightEstimate;
      } else if (weights.isNotEmpty) {
        // 2. Fallback to latest raw weight
        weights.sort((a, b) => a.date.compareTo(b.date));
        referenceWeight = weights.last.weight;
      } else {
        // 3. Fallback to anchor weight
        referenceWeight = settings.anchorWeight;
      }

      if (referenceWeight > 0) {
        final newProtein = referenceWeight * settings.proteinMultiplier;
        settings = settings.copyWith(proteinTarget: newProtein);
      }
    }

    // Derive macros
    final Map<String, double> macros;
    if (settings.calculationMode == MacroCalculationMode.proteinFat) {
      macros = GoalLogicService.calculateMacrosFromProteinFat(
        targetCalories: targetCalories,
        proteinGrams: settings.proteinTarget,
        fatGrams: settings.fatTarget,
      );
    } else {
      macros = GoalLogicService.calculateMacrosFromProteinCarbs(
        targetCalories: targetCalories,
        proteinGrams: settings.proteinTarget,
        carbGrams: settings.carbTarget,
      );
    }

    final computedGoals = MacroGoals(
      calories: macros['calories']!,
      protein: macros['protein']!,
      fat: macros['fat']!,
      carbs: macros['carbs']!,
      fiber: settings.fiberTarget,
    );

    debugPrint(
      'Calculated goals: calories=${computedGoals.calories}, protein=${computedGoals.protein}, fat=${computedGoals.fat}, carbs=${computedGoals.carbs}, fiber=${computedGoals.fiber}',
    );

    return TargetRecalcResult(settings: settings, goals: computedGoals);
  }

  ///// Calculates the next Monday from a given date.
  //DateTime _getNextMonday(DateTime fromDate) {
  //  int daysUntilMonday = (DateTime.monday - fromDate.weekday + 7) % 7;
  //  if (daysUntilMonday == 0) {
  //    daysUntilMonday = 7; // If today is Monday, next Monday is 7 days away
  //  }
  //  return DateTime(
  //    fromDate.year,
  //    fromDate.month,
  //    fromDate.day,
  //  ).add(Duration(days: daysUntilMonday));
  //}
}
