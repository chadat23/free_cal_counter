import 'package:flutter/material.dart';
import 'package:meal_of_record/models/meal.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/widgets/slidable_portion_widget.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:meal_of_record/screens/meal_portion_screen.dart';
import 'package:meal_of_record/models/logged_portion.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/services/database_service.dart';

class MealWidget extends StatelessWidget {
  final Meal meal;
  final Function(LoggedPortion, FoodPortion)? onFoodUpdated;
  final Function(LoggedPortion)? onFoodDeleted;
  final VoidCallback? onBackgroundTap;

  const MealWidget({
    super.key,
    required this.meal,
    this.onFoodUpdated,
    this.onFoodDeleted,
    this.onBackgroundTap,
  });

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onBackgroundTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealPortionScreen(meal: meal),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.jm().format(meal.timestamp),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.end,
                      children: [
                        Text('🔥${meal.totalCalories.toInt()}'),
                        Text('P: ${meal.totalProtein.toStringAsFixed(0)}'),
                        Text('F: ${meal.totalFat.toStringAsFixed(0)}'),
                        Text('C: ${meal.totalCarbs.toStringAsFixed(0)}'),
                        Text('Fb: ${meal.totalFiber.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ...meal.loggedPortion.asMap().entries.map((entry) {
                final index = entry.key;
                final loggedFood = entry.value;
                final isSelected =
                    loggedFood.id != null &&
                    logProvider.isPortionSelected(loggedFood.id!);

                return Column(
                  children: [
                    SlidablePortionWidget(
                      key: loggedFood.id != null
                          ? ValueKey(loggedFood.id)
                          : null,
                      serving: loggedFood.portion,
                      isSelected: isSelected,
                      onTap: () {
                        if (loggedFood.id != null) {
                          logProvider.togglePortionSelection(loggedFood.id!);
                        }
                      },
                      onLongPress: () {
                        if (loggedFood.id != null) {
                          logProvider.selectPortion(loggedFood.id!);
                        }
                      },
                      onDelete: () {
                        if (onFoodDeleted != null) {
                          onFoodDeleted!(loggedFood);
                        }
                      },
                      onEdit: () async {
                        // Reload food/recipe from database to get latest changes (e.g., image, macros)
                        final foodId = loggedFood.portion.food.id;
                        final source = loggedFood.portion.food.source;

                        final Food? reloadedFood;
                        if (source == 'recipe') {
                          final recipe = await DatabaseService.instance
                              .getRecipeById(foodId);
                          reloadedFood = recipe.toFood();
                        } else {
                          reloadedFood = await DatabaseService.instance
                              .getFoodById(foodId, 'live');
                        }

                        if (reloadedFood == null) {
                          // Fallback to cached food if reload fails
                          return;
                        }

                        final foodToEdit = reloadedFood;

                        if (!context.mounted) return;

                        final unit = foodToEdit.servings.firstWhere(
                          (s) => s.unit == loggedFood.portion.unit,
                          orElse: () => foodToEdit.servings.first,
                        );
                        final result = await Navigator.push<FoodPortion>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuantityEditScreen(
                              config: QuantityEditConfig(
                                context: QuantityEditContext.day,
                                food: foodToEdit,
                                isUpdate: true,
                                initialUnit: unit.unit,
                                initialQuantity: unit.quantityFromGrams(
                                  loggedFood.portion.grams,
                                ),
                                originalGrams: loggedFood.portion.grams,
                              ),
                            ),
                          ),
                        );
                        if (result != null && context.mounted) {
                          if (onFoodUpdated != null) {
                            onFoodUpdated!(loggedFood, result);
                          }
                        }
                      },
                    ),
                    if (index < meal.loggedPortion.length - 1)
                      Divider(
                        color: Theme.of(
                          context,
                        ).cardColor.withAlpha((255 * 0.7).round()),
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
