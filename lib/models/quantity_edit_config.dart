import 'package:meal_of_record/models/food.dart';

enum QuantityEditContext { day, recipe }

class QuantityEditConfig {
  final QuantityEditContext context;
  final Food food;
  final double initialQuantity;
  final String initialUnit;
  final bool isUpdate;
  final double originalGrams;

  // Recipe specific
  final double? recipeServings;

  const QuantityEditConfig({
    required this.context,
    required this.food,
    this.initialQuantity = 0.0,
    required this.initialUnit,
    this.isUpdate = false,
    this.originalGrams = 0.0,
    this.recipeServings,
  });
}
