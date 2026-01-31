import 'package:flutter/material.dart';

import 'package:free_cal_counter1/providers/log_provider.dart';
import 'package:free_cal_counter1/providers/navigation_provider.dart';
import 'package:free_cal_counter1/widgets/discard_dialog.dart';
import 'package:free_cal_counter1/widgets/search_ribbon.dart';
import 'package:free_cal_counter1/widgets/log_queue_top_ribbon.dart';
import 'package:free_cal_counter1/widgets/slidable_portion_widget.dart';
import 'package:free_cal_counter1/models/food_portion.dart';
import 'package:free_cal_counter1/models/quantity_edit_config.dart';
import 'package:free_cal_counter1/screens/quantity_edit_screen.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:provider/provider.dart';

class LogQueueScreen extends StatelessWidget {
  const LogQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 180, // Increased to accommodate more chart rows
            automaticallyImplyLeading: false,
            title: LogQueueTopRibbon(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  if (logProvider.logQueue.isNotEmpty) {
                    final discard = await showDiscardDialog(context);
                    if (discard == true) {
                      logProvider.clearQueue();
                      Future.microtask(() {
                        if (context.mounted) {
                          final navProvider = Provider.of<NavigationProvider>(
                            context,
                            listen: false,
                          );
                          navProvider.changeTab(0);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      });
                    }
                  } else {
                    Future.microtask(() {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    });
                  }
                },
              ),
              arrowDirection: Icons.arrow_drop_up,
              onArrowPressed: () {
                Navigator.pop(context);
              },
              logProvider: logProvider,
            ),
          ),
          body: ListView.builder(
            itemCount: logProvider.logQueue.length,
            itemBuilder: (context, index) {
              final foodServing = logProvider.logQueue[index];
              return SlidablePortionWidget(
                serving: foodServing,
                onDelete: () {
                  logProvider.removeFoodFromQueue(foodServing);
                },
                onEdit: () async {
                  // Reload food from database to get latest changes (e.g., image)
                  final foodId = foodServing.food.id;
                  final reloadedFood = await DatabaseService.instance
                      .getFoodById(foodId, 'live');

                  // Fallback to cached food if reload fails (e.g., food not yet logged)
                  final foodToUse = reloadedFood ?? foodServing.food;

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final unit = foodToUse.servings.firstWhere(
                          (s) => s.unit == foodServing.unit,
                          orElse: () => foodToUse.servings.first,
                        );
                        return QuantityEditScreen(
                          config: QuantityEditConfig(
                            context: QuantityEditContext.day,
                            food: foodToUse,
                            isUpdate: true,
                            initialUnit: unit.unit,
                            initialQuantity: unit.quantityFromGrams(
                              foodServing.grams,
                            ),
                            originalGrams: foodServing.grams,
                            onSave: (grams, unitName, updatedFood) {
                              logProvider.updateFoodInQueue(
                                index,
                                FoodPortion(
                                  food: updatedFood ?? foodToUse,
                                  grams: grams,
                                  unit: unitName,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: const SearchRibbon(),
        );
      },
    );
  }
}
