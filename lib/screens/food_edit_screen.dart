import 'dart:io';
import 'package:flutter/material.dart';
import 'package:free_cal_counter1/models/food.dart';
import 'package:free_cal_counter1/models/food_serving.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/image_storage_service.dart';
import 'package:free_cal_counter1/widgets/screen_background.dart';
import 'package:free_cal_counter1/widgets/food_image_widget.dart';
import 'package:free_cal_counter1/widgets/serving_info_sheet.dart';
import 'package:free_cal_counter1/config/app_colors.dart';
import 'package:image_picker/image_picker.dart' as picker;

enum FoodEditContext {
  search, // From Search Screen (Edit/Copy) -> "Save", "Save & Use"
  editDefinition, // From Log/Receipt (Edit Definition) -> "Update" (same as Save)
}

class FoodEditResult {
  final int foodId;
  final bool useImmediately;

  FoodEditResult(this.foodId, {this.useImmediately = false});
}

class FoodEditScreen extends StatefulWidget {
  final Food? originalFood; // Null for new food
  final FoodEditContext contextType;
  final bool isCopy; // If true, originalFood is used as template but ID is 0

  const FoodEditScreen({
    super.key,
    this.originalFood,
    this.contextType = FoodEditContext.search,
    this.isCopy = false,
  });

  @override
  State<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends State<FoodEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  late TextEditingController _notesController;

  // Macro Controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fiberController = TextEditingController();

  // Primary serving controllers (for new foods / per-serving mode)
  final _primaryServingQuantityController =
      TextEditingController(text: '1');
  final _primaryServingGramsController = TextEditingController();
  String _primaryServingUnit = 'serving';
  bool _isCustomUnit = false;
  final _customUnitController = TextEditingController();

  List<FoodServing> _servings = [];
  bool _isPerServingMode = false;
  FoodServing? _selectedServingForMacroInput;
  String? _thumbnail;

  // Available units from database
  List<String> _availableUnits = [];

  @override
  void initState() {
    super.initState();
    _initData();
    _loadAvailableUnits();
  }

  Future<void> _loadAvailableUnits() async {
    final units = await DatabaseService.instance.getDistinctUnits();
    if (mounted) {
      setState(() {
        _availableUnits = units;
      });
    }
  }

  void _initData() {
    final food = widget.originalFood;
    _nameController = TextEditingController(text: food?.name ?? '');
    _emojiController = TextEditingController(text: food?.emoji ?? '🍎');
    _notesController = TextEditingController(text: food?.usageNote ?? '');
    _thumbnail = food?.thumbnail;

    if (food != null) {
      // Editing existing food
      _servings = List.from(food.servings);

      // Find first non-g serving to use as default
      final primaryServing = _servings.firstWhere(
        (s) => s.unit != 'g',
        orElse: () => _servings.first,
      );

      if (primaryServing.unit != 'g') {
        // Has a real serving, default to per-serving mode
        _isPerServingMode = true;
        _selectedServingForMacroInput = primaryServing;
        _primaryServingUnit = primaryServing.unit;
        _primaryServingQuantityController.text =
            _formatQuantity(primaryServing.quantity);
        _primaryServingGramsController.text =
            primaryServing.grams.toStringAsFixed(0);
        // Set macros for this serving
        _updateMacroFieldsForServing(food, primaryServing);
      } else {
        // Only has grams, use per-100g mode
        _isPerServingMode = false;
        _updateMacroFieldsFromBase(food);
      }
    } else {
      // New food - default to per-serving mode
      _isPerServingMode = true;
      _servings = [
        const FoodServing(foodId: 0, unit: 'g', grams: 1.0, quantity: 1.0),
      ];
      // Primary serving will be created from the inline fields on save
    }

    if (widget.isCopy) {
      _nameController.text = '${_nameController.text} - Copy';
    }
  }

  void _updateMacroFieldsFromBase(Food food) {
    // Populate controllers based on stored per-100g values
    _caloriesController.text = _format(food.calories * 100);
    _proteinController.text = _format(food.protein * 100);
    _fatController.text = _format(food.fat * 100);
    _carbsController.text = _format(food.carbs * 100);
    _fiberController.text = _format(food.fiber * 100);
  }

  void _updateMacroFieldsForServing(Food food, FoodServing serving) {
    // Calculate macros for this serving size
    final grams = serving.grams;
    _caloriesController.text = _format(food.calories * grams);
    _proteinController.text = _format(food.protein * grams);
    _fatController.text = _format(food.fat * grams);
    _carbsController.text = _format(food.carbs * grams);
    _fiberController.text = _format(food.fiber * grams);
  }

  String _format(double val) {
    if (val == 0) return '0';
    if (val < 1) return val.toStringAsFixed(1);
    return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  String _formatQuantity(double val) {
    return val == val.roundToDouble()
        ? val.round().toString()
        : val.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _notesController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _fiberController.dispose();
    _primaryServingQuantityController.dispose();
    _primaryServingGramsController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  double _parse(String text) => double.tryParse(text) ?? 0.0;

  Future<void> _save(bool useImmediately) async {
    if (!_formKey.currentState!.validate()) return;

    // Validation: require grams in per-serving mode
    if (_isPerServingMode) {
      final grams = _parse(_primaryServingGramsController.text);
      if (grams <= 0) {
        _showValidationError('Please enter the serving weight in grams');
        return;
      }
    }

    // Build primary serving from inline fields if in per-serving mode
    if (_isPerServingMode) {
      final unit = _isCustomUnit
          ? _customUnitController.text.trim()
          : _primaryServingUnit;
      final quantity = _parse(_primaryServingQuantityController.text);
      final grams = _parse(_primaryServingGramsController.text);

      if (unit.isNotEmpty && grams > 0) {
        final primaryServing = FoodServing(
          foodId: widget.originalFood?.id ?? 0,
          unit: unit,
          grams: grams,
          quantity: quantity > 0 ? quantity : 1.0,
        );

        // Update or add the primary serving
        final existingIndex = _servings.indexWhere((s) => s.unit == unit);
        if (existingIndex >= 0) {
          _servings[existingIndex] = primaryServing;
        } else {
          // Insert after 'g' if exists, or at start
          final gIndex = _servings.indexWhere((s) => s.unit == 'g');
          if (gIndex >= 0) {
            _servings.insert(gIndex + 1, primaryServing);
          } else {
            _servings.insert(0, primaryServing);
          }
        }
        _selectedServingForMacroInput = primaryServing;
      }
    }

    // Calculate per-gram values
    double factor = 1.0;
    if (_isPerServingMode && _selectedServingForMacroInput != null) {
      if (_selectedServingForMacroInput!.grams > 0) {
        factor = 1.0 / _selectedServingForMacroInput!.grams;
      }
    } else {
      factor = 0.01;
    }

    final newFood = Food(
      id: (widget.isCopy || widget.originalFood == null)
          ? 0
          : widget.originalFood!.id,
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim(),
      thumbnail: _thumbnail,
      usageNote: _notesController.text.trim(),
      calories: _parse(_caloriesController.text) * factor,
      protein: _parse(_proteinController.text) * factor,
      fat: _parse(_fatController.text) * factor,
      carbs: _parse(_carbsController.text) * factor,
      fiber: _parse(_fiberController.text) * factor,
      source: widget.originalFood?.source ?? 'user',
      servings: _servings,
    );

    try {
      final id = await DatabaseService.instance.saveFood(newFood);
      if (mounted) {
        Navigator.pop(
          context,
          FoodEditResult(id, useImmediately: useImmediately),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving food: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Missing Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            widget.originalFood == null ? 'Create Food' : 'Edit Food',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: () => _save(false),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMetadataSection(),
              const SizedBox(height: 24),
              _buildPrimaryServingSection(),
              const SizedBox(height: 24),
              _buildMacroSection(),
              const SizedBox(height: 24),
              _buildServingsSection(),
              const SizedBox(height: 32),
              if (widget.contextType == FoodEditContext.search)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _save(true),
                    icon: const Icon(Icons.input),
                    label: const Text('Save & Use Immediately'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextFormField(
                controller: _emojiController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: 'Emoji'),
                onChanged: (val) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes (Optional)'),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildImagePreview(),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Add Image'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: FoodImageWidget(
        thumbnail: _thumbnail,
        emoji: _emojiController.text,
        name: _nameController.text,
        size: 80,
        onTap: _pickImage,
      ),
    );
  }

  Widget _buildPrimaryServingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.largeWidgetBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serving Size',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  const Text('Per: '),
                  DropdownButton<bool>(
                    value: _isPerServingMode,
                    dropdownColor: Colors.grey[800],
                    items: const [
                      DropdownMenuItem(value: false, child: Text('100g')),
                      DropdownMenuItem(value: true, child: Text('Serving')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _isPerServingMode = val!;
                        // Recalculate macros when switching modes
                        if (widget.originalFood != null) {
                          if (_isPerServingMode &&
                              _selectedServingForMacroInput != null) {
                            _updateMacroFieldsForServing(
                              widget.originalFood!,
                              _selectedServingForMacroInput!,
                            );
                          } else {
                            _updateMacroFieldsFromBase(widget.originalFood!);
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_isPerServingMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                // Quantity field
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: _primaryServingQuantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Unit dropdown
                Expanded(
                  child: _isCustomUnit
                      ? TextFormField(
                          controller: _customUnitController,
                          decoration: InputDecoration(
                            labelText: 'Unit name',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _isCustomUnit = false;
                                  _customUnitController.clear();
                                });
                              },
                            ),
                          ),
                        )
                      : _buildUnitDropdown(),
                ),
                const SizedBox(width: 8),
                const Text('='),
                const SizedBox(width: 8),
                // Grams field
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _primaryServingGramsController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      labelText: 'Grams',
                      suffixText: 'g',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    onChanged: (val) {
                      // Auto-calculate macros if we have a food with existing data
                      if (widget.originalFood != null) {
                        final grams = _parse(val);
                        if (grams > 0) {
                          final food = widget.originalFood!;
                          _caloriesController.text = _format(food.calories * grams);
                          _proteinController.text = _format(food.protein * grams);
                          _fatController.text = _format(food.fat * grams);
                          _carbsController.text = _format(food.carbs * grams);
                          _fiberController.text = _format(food.fiber * grams);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitDropdown() {
    // Build list of unit options
    final units = <String>['serving'];

    // Add units from database that aren't already in the list
    for (final unit in _availableUnits) {
      if (!units.contains(unit)) {
        units.add(unit);
      }
    }

    // Add units from current food's servings
    for (final serving in _servings) {
      if (serving.unit != 'g' && !units.contains(serving.unit)) {
        units.add(serving.unit);
      }
    }

    // Ensure current selection is in the list
    if (!units.contains(_primaryServingUnit)) {
      units.insert(0, _primaryServingUnit);
    }

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Unit',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _primaryServingUnit,
          dropdownColor: Colors.grey[800],
          isExpanded: true,
          isDense: true,
          items: [
        ...units.map(
          (unit) => DropdownMenuItem(
            value: unit,
            child: Text(unit),
          ),
        ),
        const DropdownMenuItem(
          value: '_custom_',
          child: Text('Custom...'),
        ),
      ],
          onChanged: (val) {
            if (val == '_custom_') {
              setState(() {
                _isCustomUnit = true;
              });
            } else if (val != null) {
              setState(() {
                _primaryServingUnit = val;
                // If selecting an existing serving, update grams field
                final existingServing = _servings.firstWhere(
                  (s) => s.unit == val,
                  orElse: () => const FoodServing(
                    foodId: 0,
                    unit: '',
                    grams: 0,
                    quantity: 1,
                  ),
                );
                if (existingServing.grams > 0) {
                  _primaryServingGramsController.text =
                      existingServing.grams.toStringAsFixed(0);
                  _primaryServingQuantityController.text =
                      _formatQuantity(existingServing.quantity);
                  _selectedServingForMacroInput = existingServing;
                  // Auto-calculate macros
                  if (widget.originalFood != null) {
                    _updateMacroFieldsForServing(
                      widget.originalFood!,
                      existingServing,
                    );
                  }
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMacroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.largeWidgetBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition', style: Theme.of(context).textTheme.titleMedium),
          if (_isPerServingMode && _primaryServingGramsController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Values for ${_primaryServingQuantityController.text} ${_isCustomUnit ? _customUnitController.text : _primaryServingUnit} (${_primaryServingGramsController.text}g)',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          if (!_isPerServingMode)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Values per 100g',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          _buildMacroRow(_caloriesController, 'Calories', 'kcal'),
          _buildMacroRow(_proteinController, 'Protein', 'g'),
          _buildMacroRow(_fatController, 'Fat', 'g'),
          _buildMacroRow(_carbsController, 'Carbs', 'g'),
          _buildMacroRow(_fiberController, 'Fiber', 'g'),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                suffixText: suffix,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Servings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addServing,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._servings.asMap().entries.map((entry) {
          final index = entry.key;
          final serving = entry.value;
          // Don't show 'g' unit or the primary serving being edited
          if (serving.unit == 'g') return const SizedBox.shrink();
          if (_isPerServingMode &&
              serving.unit ==
                  (_isCustomUnit
                      ? _customUnitController.text
                      : _primaryServingUnit)) {
            return const SizedBox.shrink();
          }

          return Card(
            color: Colors.white.withValues(alpha: 0.05),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(_formatServingLabel(serving)),
              subtitle: Text('= ${serving.grams.toStringAsFixed(0)}g'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editServing(index),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.white54,
                    ),
                    onPressed: () => _deleteServing(index),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        // View Servings Info button
        if (widget.originalFood != null || _servings.length > 1)
          Center(
            child: TextButton.icon(
              onPressed: _showServingInfo,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('View Servings'),
            ),
          ),
      ],
    );
  }

  String _formatServingLabel(FoodServing serving) {
    final qty = serving.quantity;
    final qtyStr = qty == qty.roundToDouble()
        ? qty.round().toString()
        : qty.toStringAsFixed(1);
    return '$qtyStr ${serving.unit}';
  }

  void _showServingInfo() {
    // Build a temporary food with current state for the info sheet
    final grams = _parse(_primaryServingGramsController.text);
    double factor = 1.0;
    if (_isPerServingMode && grams > 0) {
      factor = 1.0 / grams;
    } else {
      factor = 0.01;
    }

    final tempFood = Food(
      id: widget.originalFood?.id ?? 0,
      name: _nameController.text.isNotEmpty
          ? _nameController.text
          : 'New Food',
      source: 'user',
      calories: _parse(_caloriesController.text) * factor,
      protein: _parse(_proteinController.text) * factor,
      fat: _parse(_fatController.text) * factor,
      carbs: _parse(_carbsController.text) * factor,
      fiber: _parse(_fiberController.text) * factor,
      servings: _servings,
    );

    showServingInfoSheet(context, tempFood);
  }

  Future<void> _addServing() async {
    await _showServingDialog();
  }

  Future<void> _editServing(int index) async {
    await _showServingDialog(index: index, serving: _servings[index]);
  }

  void _deleteServing(int index) {
    setState(() {
      final removed = _servings.removeAt(index);
      if (_selectedServingForMacroInput?.unit == removed.unit) {
        _selectedServingForMacroInput = _servings.firstWhere(
          (s) => s.unit != 'g',
          orElse: () => _servings.first,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_thumbnail != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    if (choice == 'remove') {
      if (_thumbnail != null) {
        final guid = widget.originalFood?.getLocalImageGuid();
        if (guid != null) {
          await ImageStorageService.instance.deleteImage(guid);
        }
      }
      setState(() {
        _thumbnail = null;
      });
      return;
    }

    final imagePicker = picker.ImagePicker();
    final picker.XFile? pickedFile;
    if (choice == 'camera') {
      pickedFile = await imagePicker.pickImage(
        source: picker.ImageSource.camera,
      );
    } else {
      pickedFile = await imagePicker.pickImage(
        source: picker.ImageSource.gallery,
      );
    }

    if (pickedFile == null) return;

    try {
      final guid = await ImageStorageService.instance.saveImage(
        File(pickedFile.path),
      );

      if (_thumbnail != null) {
        final oldGuid = widget.originalFood?.getLocalImageGuid();
        if (oldGuid != null) {
          await ImageStorageService.instance.deleteImage(oldGuid);
        }
      }

      setState(() {
        _thumbnail = '${ImageStorageService.localPrefix}$guid';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showServingDialog({int? index, FoodServing? serving}) async {
    final nameCtrl = TextEditingController(text: serving?.unit ?? '');
    final gramsCtrl = TextEditingController(
      text: serving?.grams.toString() ?? '',
    );
    final quantityCtrl = TextEditingController(
      text: serving?.quantity.toString() ?? '1.0',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(serving == null ? 'Add Serving' : 'Edit Serving'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Unit Name (e.g. cup, slice)',
              ),
            ),
            TextFormField(
              controller: quantityCtrl,
              decoration: const InputDecoration(
                labelText: 'Quantity (e.g. 1.0)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextFormField(
              controller: gramsCtrl,
              decoration: const InputDecoration(
                labelText: 'Weight for Quantity (g)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final grams = double.tryParse(gramsCtrl.text) ?? 0.0;
              final qty = double.tryParse(quantityCtrl.text) ?? 1.0;
              if (name.isNotEmpty && grams > 0) {
                setState(() {
                  final newServing = FoodServing(
                    foodId: widget.originalFood?.id ?? 0,
                    unit: name,
                    grams: grams,
                    quantity: qty,
                  );
                  if (index != null) {
                    _servings[index] = newServing;
                  } else {
                    _servings.add(newServing);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
