import 'package:meal_of_record/models/food_portion.dart';

class LoggedPortion {
  final int? id;
  final FoodPortion portion;
  final DateTime timestamp;

  LoggedPortion({this.id, required this.portion, required this.timestamp});
}
