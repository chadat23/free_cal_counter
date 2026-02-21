import 'package:flutter/material.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/utils/math_evaluator.dart';
import 'package:meal_of_record/widgets/math_input_bar.dart';
import 'package:meal_of_record/widgets/screen_background.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _caloriesController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _caloriesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasOperator {
    final text = _caloriesController.text;
    // Check for operators that aren't just a leading negative sign
    final withoutLeadingMinus = text.startsWith('-') ? text.substring(1) : text;
    return withoutLeadingMinus.contains(RegExp(r'[+\-*/]'));
  }

  double? get _previewValue {
    final text = _caloriesController.text.trim();
    if (text.isEmpty || !_hasOperator) return null;
    final result = MathEvaluator.evaluate(text);
    if (result == null || result.isInfinite || result.isNaN) return null;
    return result;
  }

  String _formatResult(double val) {
    if (val == 0) return '0';
    if (val < 1) return val.toStringAsFixed(1);
    return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  Future<void> _submit() async {
    final text = _caloriesController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Required');
      return;
    }

    double? calories = double.tryParse(text);
    calories ??= MathEvaluator.evaluate(text);

    if (calories == null || calories.isInfinite || calories.isNaN) {
      setState(() => _error = 'Invalid expression');
      return;
    }
    if (calories <= 0) {
      setState(() => _error = 'Enter a positive number');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final quickAddFood =
          await DatabaseService.instance.getSystemQuickAddFood();

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

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final showMathBar = _hasFocus && keyboardHeight > 0;
    final preview = _previewValue;

    return ScreenBackground(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Quick Add')),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              32,
              24,
              showMathBar ? 48 + keyboardHeight : keyboardHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _caloriesController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    suffixText: 'cal',
                    errorText: _error,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                ),
                if (_hasOperator && preview != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '= ${_formatResult(preview)} cal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                const SizedBox(height: 24),
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
            ),
          ),
          if (showMathBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardHeight,
              child: MathInputBar(controller: _caloriesController),
            ),
        ],
      ),
    );
  }
}
