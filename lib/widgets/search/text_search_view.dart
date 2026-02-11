import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/models/food_portion.dart' as model_portion;
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:meal_of_record/models/search_config.dart';
import 'package:meal_of_record/widgets/search/slidable_search_result.dart';
import 'package:meal_of_record/models/food.dart' as model_food;
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/screens/food_edit_screen.dart';

class TextSearchView extends StatefulWidget {
  final SearchConfig config;
  const TextSearchView({super.key, required this.config});

  @override
  State<TextSearchView> createState() => _TextSearchViewState();
}

class _TextSearchViewState extends State<TextSearchView> {
  String? _handledBarcode;

  SearchConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        // Handle barcode search results
        if (searchProvider.isBarcodeSearch &&
            !searchProvider.isLoading &&
            searchProvider.lastScannedBarcode != _handledBarcode) {
          // Schedule the handling for after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleBarcodeSearchResult(context, searchProvider);
          });
        }

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
          // Show different message for barcode search with no results
          if (searchProvider.isBarcodeSearch) {
            return const Center(child: Text('No food found for this barcode'));
          }
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
                  searchProvider.clearSearch();
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
                              searchProvider.clearSearch();
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

  Future<void> _openQuantityEdit(
    BuildContext context,
    model_food.Food food,
    SearchConfig config,
  ) async {
    var initialUnit = food.servings.first.unit;
    var initialQuantity = food.servings.first.quantity;

    if (food.id != 0) {
      final lastInfo = await DatabaseService.instance.getLastLoggedInfo(food.id);
      if (lastInfo != null) {
        final serving = food.servings.where((s) => s.unit == lastInfo.unit).firstOrNull;
        if (serving != null) {
          initialUnit = serving.unit;
          initialQuantity = lastInfo.quantity;
        }
      }
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuantityEditScreen(
          config: QuantityEditConfig(
            context: config.context,
            food: food,
            initialUnit: initialUnit,
            initialQuantity: initialQuantity,
            onSave: (grams, unit, updatedFood) {
              final portion = model_portion.FoodPortion(
                food: updatedFood ?? food,
                grams: grams,
                unit: unit,
              );
              if (config.onSaveOverride != null) {
                Navigator.pop(context);
                config.onSaveOverride!(portion);
              } else {
                Provider.of<LogProvider>(
                  context,
                  listen: false,
                ).addFoodToQueue(portion);
                Provider.of<SearchProvider>(
                  context,
                  listen: false,
                ).clearSearch();
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleBarcodeSearchResult(
    BuildContext context,
    SearchProvider searchProvider,
  ) async {
    if (!mounted) return;

    final barcode = searchProvider.lastScannedBarcode;
    if (barcode == null) return;

    // Mark this barcode as handled
    setState(() {
      _handledBarcode = barcode;
    });

    final results = searchProvider.searchResults;

    if (results.isEmpty) {
      // Show "not found" dialog
      _showBarcodeNotFoundDialog(context, barcode, searchProvider);
    } else if (results.length == 1) {
      // Auto-navigate to quantity edit for single result
      final food = results.first;
      await _openQuantityEdit(context, food, config);
      // Clear barcode search state after navigation
      searchProvider.clearBarcodeSearchState();
    }
    // If multiple results, just show them in the list (already handled)
  }

  Future<void> _showBarcodeNotFoundDialog(
    BuildContext context,
    String barcode,
    SearchProvider searchProvider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No food was found for this barcode:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                barcode,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Would you like to create a new food with this barcode?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create New Food'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Navigate to food edit screen with barcode pre-populated
      final editResult = await Navigator.push<FoodEditResult>(
        context,
        MaterialPageRoute(
          builder: (context) => FoodEditScreen(
            originalFood: null,
            contextType: FoodEditContext.search,
            isCopy: false,
            initialBarcode: barcode,
          ),
        ),
      );

      if (editResult != null && mounted) {
        // If food was created and user wants to use it immediately
        if (editResult.useImmediately) {
          final newFood = await DatabaseService.instance
              .getFoodById(editResult.foodId, 'live');
          if (mounted && newFood != null) {
            _openQuantityEdit(
              context,
              newFood,
              config,
            );
          }
        }
      }
    }

    // Clear barcode search state
    searchProvider.clearBarcodeSearchState();
  }
}
