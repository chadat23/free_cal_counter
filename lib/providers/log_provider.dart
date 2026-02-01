import 'package:flutter/material.dart';
import 'package:free_cal_counter1/models/food_portion.dart' as model;
import 'package:free_cal_counter1/models/logged_portion.dart' as model;
import 'package:free_cal_counter1/models/recipe.dart' as model;
import 'package:free_cal_counter1/models/food.dart' as model_food;
import 'package:free_cal_counter1/services/emoji_service.dart';
import 'package:free_cal_counter1/models/daily_macro_stats.dart';
import 'package:free_cal_counter1/services/database_service.dart';

class LogProvider extends ChangeNotifier {
  // State for macros
  double _loggedCalories = 0.0;
  double _loggedProtein = 0.0;
  double _loggedFat = 0.0;
  double _loggedCarbs = 0.0;
  double _loggedFiber = 0.0;

  double _queuedCalories = 0.0;
  double _queuedProtein = 0.0;
  double _queuedFat = 0.0;
  double _queuedCarbs = 0.0;
  double _queuedFiber = 0.0;

  final double _dailyTargetCalories = 2000.0;
  final double _dailyTargetProtein = 150.0;
  final double _dailyTargetFat = 70.0;
  final double _dailyTargetCarbs = 250.0;
  final double _dailyTargetFiber = 30.0;

  final List<model.FoodPortion> _logQueue = [];
  List<model.LoggedPortion> _loggedPortion = [];
  bool _isFasted = false;

  // Multiselect state
  final Set<int> _selectedPortionIds = {};

  // Getters
  double get loggedCalories => _loggedCalories;
  double get queuedCalories => _queuedCalories;
  double get queuedProtein => _queuedProtein;
  double get queuedFat => _queuedFat;
  double get queuedCarbs => _queuedCarbs;
  double get queuedFiber => _queuedFiber;

  double get totalCalories => _loggedCalories + _queuedCalories;
  double get totalProtein => _loggedProtein + _queuedProtein;
  double get totalFat => _loggedFat + _queuedFat;
  double get totalCarbs => _loggedCarbs + _queuedCarbs;
  double get totalFiber => _loggedFiber + _queuedFiber;

  double get dailyTargetCalories => _dailyTargetCalories;
  double get dailyTargetProtein => _dailyTargetProtein;
  double get dailyTargetFat => _dailyTargetFat;
  double get dailyTargetCarbs => _dailyTargetCarbs;
  double get dailyTargetFiber => _dailyTargetFiber;

  List<model.FoodPortion> get logQueue => _logQueue;
  List<model.LoggedPortion> get loggedPortion => _loggedPortion;
  bool get isFasted => _isFasted;
  Set<int> get selectedPortionIds => _selectedPortionIds;
  bool get hasSelectedPortions => _selectedPortionIds.isNotEmpty;
  int get selectedPortionCount => _selectedPortionIds.length;

  // Queue Operations
  void addFoodToQueue(model.FoodPortion serving) {
    _logQueue.add(serving);
    _recalculateQueuedMacros();
    notifyListeners();
  }

  void addRecipeToQueue(model.Recipe recipe, {double quantity = 1.0}) {
    if (recipe.isTemplate) {
      dumpRecipeToQueue(recipe, quantity: quantity);
    } else {
      // Not a template: Add as a single item (frozen)
      final food = recipe.toFood();
      // Ensure emoji is set correctly for the recipe food
      final enrichedFood = food.copyWith(
        emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
            ? emojiForFoodName(food.name)
            : food.emoji,
      );
      addFoodToQueue(
        model.FoodPortion(
          food: enrichedFood,
          grams: recipe.gramsPerPortion * quantity,
          unit: recipe.portionName,
        ),
      );
    }
  }

  void dumpRecipeToQueue(model.Recipe recipe, {double quantity = 1.0}) {
    // Force decomposition: Add all items recursively
    for (final item in recipe.items) {
      if (item.isFood) {
        final food = item.food!;
        // Ensure emoji is set if missing
        final enrichedFood = food.copyWith(
          emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
              ? emojiForFoodName(food.name)
              : food.emoji,
        );
        addFoodToQueue(
          model.FoodPortion(
            food: enrichedFood,
            grams: item.grams * quantity,
            unit: item.unit,
          ),
        );
      } else if (item.isRecipe) {
        // Recursive decomposition
        dumpRecipeToQueue(
          item.recipe!,
          quantity: (item.grams / item.recipe!.gramsPerPortion) * quantity,
        );
      }
    }
  }

  void updateFoodInQueue(int index, model.FoodPortion newPortion) {
    if (index >= 0 && index < _logQueue.length) {
      _logQueue[index] = newPortion;
      _recalculateQueuedMacros();
      notifyListeners();
    }
  }

  void removeFoodFromQueue(model.FoodPortion serving) {
    _logQueue.remove(serving);
    _recalculateQueuedMacros();
    notifyListeners();
  }

  void clearQueue() {
    _logQueue.clear();
    _recalculateQueuedMacros();
    notifyListeners();
  }

  /// Refreshes food references in the log queue after a food is edited
  /// This ensures that when a food's name, image, or other metadata is updated,
  /// the log queue reflects the latest version of the food.
  Future<void> refreshFoodInQueue(
    int foodId,
    model_food.Food updatedFood,
  ) async {
    bool changed = false;
    for (int i = 0; i < _logQueue.length; i++) {
      final portion = _logQueue[i];
      // Match by food ID or by barcode (for OFF foods)
      if (portion.food.id == foodId ||
          (portion.food.source == 'off' &&
              portion.food.sourceBarcode == updatedFood.sourceBarcode)) {
        // Update the portion with the new food reference
        _logQueue[i] = model.FoodPortion(
          food: updatedFood,
          grams: portion.grams,
          unit: portion.unit,
        );
        changed = true;
      }
    }

    if (changed) {
      _recalculateQueuedMacros();
      notifyListeners();
    }
  }

  Future<void> logQueueToDatabase() async {
    if (_logQueue.isEmpty) return;

    await DatabaseService.instance.logPortions(_logQueue, DateTime.now());
    clearQueue();
    await loadLoggedPortionsForDate(DateTime.now());
  }

  // Database Operations
  Future<void> loadLoggedPortionsForDate(DateTime date) async {
    final portions = await DatabaseService.instance.getLoggedPortionsForDate(
      date,
    );

    // Enrich with smart emojis
    _loggedPortion = portions.map((p) {
      final food = p.portion.food;
      if (food.emoji == null || food.emoji == '🍴' || food.emoji == '') {
        final enrichedFood = food.copyWith(emoji: emojiForFoodName(food.name));
        return model.LoggedPortion(
          id: p.id,
          timestamp: p.timestamp,
          portion: model.FoodPortion(
            food: enrichedFood,
            grams: p.portion.grams,
            unit: p.portion.unit,
          ),
        );
      }
      return p;
    }).toList();

    _isFasted = await DatabaseService.instance.isFastedOnDate(date);
    _recalculateLoggedMacros();
    notifyListeners();
  }

  Future<void> toggleFasted(DateTime date) async {
    await DatabaseService.instance.toggleFasted(date);
    await loadLoggedPortionsForDate(date);
  }

  Future<void> deleteLoggedPortion(model.LoggedPortion food) async {
    if (food.id == null) return;

    await DatabaseService.instance.deleteLoggedPortion(food.id!);

    _loggedPortion.removeWhere((item) => item.id == food.id);
    _recalculateLoggedMacros();
    notifyListeners();
  }

  Future<void> updateLoggedPortion(
    model.LoggedPortion oldLoggedPortion,
    model.FoodPortion newPortion,
  ) async {
    if (oldLoggedPortion.id == null) return;

    await DatabaseService.instance.updateLoggedPortion(
      oldLoggedPortion.id!,
      newPortion,
    );

    // Reload the logged portions for the current date
    final date = oldLoggedPortion.timestamp;
    await loadLoggedPortionsForDate(date);
  }

  // Internal Calculation Logic
  void _recalculateQueuedMacros() {
    _queuedCalories = 0.0;
    _queuedProtein = 0.0;
    _queuedFat = 0.0;
    _queuedCarbs = 0.0;
    _queuedFiber = 0.0;

    for (var serving in _logQueue) {
      final food = serving.food;
      _queuedCalories += food.calories * serving.grams;
      _queuedProtein += food.protein * serving.grams;
      _queuedFat += food.fat * serving.grams;
      _queuedCarbs += food.carbs * serving.grams;
      _queuedFiber += food.fiber * serving.grams;
    }
  }

  void _recalculateLoggedMacros() {
    _loggedCalories = 0.0;
    _loggedProtein = 0.0;
    _loggedFat = 0.0;
    _loggedCarbs = 0.0;
    _loggedFiber = 0.0;

    for (var item in _loggedPortion) {
      final food = item.portion.food;
      _loggedCalories += food.calories * item.portion.grams;
      _loggedProtein += food.protein * item.portion.grams;
      _loggedFat += food.fat * item.portion.grams;
      _loggedCarbs += food.carbs * item.portion.grams;
      _loggedFiber += food.fiber * item.portion.grams;
    }
  }

  Future<List<DailyMacroStats>> getDailyMacroStats(
    DateTime start,
    DateTime end,
  ) async {
    final dtos = await DatabaseService.instance.getLoggedMacrosForDateRange(
      start,
      end,
    );
    return DailyMacroStats.fromDTOS(dtos, start, end);
  }

  Future<DailyMacroStats> getTodayStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stats = await getDailyMacroStats(today, today);
    return stats.first;
  }

  // Multiselect operations
  void togglePortionSelection(int portionId) {
    if (_selectedPortionIds.contains(portionId)) {
      _selectedPortionIds.remove(portionId);
    } else {
      _selectedPortionIds.add(portionId);
    }
    notifyListeners();
  }

  void selectPortion(int portionId) {
    _selectedPortionIds.add(portionId);
    notifyListeners();
  }

  void deselectPortion(int portionId) {
    _selectedPortionIds.remove(portionId);
    notifyListeners();
  }

  void clearSelection() {
    _selectedPortionIds.clear();
    notifyListeners();
  }

  bool isPortionSelected(int portionId) {
    return _selectedPortionIds.contains(portionId);
  }

  // Copy selected portions to log queue
  void copySelectedPortionsToQueue() {
    if (_selectedPortionIds.isEmpty) return;

    // Find selected portions and copy their FoodPortion to the queue
    for (final loggedPortion in _loggedPortion) {
      if (loggedPortion.id != null &&
          _selectedPortionIds.contains(loggedPortion.id!)) {
        addFoodToQueue(loggedPortion.portion);
      }
    }

    // Clear selection after copying
    clearSelection();
  }

  // Move selected portions to a new date and time
  Future<void> moveSelectedPortions(DateTime newTimestamp) async {
    if (_selectedPortionIds.isEmpty) return;

    // Collect the IDs of selected portions
    final selectedIds = <int>[];
    for (final loggedPortion in _loggedPortion) {
      if (loggedPortion.id != null &&
          _selectedPortionIds.contains(loggedPortion.id!)) {
        selectedIds.add(loggedPortion.id!);
      }
    }

    // Update timestamps in the database
    await DatabaseService.instance.updateLoggedPortionsTimestamp(
      selectedIds,
      newTimestamp,
    );

    // Clear selection after moving
    clearSelection();

    // Reload the logged portions for the current date
    // Note: The caller should handle navigation to the new date
  }

  /// Deletes all currently selected portions from the database
  ///
  /// This method:
  /// 1. Collects the IDs of all selected portions
  /// 2. Deletes them from the database in a batch operation
  /// 3. Removes them from the local state
  /// 4. Recalculates the logged macros
  /// 5. Clears the selection
  ///
  /// The user remains on the current date (no navigation occurs).
  Future<void> deleteSelectedPortions() async {
    if (_selectedPortionIds.isEmpty) return;

    // Collect the IDs of selected portions
    final selectedIds = <int>[];
    for (final loggedPortion in _loggedPortion) {
      if (loggedPortion.id != null &&
          _selectedPortionIds.contains(loggedPortion.id!)) {
        selectedIds.add(loggedPortion.id!);
      }
    }

    // Delete from database
    await DatabaseService.instance.deleteLoggedPortions(selectedIds);

    // Remove from local state
    _loggedPortion.removeWhere(
      (item) => item.id != null && selectedIds.contains(item.id!),
    );

    // Recalculate macros
    _recalculateLoggedMacros();

    // Clear selection
    clearSelection();
  }
}
