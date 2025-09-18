class FoodPortion {
  final int id;
  final int foodId;
  final double amount;
  final String unit;
  final double gramWeight;

  FoodPortion({
    required this.id,
    required this.foodId,
    required this.amount,
    required this.unit,
    required this.gramWeight,
  });

  factory FoodPortion.fromMap(Map<String, dynamic> map) {
    return FoodPortion(
      id: map['id'] as int,
      foodId: map['food_id'] as int,
      amount: (map['amount'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'serving',
      gramWeight: (map['gram_weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodId,
      'amount': amount,
      'unit': unit,
      'gram_weight': gramWeight,
    };
  }

  String get label {
    final normalizedUnit = unit.trim();
    if (amount == 1.0) return normalizedUnit;
    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} $normalizedUnit';
  }

  String get gramsLabel => '${gramWeight.toStringAsFixed(0)} g';
}
