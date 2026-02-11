import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';

typedef SearchSaveCallback = void Function(FoodPortion portion);

class SearchConfig {
  final QuantityEditContext context;
  final String title;
  final bool showQueueStats;
  final SearchSaveCallback? onSaveOverride;

  const SearchConfig({
    required this.context,
    required this.title,
    this.showQueueStats = true,
    this.onSaveOverride,
  });
}
