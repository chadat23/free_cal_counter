import 'dart:io';
import 'package:flutter/material.dart';
import 'package:free_cal_counter1/models/food.dart';
import 'package:free_cal_counter1/models/food_serving.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/image_storage_service.dart';
import 'package:free_cal_counter1/widgets/screen_background.dart';
import 'package:free_cal_counter1/widgets/food_image_widget.dart';
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

  List<FoodServing> _servings = [];
  bool _isPerServingMode = false;
  FoodServing? _selectedServingForMacroInput;
  String? _thumbnail;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final food = widget.originalFood;
    _nameController = TextEditingController(text: food?.name ?? '');
    _emojiController = TextEditingController(text: food?.emoji ?? '🍎');
    _notesController = TextEditingController(text: food?.usageNote ?? '');
    _thumbnail = food?.thumbnail;

    if (food != null) {
      // Copy servings but ensure they are mutable
      _servings = List.from(food.servings);

      // Initialize macro fields (always derived from per-100g base initially)
      _updateMacroFieldsFromBase(food);
    } else {
      // Default servings for new food
      _servings = [
        const FoodServing(foodId: 0, unit: 'g', grams: 1.0, quantity: 1.0),
        const FoodServing(
          foodId: 0,
          unit: 'serving',
          grams: 100.0,
          quantity: 1.0,
        ),
      ];
    }

    // Auto-select "serving" if available for per-serving mode
    _selectedServingForMacroInput = _servings.firstWhere(
      (s) => s.unit != 'g',
      orElse: () => _servings.first,
    );

    if (widget.isCopy) {
      _nameController.text = '${_nameController.text} - Copy';
    }
  }

  void _updateMacroFieldsFromBase(Food food) {
    // Populate controllers based on stored 100g values
    _caloriesController.text = _format(food.calories * 100);
    _proteinController.text = _format(food.protein * 100);
    _fatController.text = _format(food.fat * 100);
    _carbsController.text = _format(food.carbs * 100);
    _fiberController.text = _format(food.fiber * 100);
  }

  String _format(double val) {
    return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
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
    super.dispose();
  }

  double _parse(String text) => double.tryParse(text) ?? 0.0;

  Future<void> _save(bool useImmediately) async {
    if (!_formKey.currentState!.validate()) return;

    // Calculate per-100g values
    double factor = 1.0;
    if (_isPerServingMode && _selectedServingForMacroInput != null) {
      // Input is for X grams (serving size), we want per 1g
      // e.g. 200 cals per 50g -> 4 cals per 1g
      if (_selectedServingForMacroInput!.grams > 0) {
        factor = 1.0 / _selectedServingForMacroInput!.grams;
      }
    } else {
      // Input is per 100g. 100g -> 1g is divide by 100
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
      source:
          widget.originalFood?.source ?? 'user', // Preserve source if editing
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
            // "Save" (Checkmark)
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
                onChanged: (val) {
                  // Basic validation or auto-picker hook could go here
                },
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
        // Image picker with preview
        Row(
          children: [
            // Image preview frame
            _buildImagePreview(),
            const SizedBox(width: 16),
            // Image picker button
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
      child: _thumbnail != null
          ? _buildThumbnailImage()
          : _buildEmptyPlaceholder(),
    );
  }

  Widget _buildThumbnailImage() {
    return FoodImageWidget(
      thumbnail: _thumbnail,
      emoji: _emojiController.text,
      size: 80,
      onTap: _pickImage,
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          'No Image',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nutrition', style: Theme.of(context).textTheme.titleMedium),
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
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_isPerServingMode) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<FoodServing>(
              value: _selectedServingForMacroInput,
              decoration: const InputDecoration(labelText: 'Based on Serving'),
              dropdownColor: Colors.grey[800],
              items: _servings
                  .where(
                    (s) => s.unit != 'g',
                  ) // Exclude 'g' as it's redundant for "Per Serving" usually
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.quantity} ${s.unit} (${s.grams}g)'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedServingForMacroInput = val);
              },
            ),
          ],
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
              'Servings / Units',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addServing,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_servings.isEmpty)
          const Text(
            'No servings defined. Defaults to grams only.',
            style: TextStyle(color: Colors.grey),
          ),
        ..._servings.asMap().entries.map((entry) {
          final index = entry.key;
          final serving = entry.value;
          // Don't simplify editing of 'g' for now, it's a constant base
          if (serving.unit == 'g') return const SizedBox.shrink();

          return Card(
            color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('${serving.quantity} ${serving.unit}'),
              subtitle: Text('= ${serving.grams} g'),
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
      ],
    );
  }

  Future<void> _addServing() async {
    await _showServingDialog();
  }

  Future<void> _editServing(int index) async {
    await _showServingDialog(index: index, serving: _servings[index]);
  }

  void _deleteServing(int index) {
    setState(() {
      _servings.removeAt(index);
      if (_selectedServingForMacroInput == _servings[index]) {
        _selectedServingForMacroInput = _servings.firstWhere(
          (s) => s.unit != 'g',
          orElse: () => _servings.first,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    // Show dialog with options
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
      // Delete old image if exists
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

    // Pick image from camera or gallery
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

    // Save image (cropping to be added later)
    try {
      final guid = await ImageStorageService.instance.saveImage(
        File(pickedFile.path),
      );

      // Delete old image if exists
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
                  // Select new/edited serving if we are in per-serving mode and none selected
                  if (_isPerServingMode &&
                      _selectedServingForMacroInput == null) {
                    _selectedServingForMacroInput = newServing;
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
