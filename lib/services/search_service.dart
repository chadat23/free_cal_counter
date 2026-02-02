import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import 'package:free_cal_counter1/models/food.dart' as model;
import 'package:free_cal_counter1/models/recipe.dart' as model;
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/services/open_food_facts_service.dart';
import 'package:free_cal_counter1/services/food_sorting_service.dart';

class SearchService {
  final DatabaseService databaseService;
  final OffApiService offApiService;
  final String Function(String) emojiForFoodName;
  final FoodSortingService sortingService;

  SearchService({
    required this.databaseService,
    required this.offApiService,
    required this.emojiForFoodName,
    required this.sortingService,
  });

  // Helper function to apply fuzzy matching and sorting
  List<model.Food> _applyFuzzyMatching(String query, List<model.Food> foods) {
    if (query.isEmpty || foods.isEmpty) {
      return [];
    }
    final lowerCaseQuery = query.toLowerCase();

    // Score each food based on match quality
    final scoredFoods = foods.map((food) {
      final lowerCaseName = food.name.toLowerCase();
      int score;

      if (lowerCaseName == lowerCaseQuery) {
        score = 0; // Exact match = perfect score
      } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
        score = 1; // Starts with = very high score
      } else if (lowerCaseName.contains(' $lowerCaseQuery')) {
        score = 2; // Contains as whole word = high score
      } else {
        // Use token set ratio for everything else.
        // We subtract from 100 because a higher ratio is better, but a lower sort score is better.
        score = 100 - fuzzy.tokenSetRatio(lowerCaseName, lowerCaseQuery);
      }
      return {'food': food, 'score': score};
    }).toList();

    // Sort by score (lower is better), then alphabetically as a tie-breaker
    scoredFoods.sort((a, b) {
      final scoreA = a['score'] as int;
      final scoreB = b['score'] as int;
      if (scoreA != scoreB) {
        return scoreA.compareTo(scoreB);
      }
      return (a['food'] as model.Food).name.toLowerCase().compareTo(
        (b['food'] as model.Food).name.toLowerCase(),
      );
    });

    final sortedFoods = scoredFoods
        .map((e) => e['food'] as model.Food)
        .toList();

    // Map back to list of foods and limit to a reasonable number
    return sortedFoods.take(50).toList();
  }

  Future<List<model.Food>> searchLocal(String query, {int? categoryId}) async {
    if (query.isEmpty) {
      if (categoryId != null) {
        return searchRecipesOnly(query, categoryId: categoryId);
      }
      return [];
    }

    // 1. Query live and reference databases separately
    final liveFoods = await databaseService.searchLiveFoodsByName(query);
    final referenceFoods = await databaseService.searchReferenceFoodsByName(
      query,
    );

    // 2. Get usage statistics for live foods
    final liveFoodIds = liveFoods.map((f) => f.id).toList();
    final foodUsageStats = await databaseService.getFoodUsageStats(liveFoodIds);

    // 3. Filter reference foods that have live versions
    final filteredReferenceFoods = await databaseService
        .filterReferenceFoodsWithLiveVersions(referenceFoods, liveFoods);

    // 4. Sort live foods with complex weighted algorithm
    final sortedLiveFoods = sortingService.sortLiveFoods(
      liveFoods,
      foodUsageStats,
      query,
    );

    // 5. Sort reference foods with fuzzy matching
    final sortedReferenceFoods = sortingService.sortReferenceFoods(
      filteredReferenceFoods,
      query,
    );

    // 6. Combine results: strictly Live first, then Reference
    // Recipes are excluded from general search per requirements
    final combinedResults = [...sortedLiveFoods, ...sortedReferenceFoods];

    // 7. Limit to a reasonable number to avoid UI lag
    final limitedResults = combinedResults.take(50).toList();

    // 8. Add usage notes and emojis
    final usageNotes = await databaseService.getFoodsUsageNotes(limitedResults);

    final resultsWithEmoji = limitedResults
        .map(
          (food) => food.copyWith(
            emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
                ? emojiForFoodName(food.name)
                : food.emoji,
            usageNote: usageNotes[food.id],
          ),
        )
        .toList();

    return resultsWithEmoji;
  }

  Future<List<model.Food>> searchOff(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final offResults = await offApiService.searchFoodsByName(query);
    final usageNotes = await databaseService.getFoodsUsageNotes(offResults);

    final resultsWithEmoji = offResults
        .map(
          (food) => food.copyWith(
            emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
                ? emojiForFoodName(food.name)
                : food.emoji,
            usageNote: usageNotes[food.id],
          ),
        )
        .toList();
    return _applyFuzzyMatching(query, resultsWithEmoji);
  }

  Future<List<model.Food>> getAllRecipesAsFoods({int? categoryId}) async {
    final recipes = await databaseService.getRecipesBySearch(
      '',
      categoryId: categoryId,
    );
    final foods = recipes.map((r) => r.toFood()).toList();
    final usageNotes = await databaseService.getFoodsUsageNotes(foods);

    // Map recipes to foods
    final resultsWithEmoji = foods.map((food) {
      return food.copyWith(
        emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
            ? emojiForFoodName(food.name)
            : food.emoji,
        usageNote: usageNotes[food.id],
      );
    }).toList();

    return resultsWithEmoji;
  }

  Future<List<model.Food>> searchRecipesOnly(
    String query, {
    int? categoryId,
  }) async {
    // 1. Get recipes from DB
    final recipeResults = await databaseService.getRecipesBySearch(
      query,
      categoryId: categoryId,
    );

    // 2. Get usage statistics for recipes
    final recipeIds = recipeResults.map((r) => r.id).toList();
    final recipeUsageStats = await databaseService.getRecipeUsageStats(
      recipeIds,
    );

    // 3. Sort recipes with weighted algorithm (Fuzzy + Usage)
    final sortedRecipes = sortingService.sortRecipes(
      recipeResults,
      recipeUsageStats,
      query,
    );

    final foods = sortedRecipes.map((r) => r.toFood()).toList();

    // 4. Limit to avoid UI lag
    final limitedResults = foods.take(50).toList();

    // 5. Add usage notes and emojis
    final usageNotes = await databaseService.getFoodsUsageNotes(limitedResults);

    final resultsWithEmoji = limitedResults.map((food) {
      return food.copyWith(
        emoji: (food.emoji == null || food.emoji == '🍴' || food.emoji == '')
            ? emojiForFoodName(food.name)
            : food.emoji,
        usageNote: usageNotes[food.id],
      );
    }).toList();

    return resultsWithEmoji;
  }
}
