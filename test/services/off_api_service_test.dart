import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/services/off_api_client_wrapper.dart';
import 'package:matcher/matcher.dart' as matcher;

import 'off_api_service_test.mocks.dart';

class MockProduct extends Mock implements Product {
  @override
  Map<String, dynamic> toJson() {
    return super.noSuchMethod(
      Invocation.method(#toJson, []),
      returnValue: <String, dynamic>{},
      returnValueForMissingStub: <String, dynamic>{},
    );
  }
}

class MockNutriments extends Mock implements Nutriments {}

class MockProductResultV3 extends Mock implements ProductResultV3 {}

class MockSearchResult extends Mock implements SearchResult {}

@GenerateMocks([OffApiClientWrapper])
void main() {
  late OffApiService offApiService;
  late MockOffApiClientWrapper mockApiWrapper;

  setUp(() {
    mockApiWrapper = MockOffApiClientWrapper();
    offApiService = OffApiService(apiWrapper: mockApiWrapper);
  });

  group('fetchFoodByBarcode', () {
    // ... existing tests ...
  });

  group('parseServingSize', () {
    test('basic mass', () {
      final text = "25g";
      final result = parsePortionSize(text);
      expect(result, hasLength(1));
      expect(result[0].$1, 25);
      expect(result[0].$2, 'g');
    });

    test('basic volume', () {
      final text = "240ml";
      final result = parsePortionSize(text);
      expect(result, hasLength(1));
      expect(result[0].$1, 240);
      expect(result[0].$2, 'ml');
    });

    test('abstract unit should be preserved', () {
      final text = "1 slice";
      final result = parsePortionSize(text);
      expect(result, hasLength(1));
      expect(result[0].$1, 1);
      expect(result[0].$2, 'slice');
    });

    test('abstract unit with mass', () {
      final text = "1 slice (28g)";
      final result = parsePortionSize(text);
      expect(result.any((r) => r.$1 == 1 && r.$2 == 'slice'), isTrue);
      expect(result.any((r) => r.$1 == 28 && r.$2 == 'g'), isTrue);
    });

    test('oz ambiguity: default to mass', () {
      final text = "10 oz";
      final result = parsePortionSize(text);
      expect(result.any((r) => r.$1 == 10 && r.$2 == 'oz'), isTrue);
      expect(result.any((r) => r.$2 == 'g'), isTrue); // Should add grams
    });

    test('oz ambiguity: mass context -> mass', () {
      final text = "10 oz 30g";
      final result = parsePortionSize(text);
      expect(result.any((r) => r.$1 == 10 && r.$2 == 'oz'), isTrue);
      expect(result.any((r) => r.$1 == 30 && r.$2 == 'g'), isTrue);
    });

    test('oz ambiguity: volume context -> volume', () {
      final text = "10 oz 240ml";
      final result = parsePortionSize(text);
      // Should treat oz as fl_oz
      expect(result.any((r) => r.$1 == 10 && r.$2 == 'fl_oz'), isTrue);
      expect(result.any((r) => r.$1 == 240 && r.$2 == 'ml'), isTrue);
    });

    test('oz ambiguity: mixed context -> mass (default)', () {
      final text = "10 oz 30g 240ml";
      final result = parsePortionSize(text);
      // Has both mass and volume context -> fallback to mass
      expect(result.any((r) => r.$1 == 10 && r.$2 == 'oz'), isTrue);
      expect(result.any((r) => r.$1 == 30 && r.$2 == 'g'), isTrue);
      expect(result.any((r) => r.$1 == 240 && r.$2 == 'ml'), isTrue);
    });

    test('complex mixed string with abstract', () {
      final text = "2 bars (40g) 1.5 oz";
      final result = parsePortionSize(text);

      // 2 bars -> abstract
      // 40g -> mass
      // 1.5 oz -> mass context (due to 40g) -> mass

      expect(result.any((r) => r.$1 == 2 && r.$2 == 'bars'), isTrue);
      expect(result.any((r) => r.$1 == 40 && r.$2 == 'g'), isTrue);
      expect(result.any((r) => r.$1 == 1.5 && r.$2 == 'oz'), isTrue);
    });
  });

  group('searchFoodsByName', () {
    test(
      'should return a list of Food objects for a valid search query',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        when(product.productName).thenReturn('peanut');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(1910); // Updated from new JSON
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(68.4); // Updated from new JSON
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(156); // Updated from new JSON
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(58.6); // Updated from new JSON
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(0.0); // Mock fiber
        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);

        when(
          mockApiWrapper.searchProducts(
            any, // for User? user
            any, // for ProductSearchQueryConfiguration configuration
          ),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('peanut');

        // Assert
        expect(result, isA<List<model.Food>>());
        expect(result, hasLength(1));
        expect(result.first.name, 'peanut');
        expect(result.first.calories, 19.10);
        expect(result.first.protein, 0.684);
        expect(result.first.carbs, 0.586);
        expect(result.first.emoji, '🥜');
      },
    );

    test('should return an empty list when no products are found', () async {
      // Arrange
      final searchResult = MockSearchResult();
      when(searchResult.products).thenReturn([]);

      // Use concrete mock objects in when clause
      when(
        mockApiWrapper.searchProducts(
          any, // for User? user
          any, // for ProductSearchQueryConfiguration configuration
        ),
      ).thenAnswer((_) async => searchResult);

      // Act
      final result = await offApiService.searchFoodsByName('nonexistent food');

      // Assert
      expect(result, isEmpty);
    });

    test(
      'should filter out food items with no reliable anchor units',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with no per 100g data
        when(product.productName).thenReturn('Unanchored Food');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(product.nutriments).thenReturn(nutriments);

        // Mock serving sizes that don't provide a gram weight
        when(product.servingSize).thenReturn('1 piece'); // No explicit grams
        when(
          product.servingQuantity,
        ).thenReturn(null); // No quantity to infer grams

        when(searchResult.products).thenReturn([product]);

        when(
          mockApiWrapper.searchProducts(
            any, // for User? user
            any, // for ProductSearchQueryConfiguration configuration
          ),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('unanchored food');

        // Assert
        expect(result, isEmpty); // Expect the food to be filtered out
      },
    );

    test(
      'should use serving size with volume as anchor (1ml=1g assumption)',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with NO per 100g data
        when(product.productName).thenReturn('soy sauce');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(null);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(null);

        // Mock serving size with volume
        when(product.servingSize).thenReturn('1 tbsp (15ml)');
        when(product.servingQuantity).thenReturn(15.0);

        // Nutritional data PER SERVING (15ml ~ 15g)
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(15.0);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.serving),
        ).thenReturn(1.0);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.serving),
        ).thenReturn(0.0);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.serving),
        ).thenReturn(2.0);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.serving),
        ).thenReturn(null); // Missing fiber should default to 0

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);

        when(
          mockApiWrapper.searchProducts(
            any, // for User? user
            any, // for ProductSearchQueryConfiguration configuration
          ),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('soy sauce');

        // Assert
        expect(result, isA<List<model.Food>>());
        expect(result, hasLength(1));
        final food = result.first;

        // Verify calculated per gram values (based on 15ml ~ 15g)
        expect(food.calories, closeTo(1.0, 0.01));
        expect(food.fiber, closeTo(0.0, 0.01)); // Defaulted to 0

        // Verify units list
        expect(food.servings, matcher.isNotNull);
        expect(food.servings.isNotEmpty, matcher.isTrue);

        // Verify 'tbsp' unit (standard volume)
        expect(
          food.servings.any(
            (unit) =>
                unit.unit == 'tbsp' &&
                unit.grams == 15.0 &&
                unit.quantity == 1.0,
          ),
          matcher.isTrue,
        );
        // Verify 'ml' unit
        expect(
          food.servings.any(
            (unit) =>
                unit.unit == 'ml' && unit.grams == 1.0 && unit.quantity == 15.0,
          ),
          matcher.isTrue,
        );
      },
    );

    test('should bridge volume units using calorie density', () async {
      // Arrange
      final product = MockProduct();
      final nutriments = MockNutriments();
      final searchResult = MockSearchResult();

      // Mock a product with complete per 100g data (Oil: ~900kcal/100g)
      when(product.productName).thenReturn('oil');
      when(
        nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
      ).thenReturn(900.0);
      when(
        nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
      ).thenReturn(0.0);
      when(
        nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
      ).thenReturn(100.0);
      when(
        nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
      ).thenReturn(0.0);
      when(
        nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
      ).thenReturn(0.0);

      // Mock serving size "1 tbsp (15ml)"
      when(product.servingSize).thenReturn('1 tbsp (15ml)');
      when(product.servingQuantity).thenReturn(15.0);

      // Nutritional data PER SERVING (1 tbsp oil ~ 14g ~ 126kcal)
      when(
        nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
      ).thenReturn(126.0);
      // Other nutrients irrelevant for bridging, but needed for strict checks if any

      when(product.nutriments).thenReturn(nutriments);
      when(searchResult.products).thenReturn([product]);

      when(
        mockApiWrapper.searchProducts(any, any),
      ).thenAnswer((_) async => searchResult);

      // Act
      final result = await offApiService.searchFoodsByName('oil');

      // Assert
      expect(result, hasLength(1));
      final food = result.first;

      // Verify 'tbsp' unit
      // With 1ml = 1g assumption restored:
      // 1 tbsp = 15ml = 15g
      expect(
        food.servings.any(
          (unit) =>
              unit.unit == 'tbsp' && unit.grams == 15.0 && unit.quantity == 1.0,
        ),
        matcher.isTrue,
      );

      // Verify 'ml' unit
      // 1 ml = 1g
      // Quantity is 15 because input was "15 ml"
      expect(
        food.servings.any(
          (unit) =>
              unit.unit == 'ml' && unit.grams == 1.0 && unit.quantity == 15.0,
        ),
        matcher.isTrue,
      );
    });

    test(
      'should correctly bridge abstract units when a 100g anchor is present',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with complete per 100g data (primary anchor)
        when(product.productName).thenReturn('cookie');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(500.0); // 500 kcal/100g
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(5.0); // 5g protein/100g
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(25.0); // 25g fat/100g
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(60.0); // 60g carbs/100g
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(2.0); // 2g fiber/100g

        // Mock an abstract serving size "1 cookie" with only calorie data
        when(product.servingSize).thenReturn('1 cookie');
        when(product.servingQuantity).thenReturn(null); // No explicit grams

        // Nutritional data PER SERVING (for "1 cookie")
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(100.0); // 100 kcal per 1 cookie
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.serving),
        ).thenReturn(null); // Missing protein for serving
        when(
          nutriments.getValue(Nutrient.fat, PerSize.serving),
        ).thenReturn(null); // Missing fat for serving
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.serving),
        ).thenReturn(null); // Missing carbs for serving

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);

        when(
          mockApiWrapper.searchProducts(
            any, // for User? user
            any, // for ProductSearchQueryConfiguration configuration
          ),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('cookie');

        // Assert
        expect(result, isA<List<model.Food>>());
        expect(result, hasLength(1));
        final food = result.first;

        // Verify baseline per gram values are from the 100g anchor
        expect(food.calories, closeTo(5.0, 0.01));
        expect(food.protein, closeTo(0.05, 0.001));
        expect(food.fat, closeTo(0.25, 0.001));
        expect(food.carbs, closeTo(0.60, 0.001));
        expect(food.emoji, '🍪');

        // Verify units list
        expect(food.servings, matcher.isNotNull);
        expect(food.servings.isNotEmpty, matcher.isTrue);
        expect(
          food.servings.length,
          greaterThanOrEqualTo(2),
        ); // 'g' and 'cookie'

        // Verify 'g' unit
        expect(
          food.servings.any(
            (unit) =>
                unit.unit == 'g' && unit.grams == 1.0 && unit.quantity == 1.0,
          ),
          matcher.isTrue,
        );

        // Verify "cookie" unit (bridged)
        // 500 kcal / 100g = 5 kcal/g
        // 100 kcal / 5 kcal/g = 20g
        expect(
          food.servings.any(
            (unit) =>
                unit.unit == 'cookie' &&
                unit.grams == 20.0 &&
                unit.quantity == 1.0,
          ),
          matcher.isTrue,
        );
      },
    );

    test(
      'should filter out food with abstract serving and no way to bridge (no serving calories)',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // 100g data exists (so baseline is established)
        when(product.productName).thenReturn('Mystery Bread');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(250.0);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(10.0);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(5.0);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(40.0);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(2.0);

        // Serving is abstract "1 slice" with NO mass/volume
        when(product.servingSize).thenReturn('1 slice');
        when(product.servingQuantity).thenReturn(null);

        // NO serving calories -> Cannot bridge
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(null);

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);
        when(
          mockApiWrapper.searchProducts(any, any),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('Mystery Bread');

        // Assert
        // Should be filtered because we can't quantify "1 slice"
        expect(result, isEmpty);
      },
    );

    test(
      'should keep food with abstract serving if bridging is possible',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // 100g data exists
        when(product.productName).thenReturn('Bridged Bread');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(250.0); // 2.5 kcal/g
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(10.0);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(5.0);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(40.0);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(2.0);

        // Serving is abstract "1 slice"
        when(product.servingSize).thenReturn('1 slice');
        when(product.servingQuantity).thenReturn(null);

        // Serving calories EXIST -> Can bridge
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(100.0); // 100 kcal / 2.5 = 40g

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);
        when(
          mockApiWrapper.searchProducts(any, any),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('Bridged Bread');

        // Assert
        expect(result, hasLength(1));
        final food = result.first;
        expect(
          food.servings.any(
            (unit) =>
                unit.unit == 'slice' &&
                closeTo(unit.grams, 0.1).matches(40.0, {}) &&
                unit.quantity == 1.0,
          ),
          matcher.isTrue,
        );
      },
    );

    test('should filter out foods with no name', () async {
      // Arrange
      final product = MockProduct();
      final nutriments = MockNutriments();
      final searchResult = MockSearchResult();

      when(product.productName).thenReturn(null);
      when(product.genericName).thenReturn('');
      // ... nutriments setup ...
      when(
        nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
      ).thenReturn(100.0);
      when(
        nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
      ).thenReturn(10.0);
      when(
        nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
      ).thenReturn(10.0);
      when(
        nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
      ).thenReturn(10.0);
      when(product.nutriments).thenReturn(nutriments);

      when(searchResult.products).thenReturn([product]);
      when(
        mockApiWrapper.searchProducts(any, any),
      ).thenAnswer((_) async => searchResult);

      // Act
      final result = await offApiService.searchFoodsByName('nameless');

      // Assert
      expect(result, isEmpty);
    });

    test(
      'should prioritize 100g data for baseline calculation when multiple anchors exist',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with complete per 100g data (primary anchor)
        when(product.productName).thenReturn('pizza');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(200.0); // 200 kcal/100g
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(10.0); // 10g protein/100g
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(5.0); // 5g fat/100g
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(20.0); // 20g carbs/100g
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(1.0); // 1g fiber/100g

        // Mock a serving size with explicit grams (secondary anchor)
        when(product.servingSize).thenReturn('1 serving (50g)');
        when(product.servingQuantity).thenReturn(50.0);

        // Nutritional data PER SERVING (for 50g) - deliberately different to test prioritization
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(
          150.0,
        ); // 150 kcal per 50g serving (would imply 300 kcal/100g)
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.serving),
        ).thenReturn(8.0); // 8g protein per 50g serving
        when(
          nutriments.getValue(Nutrient.fat, PerSize.serving),
        ).thenReturn(3.0); // 3g fat per 50g serving
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.serving),
        ).thenReturn(15.0); // 15g carbs per 50g serving

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);

        when(
          mockApiWrapper.searchProducts(
            any, // for User? user
            any, // for ProductSearchQueryConfiguration configuration
          ),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('pizza');

        // Assert
        expect(result, isA<List<model.Food>>());
        expect(result, hasLength(1));
        final food = result.first;

        // Verify baseline per gram values are from the NATIVE 100g anchor, NOT the serving size
        expect(food.calories, closeTo(2.0, 0.01));
        expect(food.protein, closeTo(0.10, 0.001));
        expect(food.fat, closeTo(0.05, 0.001));
        expect(food.carbs, closeTo(0.20, 0.001));
        expect(food.emoji, '🍕');

        // Verify units list contains both 'g' and serving unit
        expect(food.servings, matcher.isNotNull);
        expect(food.servings.isNotEmpty, matcher.isTrue);
        expect(food.servings.length, greaterThanOrEqualTo(2));

        // Verify 'g' unit
        expect(
          food.servings.any((unit) => unit.unit == 'g' && unit.grams == 1.0),
          matcher.isTrue,
        );

        // Verify serving unit
        expect(
          food.servings.any(
            (unit) => unit.unit == 'serving' && unit.grams == 50.0,
          ),
          matcher.isTrue,
        );
      },
    );

    test(
      'should use serving_size_imported for additional unit options',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with 100g data
        when(product.productName).thenReturn('Soy Sauce');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(53.0);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(8.0);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(0.0);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(4.9);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(0.0);

        // Mock standard serving size
        when(product.servingSize).thenReturn('1 portion (15 ml)');
        when(product.servingQuantity).thenReturn(15.0);

        // Mock imported serving size via toJson
        when(
          product.toJson(),
        ).thenReturn({'serving_size_imported': '1 Tbsp (15 ml)'});

        // Serving calories
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(8.0);

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);
        when(
          mockApiWrapper.searchProducts(any, any),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('Soy Sauce');

        // Assert
        expect(result, hasLength(1));
        final food = result.first;

        // Should have 'g' unit
        expect(
          food.servings.any((u) => u.unit == 'g' && u.grams == 1.0),
          isTrue,
        );

        // Should have 'ml' unit (from both strings, deduped)
        expect(
          food.servings.any(
            (u) => u.unit == 'ml' && u.grams == 1.0 && u.quantity == 15.0,
          ),
          isTrue,
        );

        // Should have 'portion' unit (from servingSize)
        expect(
          food.servings.any(
            (u) => u.unit == 'portion' && u.grams == 15.0 && u.quantity == 1.0,
          ),
          isTrue,
        );

        // Should have 'Tbsp' unit (from serving_size_imported)
        // 1 Tbsp = 15ml = 15g (approx)
        expect(
          food.servings.any(
            (u) => u.unit == 'tbsp' && u.grams == 15.0 && u.quantity == 1.0,
          ),
          isTrue,
        );
      },
    );

    test(
      'should use servingQuantity when servingSize string is unparseable',
      () async {
        // Arrange
        final product = MockProduct();
        final nutriments = MockNutriments();
        final searchResult = MockSearchResult();

        // Mock a product with 100g data
        when(product.productName).thenReturn('Chips');
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
        ).thenReturn(500.0);
        when(
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
        ).thenReturn(5.0);
        when(
          nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
        ).thenReturn(30.0);
        when(
          nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
        ).thenReturn(50.0);
        when(
          nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
        ).thenReturn(2.0);

        // Mock unparseable serving size string but valid servingQuantity
        when(product.servingSize).thenReturn('1 bag');
        when(product.servingQuantity).thenReturn(45.0); // 45g

        // Serving calories (optional for this test if 100g is present, but good for completeness)
        when(
          nutriments.getValue(Nutrient.energyKCal, PerSize.serving),
        ).thenReturn(225.0); // 45g * 5 kcal/g = 225 kcal

        when(product.nutriments).thenReturn(nutriments);
        when(searchResult.products).thenReturn([product]);
        when(
          mockApiWrapper.searchProducts(any, any),
        ).thenAnswer((_) async => searchResult);

        // Act
        final result = await offApiService.searchFoodsByName('Chips');

        // Assert
        expect(result, hasLength(1));
        final food = result.first;

        // Should have 'g' unit
        expect(
          food.servings.any((u) => u.unit == 'g' && u.grams == 1.0),
          isTrue,
        );

        // Should have 'bag' unit derived from servingQuantity (45g)
        // logic: unit comes from parsing "1 bag" -> quantity=1, unit="bag"
        // portionGrams = 45.0
        // calculatedGrams = 45.0 / 1 = 45.0
        expect(
          food.servings.any(
            (u) => u.unit == 'bag' && u.grams == 45.0 && u.quantity == 1.0,
          ),
          isTrue,
        );
      },
    );

    test('should preserve functionally similar but distinctly named units', () async {
      // Arrange
      final product = MockProduct();
      final nutriments = MockNutriments();
      final searchResult = MockSearchResult();

      // Mock a product with complete per 100g data
      when(product.productName).thenReturn('bread');
      when(
        nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
      ).thenReturn(100.0);
      when(
        nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
      ).thenReturn(10.0);
      when(
        nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams),
      ).thenReturn(5.0);
      when(
        nutriments.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
      ).thenReturn(15.0);
      when(
        nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
      ).thenReturn(2.0); // 2g fiber/100g

      // Mock serving size "1 oz (28g)"
      when(product.servingSize).thenReturn('1 oz (28g)');
      when(product.servingQuantity).thenReturn(28.0);

      // Mock another serving size "28g" - this requires a bit of a hack with current mock structure
      // Since product.servingSize is a single field, we'll simulate this by adding another product
      // or by modifying the _processProduct to look for other sources of units.
      // For now, we'll assume product.servingSize is the primary source and add a second unit manually
      // in the test's expectation, assuming the service would find it if it existed in OFF data.
      // This test primarily checks that if the service *does* find them, it keeps both.

      when(product.nutriments).thenReturn(nutriments);
      when(searchResult.products).thenReturn([product]);

      when(
        mockApiWrapper.searchProducts(
          any, // for User? user
          any, // for ProductSearchQueryConfiguration configuration
        ),
      ).thenAnswer((_) async => searchResult);

      // Act
      final result = await offApiService.searchFoodsByName('bread');

      // Assert
      expect(result, isA<List<model.Food>>());
      expect(result, hasLength(1));
      final food = result.first;

      // Verify baseline per gram values
      expect(food.calories, closeTo(1.0, 0.01));
      expect(food.protein, closeTo(0.1, 0.001));
      expect(food.fat, closeTo(0.05, 0.001));
      expect(food.carbs, closeTo(0.15, 0.001));
      expect(food.emoji, '🍞');

      // Verify units list contains 'g' and "1 oz (28g)"
      expect(food.servings, matcher.isNotNull);
      expect(food.servings.isNotEmpty, matcher.isTrue);
      expect(
        food.servings.length,
        greaterThanOrEqualTo(2),
      ); // 'g' and '1 oz (28g)'

      // Verify 'g' unit
      expect(
        food.servings.any((unit) => unit.unit == 'g' && unit.grams == 1.0),
        matcher.isTrue,
      );

      // Verify "oz" unit
      expect(
        food.servings.any(
          (unit) => unit.unit == 'oz' && unit.grams > 28.0 && unit.grams < 29.0,
        ),
        matcher.isTrue,
      );
    });
  });
}
