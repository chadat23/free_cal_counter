import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food.dart';
import '../models/food_portion.dart';
import '../services/database_service.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  int consumedCalories = 0;
  int totalCalories = 2000; // Example total calories
  List<String> provisionalFoods =
      []; // List to hold emojis of provisionally added foods
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Database and search state
  final DatabaseService _databaseService = DatabaseService();
  List<Food> _searchResults = [];
  List<Food> _offSearchResults = [];
  bool _isSearching = false;
  bool _isSearchingOff = false;
  bool _showOffResults = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    // Focus the search box when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    // Load some random foods initially
    _loadRandomFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRandomFoods() async {
    try {
      final foods = await _databaseService.getRandomFoods(limit: 10);
      setState(() {
        _searchResults = foods;
      });
    } catch (e) {
      //TODO: Handle error
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.trim().isEmpty) {
      await _loadRandomFoods();
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
      _showOffResults = false;
      _offSearchResults = [];
    });

    try {
      final results = await _databaseService.searchFoods(query, limit: 20);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      //TODO: Handle error
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _searchOpenFoodFacts() async {
    if (_currentQuery.trim().isEmpty) return;

    setState(() {
      _isSearchingOff = true;
    });

    try {
      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
            parametersList: <Parameter>[
              SearchTerms(terms: [_currentQuery]),
            ],
            version: ProductQueryVersion.v3,
          );

      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null,
        configuration,
      );

      final offResults =
          result.products
              ?.map((product) => _convertOffProductToFood(product))
              .whereType<Food>()
              .toList() ??
          [];

      setState(() {
        _offSearchResults = offResults;
        _isSearchingOff = false;
        _showOffResults = true;
      });
    } catch (e) {
      //TODO: Handle error
      setState(() {
        _isSearchingOff = false;
      });
    }
  }

  Food? _convertOffProductToFood(Product product) {
    // Extract calories from nutrients
    final nutriments = product.nutriments;

    final energyKcal = nutriments?.getValue(
      Nutrient.energyKCal,
      PerSize.oneHundredGrams,
    );
    final energyKj = nutriments?.getValue(
      Nutrient.energyKJ,
      PerSize.oneHundredGrams,
    );
    double? calories;

    if (energyKcal != null) {
      calories = energyKcal;
    } else if (energyKj != null) {
      // Convert kJ to kcal if needed
      calories = energyKj / 4.184;
    }

    // Extract other nutrients (per 100g)
    double? protein = nutriments?.getValue(
      Nutrient.proteins,
      PerSize.oneHundredGrams,
    );
    double? fat = nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams);
    double? carbs = nutriments?.getValue(
      Nutrient.carbohydrates,
      PerSize.oneHundredGrams,
    );

    if (calories == null || protein == null || fat == null || carbs == null) {
      return null;
    }

    // Create a Food object from OpenFoodFacts data
    return Food(
      id: int.tryParse(product.barcode ?? '0') ?? 0,
      source: 'openfoodfacts',
      externalId: product.barcode ?? 'unknown',
      description: product.productName ?? 'Unknown Product',
      caloriesKcal: calories,
      proteinG: protein,
      fatG: fat,
      carbsG: carbs,
      portions:
          [], // OpenFoodFacts doesn't have portion data in the same format
      imageThumbUrl: product.imageFrontUrl,
      imageFrontThumbUrl: product.imageFrontUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header - always visible, doesn't scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  // Calories display (X/Y format)
                  Text(
                    '$consumedCalories/$totalCalories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Emoji area for provisionally added foods
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          // Display emojis of provisionally added foods
                          if (provisionalFoods.isEmpty)
                            Text(
                              'Added foods...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provisionalFoods.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      provisionalFoods[index],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Dropdown arrow (⬇️)
                  GestureDetector(
                    onTap: () {
                      // TODO: Show detailed view of provisionally added foods
                      _showProvisionalFoodsDetails();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('⬇️', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close button (X)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content area for food search results
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSearchResults(),
                ),
              ),
            ),

            // Search box at the bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: '🔍 Search for foods...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        // Debounce search to avoid too many database calls
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (_searchController.text == value) {
                            _searchFoods(value);
                          }
                        });
                      },
                      onTapOutside: (event) {
                        // Hide keyboard when tapping outside the text field
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // OpenFoodFacts button - always visible
                  ElevatedButton.icon(
                    onPressed: _isSearchingOff ? null : _searchOpenFoodFacts,
                    icon: _isSearchingOff
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.public, size: 18),
                    label: Text(_isSearchingOff ? 'OFF...' : 'OFF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Show OpenFoodFacts results if we're showing them
    if (_showOffResults) {
      return Column(
        children: [
          // Header with back button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showOffResults = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.public, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'OpenFoodFacts Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_isSearchingOff)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // OpenFoodFacts results
          if (_offSearchResults.isEmpty && !_isSearchingOff)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No OpenFoodFacts results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _offSearchResults
                  .map((food) => _buildFoodItem(food, isOffResult: true))
                  .toList(),
            ),
        ],
      );
    }

    // Show local database results
    if (_searchResults.isEmpty && !_isSearching) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Column(
          children: [
            Icon(Icons.search, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No foods found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching for a different food',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Local database results
        ..._searchResults.map((food) => _buildFoodItem(food)),
      ],
    );
  }

  Widget _buildFoodItem(Food food, {bool isOffResult = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isOffResult && food.imageThumbUrl != null)
            Image.network(
              food.imageThumbUrl!,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            )
          else if (isOffResult && food.imageFrontThumbUrl != null)
            Image.network(
              food.imageFrontThumbUrl!,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            )
          else
            Text(
              _getFoodEmoji(food.description),
              style: const TextStyle(fontSize: 24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isOffResult)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.public,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'OFF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  food.caloriesText100g,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (food.portions.isNotEmpty)
                  _buildPortionsRow(food.portions, food),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _addToProvisionalFoods(food);
            },
            icon: const Icon(Icons.add),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPortionsRow(List<FoodPortion> portions, Food food) {
    final top = portions.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in top) _portionChip(p, food),
            if (portions.length > 3)
              GestureDetector(
                onTap: () => _showAllPortions(food),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+${portions.length - 3} more',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _portionChip(FoodPortion portion, Food food) {
    final grams = portion.gramWeight;
    final kcal = food.caloriesForGrams(grams).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '${portion.label} • ${grams.toStringAsFixed(0)} g • $kcal kcal',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showAllPortions(Food food) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  food.caloriesText100g,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                for (final portion in food.portions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(portion.label)),
                        Text('${portion.gramWeight.toStringAsFixed(0)} g'),
                        const SizedBox(width: 8),
                        Text(
                          '${food.caloriesForGrams(portion.gramWeight).round()} kcal',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFoodEmoji(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('apple')) return '🍎';
    if (desc.contains('banana')) return '🍌';
    if (desc.contains('orange')) return '🍊';
    if (desc.contains('grape')) return '🍇';
    if (desc.contains('strawberry')) return '🍓';
    if (desc.contains('cherry')) return '🍒';
    if (desc.contains('peach')) return '🍑';
    if (desc.contains('pear')) return '🍐';
    if (desc.contains('lemon')) return '🍋';
    if (desc.contains('lime')) return '🍋';
    if (desc.contains('watermelon')) return '🍉';
    if (desc.contains('melon')) return '🍈';
    if (desc.contains('pineapple')) return '🍍';
    if (desc.contains('coconut')) return '🥥';
    if (desc.contains('mango')) return '🥭';
    if (desc.contains('avocado')) return '🥑';
    if (desc.contains('tomato')) return '🍅';
    if (desc.contains('carrot')) return '🥕';
    if (desc.contains('corn')) return '🌽';
    if (desc.contains('pepper')) return '🌶️';
    if (desc.contains('cucumber')) return '🥒';
    if (desc.contains('broccoli')) return '🥦';
    if (desc.contains('lettuce')) return '🥬';
    if (desc.contains('mushroom')) return '🍄';
    if (desc.contains('peanut')) return '🥜';
    if (desc.contains('bread')) return '🍞';
    if (desc.contains('croissant')) return '🥐';
    if (desc.contains('bagel')) return '🥯';
    if (desc.contains('pancake')) return '🥞';
    if (desc.contains('waffle')) return '🧇';
    if (desc.contains('cheese')) return '🧀';
    if (desc.contains('meat')) return '🥩';
    if (desc.contains('bacon')) return '🥓';
    if (desc.contains('sausage')) return '🌭';
    if (desc.contains('pizza')) return '🍕';
    if (desc.contains('burger')) return '🍔';
    if (desc.contains('sandwich')) return '🥪';
    if (desc.contains('taco')) return '🌮';
    if (desc.contains('burrito')) return '🌯';
    if (desc.contains('salad')) return '🥗';
    if (desc.contains('popcorn')) return '🍿';
    if (desc.contains('butter')) return '🧈';
    if (desc.contains('salt')) return '🧂';
    if (desc.contains('egg')) return '🥚';
    if (desc.contains('milk')) return '🥛';
    if (desc.contains('coffee')) return '☕';
    if (desc.contains('tea')) return '🍵';
    if (desc.contains('beer')) return '🍺';
    if (desc.contains('wine')) return '🍷';
    if (desc.contains('cake')) return '🍰';
    if (desc.contains('cookie')) return '🍪';
    if (desc.contains('chocolate')) return '🍫';
    if (desc.contains('candy')) return '🍬';
    if (desc.contains('lollipop')) return '🍭';
    if (desc.contains('honey')) return '🍯';
    if (desc.contains('donut')) return '🍩';
    if (desc.contains('ice cream')) return '🍦';
    if (desc.contains('fish')) return '🐟';
    if (desc.contains('shrimp')) return '🦐';
    if (desc.contains('crab')) return '🦀';
    if (desc.contains('lobster')) return '🦞';
    if (desc.contains('oyster')) return '🦪';
    if (desc.contains('rice')) return '🍚';
    if (desc.contains('noodle')) return '🍜';
    if (desc.contains('spaghetti')) return '🍝';
    if (desc.contains('bread')) return '🍞';
    if (desc.contains('pretzel')) return '🥨';
    if (desc.contains('cracker')) return '🍘';
    if (desc.contains('soup')) return '🍲';
    if (desc.contains('stew')) return '🍲';
    if (desc.contains('curry')) return '🍛';
    if (desc.contains('sushi')) return '🍣';
    if (desc.contains('bento')) return '🍱';
    if (desc.contains('dumpling')) return '🥟';
    if (desc.contains('fortune cookie')) return '🥠';
    if (desc.contains('takeout box')) return '🥡';
    return '🍽️'; // Default food emoji
  }

  void _addToProvisionalFoods(Food food) {
    setState(() {
      provisionalFoods.add(_getFoodEmoji(food.description));
      consumedCalories += food.caloriesKcal.round();
    });
  }

  void _showProvisionalFoodsDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provisional Foods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provisionalFoods.isEmpty)
              const Text('No provisional foods added yet')
            else
              ...provisionalFoods.asMap().entries.map((entry) {
                final index = entry.key;
                final emoji = entry.value;
                return ListTile(
                  leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                  title: Text('Food ${index + 1}'),
                  subtitle: Text('$consumedCalories calories total'),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        provisionalFoods.removeAt(index);
                        // Recalculate calories - this is simplified
                        consumedCalories =
                            (consumedCalories *
                                    (provisionalFoods.length - 1) /
                                    provisionalFoods.length)
                                .round();
                      });
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                );
              }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
