import 'package:meal_of_record/models/food.dart';

enum QuantityEditContext { day, recipe }

typedef QuantitySaveCallback =
    void Function(double grams, String unit, Food? updatedFood);

class QuantityEditConfig {
  final QuantityEditContext context;
  final Food food;
  final double initialQuantity;
  final String initialUnit;
  final bool isUpdate;
  final double originalGrams;
  final QuantitySaveCallback onSave;

  // Recipe specific
  final double? recipeServings;

  const QuantityEditConfig({
    required this.context,
    required this.food,
    this.initialQuantity = 0.0,
    required this.initialUnit,
    this.isUpdate = false,
    this.originalGrams = 0.0,
    required this.onSave,
    this.recipeServings,
  });
}
