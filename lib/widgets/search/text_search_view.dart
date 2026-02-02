import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:free_cal_counter1/providers/search_provider.dart';
import 'package:free_cal_counter1/models/food_portion.dart' as model_portion;
import 'package:free_cal_counter1/models/quantity_edit_config.dart';
import 'package:free_cal_counter1/providers/log_provider.dart';
import 'package:free_cal_counter1/screens/quantity_edit_screen.dart';
import 'package:free_cal_counter1/models/search_config.dart';
import 'package:free_cal_counter1/widgets/search/slidable_search_result.dart';
import 'package:free_cal_counter1/models/food.dart' as model_food;
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/screens/food_edit_screen.dart';

class TextSearchView extends StatelessWidget {
  final SearchConfig config;
  const TextSearchView({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.errorMessage != null) {
          return Center(
            child: Text(
              searchProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (searchProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchProvider.searchResults.isEmpty) {
          return const Center(child: Text('Search for a food to begin'));
        }

        return ListView.builder(
          itemCount: searchProvider.searchResults.length,
          itemBuilder: (context, index) {
            final food = searchProvider.searchResults[index];
            final logProvider = Provider.of<LogProvider>(context);
            final int existingIndex = logProvider.logQueue.indexWhere(
              (p) =>
                  (p.food.id != 0 &&
                      p.food.id == food.id &&
                      p.food.source == food.source) ||
                  (food.id == 0 &&
                      food.source == 'off' &&
                      p.food.source == 'off' &&
                      p.food.sourceBarcode == food.sourceBarcode),
            );
            final isUpdate = existingIndex != -1;

            return SlidableSearchResult(
              key: ValueKey('${food.id}_${food.source}'),
              food: food,
              isUpdate: isUpdate,
              note: food.usageNote,
              onAdd: (selectedUnit) async {
                if (isUpdate && config.onSaveOverride == null) {
                  // If already in queue and no override, edit existing
                  final existingPortion = logProvider.logQueue[existingIndex];
                  // Reload food from database to get latest changes (e.g., image)
                  final reloadedFood = await DatabaseService.instance
                      .getFoodById(food.id, 'live');

                  if (reloadedFood == null) {
                    // Fallback to cached food if reload fails
                    return;
                  }

                  if (!context.mounted) return;

                  final unitServing = reloadedFood.servings.firstWhere(
                    (s) => s.unit == existingPortion.unit,
                    orElse: () => reloadedFood.servings.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuantityEditScreen(
                        config: QuantityEditConfig(
                          context: config.context,
                          food: reloadedFood,
                          isUpdate: true,
                          initialUnit: existingPortion.unit,
                          initialQuantity: unitServing.quantityFromGrams(
                            existingPortion.grams,
                          ),
                          originalGrams: existingPortion.grams,
                          onSave: (grams, unit, updatedFood) {
                            Provider.of<LogProvider>(
                              context,
                              listen: false,
                            ).updateFoodInQueue(
                              existingIndex,
                              model_portion.FoodPortion(
                                food: updatedFood ?? reloadedFood,
                                grams: grams,
                                unit: unit,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  );
                  return;
                }

                final portion = model_portion.FoodPortion(
                  food: food,
                  grams: selectedUnit.grams,
                  unit: selectedUnit.unit,
                );
                if (config.onSaveOverride != null) {
                  config.onSaveOverride!(portion);
                } else {
                  Provider.of<LogProvider>(
                    context,
                    listen: false,
                  ).addFoodToQueue(portion);
                }
              },
              onTap: (selectedUnit) {
                final existingPortion = isUpdate
                    ? logProvider.logQueue[existingIndex]
                    : null;
                final unitServing = existingPortion != null
                    ? food.servings.firstWhere(
                        (s) => s.unit == existingPortion.unit,
                        orElse: () => food.servings.first,
                      )
                    : null;

                final initialUnit = existingPortion != null
                    ? existingPortion.unit
                    : selectedUnit.unit;
                // Use quantity from dropdown (which now includes last logged info)
                final initialQuantity =
                    existingPortion != null && unitServing != null
                    ? unitServing.quantityFromGrams(existingPortion.grams)
                    : selectedUnit.quantity;
                final originalGrams = existingPortion != null
                    ? existingPortion.grams
                    : 0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuantityEditScreen(
                      config: QuantityEditConfig(
                        context: config.context,
                        food: food,
                        isUpdate: isUpdate,
                        initialUnit: initialUnit,
                        initialQuantity: initialQuantity,
                        originalGrams: originalGrams,
                        onSave: (grams, unit, updatedFood) {
                          final portion = model_portion.FoodPortion(
                            food: updatedFood ?? food,
                            grams: grams,
                            unit: unit,
                          );
                          if (config.onSaveOverride != null) {
                            // First pop closes QuantityEditScreen
                            Navigator.pop(context);
                            // Second pop closes SearchScreen via onSaveOverride
                            config.onSaveOverride!(portion);
                          } else {
                            if (isUpdate) {
                              Provider.of<LogProvider>(
                                context,
                                listen: false,
                              ).updateFoodInQueue(existingIndex, portion);
                            } else {
                              Provider.of<LogProvider>(
                                context,
                                listen: false,
                              ).addFoodToQueue(portion);
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              onEdit: () async {
                try {
                  final result = await Navigator.push<FoodEditResult>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodEditScreen(
                        originalFood: food,
                        contextType: FoodEditContext.search,
                        isCopy: false,
                      ),
                    ),
                  );

                  if (result != null && context.mounted) {
                    // Refresh search results
                    await searchProvider.textSearch(
                      searchProvider.currentQuery,
                    );

                    if (result.useImmediately) {
                      final newFood = await DatabaseService.instance
                          .getFoodById(result.foodId, 'live');
                      if (context.mounted && newFood != null) {
                        _openQuantityEdit(
                          context,
                          newFood,
                          config,
                          isUpdate: false,
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Food updated successfully'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to edit food: $e')),
                    );
                  }
                }
              },
              onCopy: () async {
                try {
                  final result = await Navigator.push<FoodEditResult>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodEditScreen(
                        originalFood: food,
                        contextType: FoodEditContext.search,
                        isCopy: true,
                      ),
                    ),
                  );

                  if (result != null && context.mounted) {
                    // Refresh search results
                    await searchProvider.textSearch(
                      searchProvider.currentQuery,
                    );

                    if (result.useImmediately) {
                      final newFood = await DatabaseService.instance
                          .getFoodById(result.foodId, 'live');
                      if (context.mounted && newFood != null) {
                        _openQuantityEdit(
                          context,
                          newFood,
                          config,
                          isUpdate: false,
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Food copied successfully'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to copy food: $e')),
                    );
                  }
                }
              },
              onDelete: () async {
                try {
                  await DatabaseService.instance.deleteFood(
                    food.id,
                    food.source,
                  );

                  // Refresh search results
                  await searchProvider.textSearch(searchProvider.currentQuery);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Food deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete food: $e')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _openQuantityEdit(
    BuildContext context,
    model_food.Food food,
    SearchConfig config, {
    bool isUpdate = false,
    int? existingIndex,
    model_portion.FoodPortion? existingPortion,
  }) {
    final unitServing = existingPortion != null
        ? food.servings.firstWhere(
            (s) => s.unit == existingPortion.unit,
            orElse: () => food.servings.first,
          )
        : food.servings.first; // Default to first serving for new items

    final initialUnit = existingPortion?.unit ?? unitServing.unit;

    // For new items, use serving quantity (which includes last logged info if available)
    final initialQuantity = existingPortion != null
        ? unitServing.quantityFromGrams(existingPortion.grams)
        : unitServing.quantity;

    final originalGrams = existingPortion?.grams ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuantityEditScreen(
          config: QuantityEditConfig(
            context: config.context,
            food: food,
            isUpdate: isUpdate,
            initialUnit: initialUnit,
            initialQuantity: initialQuantity,
            originalGrams: originalGrams,
            onSave: (grams, unit, updatedFood) {
              final portion = model_portion.FoodPortion(
                food: updatedFood ?? food,
                grams: grams,
                unit: unit,
              );
              if (config.onSaveOverride != null) {
                // First pop closes QuantityEditScreen
                Navigator.pop(context);
                // Second pop closes SearchScreen via onSaveOverride
                config.onSaveOverride!(portion);
              } else {
                if (isUpdate && existingIndex != null) {
                  Provider.of<LogProvider>(
                    context,
                    listen: false,
                  ).updateFoodInQueue(existingIndex, portion);
                } else {
                  Provider.of<LogProvider>(
                    context,
                    listen: false,
                  ).addFoodToQueue(portion);
                }
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
