import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/config/app_router.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/models/recipe.dart';
import 'package:meal_of_record/models/recipe_item.dart';
import 'package:meal_of_record/config/app_colors.dart';
import 'package:meal_of_record/widgets/horizontal_mini_bar_chart.dart';
import 'package:meal_of_record/screens/search_screen.dart';
import 'package:meal_of_record/models/search_config.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/services/food_sorting_service.dart';
import 'package:meal_of_record/widgets/slidable_recipe_item_widget.dart';
import 'package:meal_of_record/models/quantity_edit_config.dart';
import 'package:meal_of_record/screens/quantity_edit_screen.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart' as model_unit;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/services/emoji_service.dart';
import 'package:meal_of_record/models/category.dart' as model_cat;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:meal_of_record/screens/square_camera_screen.dart';
import 'package:meal_of_record/widgets/food_image_widget.dart';
import 'package:meal_of_record/services/image_storage_service.dart';
import 'package:meal_of_record/widgets/unit_select_field.dart';

class RecipeEditScreen extends StatefulWidget {
  const RecipeEditScreen({super.key});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _portionsController;
  late TextEditingController _portionNameController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late TextEditingController _emojiController;
  List<model_cat.Category> _allCategories = [];
  List<String> _availableUnits = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.name);
    _portionsController = TextEditingController(
      text: provider.servingsCreated.toString(),
    );
    _portionNameController = TextEditingController(text: provider.portionName);
    _weightController = TextEditingController(
      text: provider.finalWeightGrams?.toString() ?? '',
    );
    _notesController = TextEditingController(text: provider.notes);
    _emojiController = TextEditingController(text: provider.emoji);
    _loadCategories();
    _loadAvailableUnits();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService.instance.getCategories();
    if (mounted) {
      setState(() {
        _allCategories = cats;
      });
    }
  }

  Future<void> _loadAvailableUnits() async {
    final units = await DatabaseService.instance.getDistinctUnits();
    if (mounted) {
      setState(() {
        _availableUnits = units;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _portionsController.dispose();
    _portionNameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.name.isEmpty ? 'New Recipe' : provider.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final success = await provider.saveRecipe();

                  if (!mounted) return;

                  if (success) {
                    navigator.pop(true);
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.errorMessage ?? 'Failed to save recipe.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              // Only show Import (Scan) button if creating a new recipe AND it's empty
              if (provider.id == 0 &&
                  provider.name.isEmpty &&
                  provider.items.isEmpty)
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Import Recipe',
                  onPressed: () async {
                    final importedId = await Navigator.pushNamed(
                      context,
                      AppRouter.qrSharingRoute,
                    );

                    if (importedId != null && importedId is int && mounted) {
                      final newRecipe = await DatabaseService.instance
                          .getRecipeById(importedId);
                      provider.loadFromRecipe(newRecipe);
                      // Update controllers
                      _nameController.text = newRecipe.name;
                      _portionsController.text = newRecipe.servingsCreated
                          .toString();
                      _portionNameController.text = newRecipe.portionName;
                      _weightController.text =
                          newRecipe.finalWeightGrams?.toString() ?? '';
                      _notesController.text = newRecipe.notes ?? '';
                      // Refresh categories
                      setState(() {});
                    }
                  },
                ),
              // Only show Share button if the recipe is saved (id > 0)
              if (provider.id > 0)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    // Reconstruct recipe object from provider state to share
                    // (Logic same as before but inside condition)
                    final recipeToShare = Recipe(
                      id: provider.id,
                      name: provider.name,
                      servingsCreated: provider.servingsCreated,
                      finalWeightGrams: provider.finalWeightGrams,
                      portionName: provider.portionName,
                      notes: provider.notes,
                      isTemplate: provider.isTemplate,
                      hidden: false,
                      parentId: provider.parentId,
                      createdTimestamp: DateTime.now().millisecondsSinceEpoch,
                      items: provider.items,
                      categories: provider.selectedCategories,
                      emoji: provider.emoji,
                      thumbnail: provider.thumbnail,
                    );

                    Navigator.pushNamed(
                      context,
                      AppRouter.qrSharingRoute,
                      arguments: recipeToShare,
                    );
                  },
                ),
            ],
          ),
          body: SlidableAutoCloseBehavior(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadataFields(provider),
                  const SizedBox(height: 24),
                  _buildMacroSummary(provider),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          final databaseService = DatabaseService.instance;
                          final offApiService = OffApiService();
                          final emojiService = emojiForFoodName;
                          final searchService = SearchService(
                            databaseService: databaseService,
                            offApiService: offApiService,
                            emojiForFoodName: emojiService,
                            sortingService: FoodSortingService(),
                          );

                          final item = await Navigator.push<RecipeItem>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (_) => SearchProvider(
                                  databaseService: databaseService,
                                  offApiService: offApiService,
                                  searchService: searchService,
                                ),
                                child: SearchScreen(
                                  config: SearchConfig(
                                    context: QuantityEditContext.recipe,
                                    title: 'Add Ingredient',
                                    showQueueStats: false,
                                    onSaveOverride: (portion) {
                                      Navigator.pop(
                                        context,
                                        RecipeItem(
                                          id: 0,
                                          food: portion.food,
                                          grams: portion.grams,
                                          unit: portion.unit,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (item != null && mounted) {
                            provider.addItem(item);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildIngredientList(provider),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Preparation steps, cooking time...',
                    ),
                    onChanged: provider.setNotes,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataFields(RecipeProvider provider) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Recipe Name',
            hintText: 'e.g. Grandma\'s Apple Pie',
          ),
          onChanged: provider.setName,
        ),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextFormField(
                controller: _emojiController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: 'Emoji'),
                onChanged: provider.setEmoji,
              ),
            ),
            const SizedBox(width: 16),
            _buildImagePreview(provider),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(provider),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Add Image'),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _portionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Portions Count'),
                onChanged: (val) {
                  final d = double.tryParse(val);
                  if (d != null) provider.setServingsCreated(d);
                },
                onTap: () {
                  _portionsController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _portionsController.text.length,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: UnitSelectField(
                label: 'Portion Unit Name',
                value: provider.portionName,
                availableUnits: _availableUnits,
                onChanged: provider.setPortionName,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Final Weight (g)',
                  hintText: 'Optional',
                ),
                onChanged: (val) {
                  final d = double.tryParse(val);
                  provider.setFinalWeightGrams(d);
                },
                onTap: () {
                  _weightController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _weightController.text.length,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Only Dumpable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Switch(
              value: provider.isTemplate,
              onChanged: provider.setIsTemplate,
            ),
          ],
        ),
        const Text(
          'When enabled, this recipe can only be dumped as individual ingredients into your log.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _showCategorySelectionDialog,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Categories',
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            child: provider.selectedCategories.isEmpty
                ? const Text(
                    'None selected',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: provider.selectedCategories.map((cat) {
                      return Chip(
                        label: Text(
                          cat.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => provider.toggleCategory(cat),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(RecipeProvider provider) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: FoodImageWidget(
        thumbnail: provider.thumbnail,
        emoji: provider.emoji,
        name: provider.name,
        size: 60,
        onTap: () => _pickImage(provider),
      ),
    );
  }

  Future<void> _pickImage(RecipeProvider provider) async {
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
            if (provider.thumbnail != null)
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
      provider.setThumbnail(null);
      return;
    }

    if (!mounted) return;

    final String? pickedPath;
    if (choice == 'camera') {
      pickedPath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const SquareCameraScreen()),
      );
    } else {
      final pickedFile = await image_picker.ImagePicker().pickImage(
        source: image_picker.ImageSource.gallery,
      );
      pickedPath = pickedFile?.path;
    }

    if (pickedPath == null) return;

    try {
      final guid = await ImageStorageService.instance.saveImage(
        File(pickedPath),
      );
      provider.setThumbnail('${ImageStorageService.localPrefix}$guid');
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

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final provider = Provider.of<RecipeProvider>(context);
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Categories'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () async {
                      final name = await _showAddCategorySimpleDialog();
                      if (name != null) {
                        final newCategoryId = await DatabaseService.instance
                            .addCategory(name);
                        await _loadCategories();
                        // Find and auto-select the newly created category
                        final newCategory = _allCategories.firstWhere(
                          (cat) => cat.id == newCategoryId,
                          orElse: () => _allCategories.last,
                        );
                        provider.toggleCategory(newCategory);
                        setDialogState(() {});
                      }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _allCategories[index];
                    final isSelected = provider.selectedCategories.any(
                      (c) => c.id == cat.id,
                    );
                    return CheckboxListTile(
                      title: Text(cat.name),
                      value: isSelected,
                      onChanged: (_) {
                        provider.toggleCategory(cat);
                        setDialogState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showAddCategorySimpleDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSummary(RecipeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.largeWidgetBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMacroRow(
            'Total Recipe Macros',
            provider.totalCalories,
            provider.totalProtein,
            provider.totalFat,
            provider.totalCarbs,
            provider.totalFiber,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          _buildMacroRow(
            'Macros per ${provider.portionName}',
            provider.caloriesPerPortion,
            provider.totalProtein / provider.servingsCreated,
            provider.totalFat / provider.servingsCreated,
            provider.totalCarbs / provider.servingsCreated,
            provider.totalFiber / provider.servingsCreated,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
    String title,
    double cal,
    double protein,
    double fat,
    double carbs,
    double fiber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMacroItem('🔥', cal, 2000, Colors.blue),
            _buildMacroItem('P', protein, 150, Colors.red),
            _buildMacroItem('F', fat, 70, Colors.yellow),
            _buildMacroItem('C', carbs, 250, Colors.green),
            _buildMacroItem('Fb', fiber, 30, Colors.brown),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, double val, double target, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: HorizontalMiniBarChart(
          consumed: val,
          target: target,
          color: color,
          macroLabel: label,
          unitLabel: '',
        ),
      ),
    );
  }

  Widget _buildIngredientList(RecipeProvider provider) {
    if (provider.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No ingredients added yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: provider.items.length,
      onReorder: (oldIndex, newIndex) => provider.reorderItem(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return SlidableRecipeItemWidget(
          key: ValueKey('${item.id}_$index'),
          item: item,
          index: index,
          onDelete: () => provider.removeItem(index),
          onEdit: () async {
            // Determine food object (either food itself or converted recipe)
            final Food food = item.isFood ? item.food! : item.recipe!.toFood();

            // Find best matching serving
            final model_unit.FoodServing serving = food.servings.firstWhere(
              (s) => s.unit == item.unit,
              orElse: () => food.servings.first,
            );

            // Reload food from database to get latest changes (e.g., image)
            final reloadedFood = await DatabaseService.instance.getFoodById(
              food.id,
              'live',
            );

            if (reloadedFood == null) {
              // Fallback to cached food if reload fails
              return;
            }

            if (!mounted) return;

            // Navigate to QuantityEditScreen
            final updatedPortion = await Navigator.push<FoodPortion>(
              context,
              MaterialPageRoute(
                builder: (_) => QuantityEditScreen(
                  config: QuantityEditConfig(
                    context: QuantityEditContext.recipe,
                    food: reloadedFood,
                    isUpdate: true,
                    initialUnit: serving.unit,
                    initialQuantity: serving.quantityFromGrams(item.grams),
                    originalGrams: item.grams,
                    recipeServings: provider.servingsCreated,
                  ),
                ),
              ),
            );

            if (updatedPortion != null && mounted) {
              // Convert FoodPortion back to RecipeItem
              final newItem = RecipeItem(
                id: item.id,
                food: item.isFood ? updatedPortion.food : null,
                recipe: item.isRecipe ? item.recipe : null,
                grams: updatedPortion.grams,
                unit: updatedPortion.unit,
              );
              provider.updateItem(index, newItem);
            }
          },
        );
      },
    );
  }
}
