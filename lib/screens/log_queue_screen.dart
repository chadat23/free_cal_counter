import 'package:flutter/material.dart';

import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/widgets/discard_dialog.dart';
import 'package:meal_of_record/widgets/search_ribbon.dart';
import 'package:meal_of_record/widgets/log_queue_top_ribbon.dart';
import 'package:meal_of_record/widgets/slidable_portion_widget.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:provider/provider.dart';

class LogQueueScreen extends StatefulWidget {
  const LogQueueScreen({super.key});

  @override
  State<LogQueueScreen> createState() => _LogQueueScreenState();
}

class _LogQueueScreenState extends State<LogQueueScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure logged portions are fresh so bar charts show correct values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<LogProvider>(context, listen: false)
            .loadLoggedPortionsForDate(DateTime.now())
            .catchError((_) {}); // DB may not be ready in tests
      }
    });
  }

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
                  final foodToUse = foodServing.food;
                  final unit = foodToUse.servings.firstWhere(
                    (s) => s.unit == foodServing.unit,
                    orElse: () => foodToUse.servings.first,
                  );
                  final result = await Navigator.push<FoodPortion>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuantityEditScreen(
                        config: QuantityEditConfig(
                          context: QuantityEditContext.day,
                          food: foodToUse,
                          isUpdate: true,
                          initialUnit: unit.unit,
                          initialQuantity: unit.quantityFromGrams(
                            foodServing.grams,
                          ),
                          originalGrams: foodServing.grams,
                        ),
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    logProvider.updateFoodInQueue(index, result);
                  }
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
