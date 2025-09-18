import 'food_portion.dart';

class Food {
  final int id;
  final String source;
  final String externalId;
  final String description;
  final double caloriesKcal; // per 100g baseline
  final double proteinG; // per 100g baseline
  final double fatG; // per 100g baseline
  final double carbsG; // per 100g baseline
  final bool isActive;
  final List<FoodPortion> portions;

  Food({
    required this.id,
    required this.source,
    required this.externalId,
    required this.description,
    required this.caloriesKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    this.isActive = true,
    this.portions = const [],
  });

  factory Food.fromMap(Map<String, dynamic> map, {List<FoodPortion> portions = const []}) {
    return Food(
      id: map['id'] as int,
      source: map['source'] as String,
      externalId: map['external_id'] as String,
      description: map['description'] as String,
      caloriesKcal: (map['calories_kcal'] as num).toDouble(),
      proteinG: (map['protein_g'] as num).toDouble(),
      fatG: (map['fat_g'] as num).toDouble(),
      carbsG: (map['carbs_g'] as num).toDouble(),
      isActive: ((map['is_active'] as int?) ?? 1) == 1,
      portions: portions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'external_id': externalId,
      'description': description,
      'calories_kcal': caloriesKcal,
      'protein_g': proteinG,
      'fat_g': fatG,
      'carbs_g': carbsG,
      'is_active': isActive ? 1 : 0,
    };
  }

  String get displayName => description;
  
  String get caloriesText100g => '${caloriesKcal.toStringAsFixed(0)} kcal / 100g';
  
  double caloriesForGrams(double grams) => caloriesKcal * (grams / 100.0);
  double proteinForGrams(double grams) => proteinG * (grams / 100.0);
  double fatForGrams(double grams) => fatG * (grams / 100.0);
  double carbsForGrams(double grams) => carbsG * (grams / 100.0);

  String nutritionSummaryForGrams(double grams) {
    return '${caloriesForGrams(grams).round()} kcal • '
           '${proteinForGrams(grams).toStringAsFixed(1)}g P • '
           '${fatForGrams(grams).toStringAsFixed(1)}g F • '
           '${carbsForGrams(grams).toStringAsFixed(1)}g C';
  }

  @override
  String toString() {
    return 'Food(id: $id, description: $description, kcal/100g: $caloriesKcal)';
  }
}

