import 'package:meal_of_record/services/emoji_service.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/models/food_serving.dart' as model_unit;
import 'package:meal_of_record/services/off_api_client_wrapper.dart';

class OffApiService {
  final OffApiClientWrapper _apiWrapper;

  OffApiService({OffApiClientWrapper? apiWrapper})
    : _apiWrapper = apiWrapper ?? OffApiClientWrapper();

  Future<model.Food?> fetchFoodByBarcode(String barcode) async {
    final productResult = await _apiWrapper.getProductV3(
      ProductQueryConfiguration(barcode, version: ProductQueryVersion.v3),
    );

    if (productResult.status != ProductResultV3.statusSuccess ||
        productResult.product == null) {
      return null;
    }

    return _processProduct(productResult.product!);
  }

  Future<List<model.Food>> searchFoodsByName(String query) async {
    final ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
          parametersList: <Parameter>[
            SearchTerms(terms: [query]),
            PageSize(size: 20),
          ],
          language: OpenFoodFactsLanguage.ENGLISH,
          fields: [
            ProductField.NAME,
            ProductField.BARCODE,
            ProductField.IMAGE_FRONT_URL,
            ProductField.NUTRIMENTS,
            ProductField.SERVING_SIZE,
            ProductField.SERVING_QUANTITY,
          ],
          version: ProductQueryVersion.v3,
        );

    final SearchResult searchResult = await _apiWrapper.searchProducts(
      null, // User can be null for public searches
      configuration,
    );

    if (searchResult.products == null || searchResult.products!.isEmpty) {
      return [];
    }

    final List<model.Food> foods = [];
    for (final Product product in searchResult.products!) {
      final food = await _processProduct(product);
      if (food != null) {
        foods.add(food);
      }
    }

    return foods;
  }

  Future<model.Food?> _processProduct(Product product) async {
    final nutriments = product.nutriments;
    if (nutriments == null) {
      return null;
    }

    // --- Step 1: Determine the best anchor and calculate baseline per gram values ---
    double? baseEnergyPerGram;
    double? baseProteinPerGram;
    double? baseFatPerGram;
    double? baseCarbsPerGram;
    double? baseFiberPerGram;

    // Option A: Direct per 100g data (highest priority anchor)
    final energy100g = nutriments.getValue(
      Nutrient.energyKCal,
      PerSize.oneHundredGrams,
    );
    final protein100g = nutriments.getValue(
      Nutrient.proteins,
      PerSize.oneHundredGrams,
    );
    final fat100g = nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams);
    final carbs100g = nutriments.getValue(
      Nutrient.carbohydrates,
      PerSize.oneHundredGrams,
    );
    final fiber100g = nutriments.getValue(
      Nutrient.fiber,
      PerSize.oneHundredGrams,
    );

    if (energy100g != null &&
        protein100g != null &&
        fat100g != null &&
        carbs100g != null) {
      baseEnergyPerGram = energy100g / 100.0;
      baseProteinPerGram = protein100g / 100.0;
      baseFatPerGram = fat100g / 100.0;
      baseCarbsPerGram = carbs100g / 100.0;
      //baseFiberPerGram = fiber100g / 100.0;
    }
    if (fiber100g != null) {
      baseFiberPerGram = fiber100g / 100.0;
    }

    // --- Step 1.5: Prepare serving size data ---
    final portionSizeText = product.servingSize;
    final parsedPortionItems = parsePortionSize(portionSizeText);

    // Also try to parse serving_size_imported for additional options
    // This field is not yet in the typed Product class, so we access it via JSON
    final importedServingSize =
        product.toJson()['serving_size_imported'] as String?;
    final parsedImportedItems = parsePortionSize(importedServingSize);

    // Combine items, prioritizing the main serving size text if needed,
    // but for unit discovery we want everything.
    final allParsedItems = [...parsedPortionItems, ...parsedImportedItems];

    // Option B: Serving size (secondary anchor)
    double? portionGrams;

    // 1. Try structured data first (servingQuantity)
    // In OpenFoodFacts, servingQuantity is typically the normalized value in grams or ml.
    if (product.servingQuantity != null) {
      portionGrams = product.servingQuantity;
    }

    // 2. Fallback to parsing serving size string if structured data failed
    if (portionGrams == null) {
      // Try to find a mass or volume in the parsed items to use as servingGrams
      // Priority: Mass (g) > Volume (ml)

      // Look for explicit mass
      for (final item in allParsedItems) {
        final grams = toGrams(item.$1, item.$2);
        if (grams != null) {
          portionGrams = grams;
          break;
        }
      }

      // If no mass, look for explicit volume
      if (portionGrams == null) {
        for (final item in allParsedItems) {
          final ml = toMilliliters(item.$1, item.$2);
          if (ml != null) {
            // Assume 1ml = 1g for baseline calculation
            portionGrams = ml;
            break;
          }
        }
      }
    }

    if (portionGrams != null && portionGrams > 0) {
      final portionEnergy = nutriments.getValue(
        Nutrient.energyKCal,
        PerSize.serving,
      );
      final portionProtein = nutriments.getValue(
        Nutrient.proteins,
        PerSize.serving,
      );
      final portionFat = nutriments.getValue(Nutrient.fat, PerSize.serving);
      final portionCarbs = nutriments.getValue(
        Nutrient.carbohydrates,
        PerSize.serving,
      );
      final servingFiber = nutriments.getValue(Nutrient.fiber, PerSize.serving);

      if (portionEnergy != null &&
          portionProtein != null &&
          portionFat != null &&
          portionCarbs != null &&
          baseEnergyPerGram == null) {
        // Calculate per gram values from this serving anchor
        // Only if we haven't already established a baseline from 100g data
        final double ratio = 1.0 / portionGrams;
        baseEnergyPerGram = portionEnergy * ratio;
        baseProteinPerGram = portionProtein * ratio;
        baseFatPerGram = portionFat * ratio;
        baseCarbsPerGram = portionCarbs * ratio;
        baseFiberPerGram = (servingFiber ?? 0.0) * ratio;
      }
    }

    // If we still don't have complete per gram data, we can't proceed
    if (baseEnergyPerGram == null ||
        baseProteinPerGram == null ||
        baseFatPerGram == null ||
        baseCarbsPerGram == null) {
      return null;
    }
    // Default fiber to 0 if missing
    baseFiberPerGram ??= 0.0;

    // --- Step 2: Populate the units list ---
    List<model_unit.FoodServing> units = [];
    final caloriesPerGram = baseEnergyPerGram; // Bridging ratio

    // Always add the 'g' unit now that our base is per-gram
    units.add(
      model_unit.FoodServing(
        id: null,
        foodId: 0,
        unit: 'g',
        grams: 1.0,
        quantity: 1.0,
      ),
    );

    // Add units from parsed serving size (and imported serving size)
    for (final item in allParsedItems) {
      final quantity = item.$1;
      final unit = item.$2;

      double? gramsPerPortion;

      // Check if it's a known mass unit
      final massGrams = toGrams(1.0, unit);
      if (massGrams != null) {
        gramsPerPortion = massGrams;
      } else {
        // Check if it's a known volume unit
        final volMl = toMilliliters(1.0, unit);
        if (volMl != null) {
          gramsPerPortion = volMl; // 1ml ~ 1g
        }
      }

      if (gramsPerPortion != null) {
        // It's a standard unit (e.g. oz, cup). Add it.
        if (!units.any((u) => u.unit == unit)) {
          units.add(
            model_unit.FoodServing(
              id: null,
              foodId: 0,
              unit: unit,
              grams: gramsPerPortion,
              quantity: quantity,
            ),
          );
        }
      } else {
        // It's an abstract unit (e.g. "slice", "bar").
        // We need to determine its weight.
        // If we have a known servingGrams for the whole string, we can infer.
        // Assumption: The entire serving string corresponds to `servingGrams`.
        // So "1 slice (28g)" -> 1 slice = 28g.
        // "2 cookies (50g)" -> 2 cookies = 50g -> 1 cookie = 25g.

        if (portionGrams != null && portionGrams > 0) {
          final calculatedGrams = portionGrams / quantity;
          if (!units.any((u) => u.unit == unit)) {
            units.add(
              model_unit.FoodServing(
                id: null,
                foodId: 0,
                unit: unit,
                grams: calculatedGrams,
                quantity: quantity,
              ),
            );
          }
        } else {
          // Try calorie bridging if servingGrams wasn't found (e.g. only 100g anchor)
          final portionEnergy = nutriments.getValue(
            Nutrient.energyKCal,
            PerSize.serving,
          );
          if (portionEnergy != null && caloriesPerGram > 0) {
            final bridgedGrams = portionEnergy / caloriesPerGram;
            final perUnitGrams = bridgedGrams / quantity;
            if (!units.any((u) => u.unit == unit)) {
              units.add(
                model_unit.FoodServing(
                  id: null,
                  foodId: 0,
                  unit: unit,
                  grams: perUnitGrams,
                  quantity: quantity,
                ),
              );
            }
          }
        }
      }
    }

    // Ensure units list is not empty
    if (units.isEmpty) {
      // This should be rare now that we always add 'g'
      return null;
    }

    // Filter out foods where we parsed a serving size but failed to resolve it to grams
    // (e.g. "1 slice" with no mass/volume and no bridging possible)
    if (parsedPortionItems.isNotEmpty && units.length == 1) {
      return null;
    }

    final foodName = product.productName ?? product.genericName;
    if (foodName == null || foodName.isEmpty) return null;

    final emoji = emojiForFoodName(foodName);

    return model.Food(
      id: 0, // Not from our DB
      source: 'off',
      name: foodName,
      emoji: emoji,
      thumbnail: product.imageFrontUrl,
      calories: baseEnergyPerGram,
      protein: baseProteinPerGram,
      fat: baseFatPerGram,
      carbs: baseCarbsPerGram,
      fiber: baseFiberPerGram,
      sourceBarcode: product.barcode,
      servings: units,
      database: model.FoodDatabase.off,
    );
  }
}

List<(double, String)> parsePortionSize(String? portionSizeText) {
  if (portionSizeText == null || portionSizeText.isEmpty) return const [];

  // Regex to capture number and unit.
  // Matches: "25g", "1.5 cup", "1/2 cup" (simplified to decimal for now based on previous code, but let's stick to the plan's regex)
  // The previous regex was: r'(\d+(?:[.,]\d+)?)\s*([a-zA-Z°%]+(?:/?\d*(?:[.,]\d+)?\s*[a-zA-Z°%]+)*)'
  // Simplified per plan: r'(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)'
  // We will use a slightly more robust one to catch "fl oz" or "fl_oz" if pre-processed, but the plan said simplify.
  // Let's stick to the one that works for "25 g", "25g".
  // Note: Added underscore to capture 'fl_oz' if it appears, though usually it's 'fl oz'.
  // Better to handle 'fl oz' by pre-processing or allowing spaces in unit?
  // The aliases map handles 'fl oz' -> 'fl_oz'. So the regex needs to capture 'fl oz'.
  // Let's try: r'(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+(?:\s+[a-zA-Z]+)?)' to capture "fl oz"

  final RegExp robustPattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+(?:\s+[a-zA-Z]+)?)',
  );

  final matches = robustPattern.allMatches(portionSizeText);

  if (matches.isEmpty) return const [];

  // Temporary storage for initial parsing
  final List<(double, String)> parsedItems = [];

  const massAliases = {
    'grams': 'g',
    'gram': 'g',
    'g.': 'g',
    'g': 'g',
    'kgs': 'kg',
    'kilo': 'kg',
    'kilos': 'kg',
    'kilogram': 'kg',
    'kilograms': 'kg',
    'kg': 'kg',
    'oz.': 'oz',
    'ounce': 'oz',
    'ounces': 'oz',
    'oz': 'oz',
    'pound': 'lb',
    'pounds': 'lb',
    'lbs': 'lb',
    'lbf': 'lb',
    'lb': 'lb',
  };

  const Map<String, String> volumeAliases = {
    'milliliter': 'ml',
    'milliliters': 'ml',
    'millilitre': 'ml',
    'millilitres': 'ml',
    'mls': 'ml',
    'ml.': 'ml',
    'ml': 'ml',
    'liter': 'l',
    'liters': 'l',
    'litre': 'l',
    'litres': 'l',
    'l.': 'l',
    'l': 'l',
    'floz': 'fl_oz',
    'fl.oz': 'fl_oz',
    'fl.oz.': 'fl_oz',
    'fl oz': 'fl_oz',
    'fluidounce': 'fl_oz',
    'fluidounces': 'fl_oz',
    'fluid oz': 'fl_oz',
    'fl_oz': 'fl_oz',
    'cups': 'cup',
    'cup.': 'cup',
    'cup': 'cup',
    'tablespoon': 'tbsp',
    'tablespoons': 'tbsp',
    'tbsp.': 'tbsp',
    'tbsp': 'tbsp',
    'teaspoon': 'tsp',
    'teaspoons': 'tsp',
    'tsp.': 'tsp',
    'tsp': 'tsp',
  };

  for (final match in matches) {
    final numberText = match.group(1)!.replaceAll(',', '.');
    final rawQuantity = double.tryParse(numberText);
    var rawUnit = match
        .group(2)!
        .toLowerCase()
        .trim(); // trim to remove trailing space from regex
    if (rawQuantity != null) {
      parsedItems.add((rawQuantity, rawUnit));
    }
  }

  bool hasUnambiguousMass = false;
  bool hasUnambiguousVolume = false;

  for (final item in parsedItems) {
    final unit = item.$2;
    final massUnit = massAliases[unit];
    final volumeUnit = volumeAliases[unit];

    if (volumeUnit != null) {
      hasUnambiguousVolume = true;
    } else if (massUnit != null && massUnit != 'oz') {
      // 'oz' is ambiguous, so it doesn't count as "unambiguous mass" for context
      hasUnambiguousMass = true;
    }
  }

  final List<(double, String)> results = [];
  bool finalHasMass = false;
  bool finalHasVolume = false;

  for (final item in parsedItems) {
    final quantity = item.$1;
    final rawUnit = item.$2;
    var massUnit = massAliases[rawUnit];
    var volumeUnit = volumeAliases[rawUnit];

    if (massUnit == 'oz') {
      // It's an oz variant. Resolve ambiguity.
      if (hasUnambiguousVolume && !hasUnambiguousMass) {
        // Treat as volume (fl_oz)
        results.add((quantity, 'fl_oz'));
        finalHasVolume = true;
      } else {
        // Treat as mass (oz)
        results.add((quantity, 'oz'));
        finalHasMass = true;
      }
    } else if (massUnit != null) {
      results.add((quantity, massUnit));
      finalHasMass = true;
    } else if (volumeUnit != null) {
      results.add((quantity, volumeUnit));
      finalHasVolume = true;
    } else {
      // Abstract unit - preserve it
      results.add((quantity, rawUnit));
    }
  }

  // Normalization: Ensure 'g' exists if Mass exists
  if (finalHasMass) {
    bool gExists = results.any((pair) => pair.$2 == 'g');
    if (!gExists) {
      // Find the first mass entry to convert
      final massEntry = results.firstWhere(
        (pair) => massAliases.values.contains(pair.$2),
      );
      final gValue = toGrams(massEntry.$1, massEntry.$2);
      if (gValue != null) {
        results.add((gValue, 'g'));
      }
    }
  }

  // Normalization: Ensure 'ml' exists if Volume exists
  if (finalHasVolume) {
    bool mlExists = results.any((pair) => pair.$2 == 'ml');
    if (!mlExists) {
      // Find the first volume entry to convert
      final volumeEntry = results.firstWhere(
        (pair) => volumeAliases.values.contains(pair.$2),
      );
      final mlValue = toMilliliters(volumeEntry.$1, volumeEntry.$2);
      if (mlValue != null) {
        results.add((mlValue, 'ml'));
      }
    }
  }

  return results;
}

/// Converts a mass value into grams.
/// Supported units: g, kg, oz, lb.
/// Unknown or unconvertible units return null.
double? toGrams(double quantity, String unit) {
  switch (unit.toLowerCase()) {
    case 'g':
      return quantity;
    case 'kg':
      return quantity * 1000.0;
    case 'oz':
      return quantity * 28.3495;
    case 'lb':
      return quantity * 453.592;
    default:
      return null; // unknown unit
  }
}

/// Converts a volume value into milliliters.
/// Supported units: ml, l, fl oz, cup, tbsp, tsp.
/// Unknown or unconvertible units return null.
double? toMilliliters(double quantity, String unit) {
  switch (unit.toLowerCase()) {
    case 'ml':
      return quantity;
    case 'l':
      return quantity * 1000.0;
    case 'fl_oz':
      return quantity * 29.5735;
    case 'cup':
      return quantity * 240.0;
    case 'tbsp':
      return quantity * 15.0;
    case 'tsp':
      return quantity * 5.0;
    default:
      return null; // unknown unit
  }
}
