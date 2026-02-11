import 'package:flutter/material.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/services/database_service.dart';

/// A simplified Quick Add dialog that only asks for calories.
/// Uses a system "Quick Add" food where 1 gram = 1 calorie.
/// Returns a FoodPortion with grams equal to the entered calories.
class QuickAddDialog extends StatefulWidget {
  const QuickAddDialog({super.key});

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Add'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _caloriesController,
          decoration: const InputDecoration(
            labelText: 'Calories',
            suffixText: 'kcal',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required';
            final parsed = double.tryParse(val);
            if (parsed == null || parsed <= 0) return 'Enter a positive number';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final calories = double.parse(_caloriesController.text);
      final quickAddFood =
          await DatabaseService.instance.getSystemQuickAddFood();

      // Create portion where grams = calories (since food is 1 cal/gram)
      final portion = FoodPortion(
        food: quickAddFood,
        grams: calories,
        unit: 'g',
      );

      if (mounted) {
        Navigator.pop(context, portion);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
