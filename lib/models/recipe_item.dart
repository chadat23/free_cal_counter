import 'package:free_cal_counter1/models/food.dart';
import 'package:free_cal_counter1/models/recipe.dart';

class RecipeItem {
  final int id;
  final Food? food;
  final Recipe? recipe;
  final double grams;
  final String unit;
  final int position;

  RecipeItem({
    required this.id,
    this.food,
    this.recipe,
    required this.grams,
    required this.unit,
    this.position = 0,
  }) : assert(
         food != null || recipe != null,
         'Either food or recipe must be provided',
       );

  RecipeItem copyWith({
    int? id,
    Food? food,
    Recipe? recipe,
    double? grams,
    String? unit,
    int? position,
  }) {
    return RecipeItem(
      id: id ?? this.id,
      food: food ?? this.food,
      recipe: recipe ?? this.recipe,
      grams: grams ?? this.grams,
      unit: unit ?? this.unit,
      position: position ?? this.position,
    );
  }

  bool get isFood => food != null;
  bool get isRecipe => recipe != null;

  String get name => isFood ? food!.name : recipe!.name;

  double get calories => isFood ? food!.calories : recipe!.caloriesPerGram;
  double get protein => isFood ? food!.protein : recipe!.proteinPerGram;
  double get fat => isFood ? food!.fat : recipe!.fatPerGram;
  double get carbs => isFood ? food!.carbs : recipe!.carbsPerGram;
  double get fiber => isFood ? food!.fiber : recipe!.fiberPerGram;

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      id: json['id'] as int,
      food: json['food'] != null
          ? Food.fromJson(json['food'] as Map<String, dynamic>)
          : null,
      recipe: json['recipe'] != null
          ? Recipe.fromJson(json['recipe'] as Map<String, dynamic>)
          : null,
      grams: (json['grams'] as num).toDouble(),
      unit: json['unit'] as String,
      position: (json['position'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food?.toJson(),
      'recipe': recipe?.toJson(),
      'grams': grams,
      'unit': unit,
      'position': position,
    };
  }
}
