import 'dart:math' as math;

import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_usage_stats.dart';
import 'package:meal_of_record/models/recipe.dart';

class FoodSortingService {
  static String _normalize(String s) =>
      s.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Sort live foods by fuzzy match quality and weighted usage statistics
  /// Logic from llm_context.md 2.1.3.1: weighted considerations of frequency,
  /// recency, and typical time of day.
  List<Food> sortLiveFoods(
    List<Food> foods,
    Map<int, FoodUsageStats>? usageStats,
    String query,
  ) {
    if (foods.isEmpty) return [];

    final now = DateTime.now();
    final currentHour = now.hour;

    final scoredFoods = foods.map((food) {
      final lowerCaseName = _normalize(food.name.toLowerCase());
      final lowerCaseQuery = _normalize(query.toLowerCase());

      // 1. Calculate match score (lower is better)
      // Exact match > starts with > everything else (sorted by usage)
      int fuzzyScore;
      if (lowerCaseName == lowerCaseQuery) {
        fuzzyScore = 0;
      } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
        fuzzyScore = 1;
      } else {
        fuzzyScore = 2;
      }

      // 2. Calculate weighted usage score (higher is better)
      double usageScore = 0.0;
      final stats = usageStats?[food.id];
      if (stats != null) {
        // Time-decayed frequency: each log contributes exp(-days/halfLife)
        // so recent logs count much more than old ones (half-life = 30 days)
        const halfLife = 30.0;
        for (final timestamp in stats.logTimestamps) {
          final daysSince = now.difference(timestamp).inDays;
          usageScore += math.exp(-0.693 * daysSince / halfLife);
        }
        usageScore = usageScore.clamp(0.0, 20.0);

        // Time of day: small bonus if within ±2 hours of typical usage
        final diff = (stats.typicalHour - currentHour).abs();
        if (diff <= 2 || diff >= 22) {
          usageScore += 1.0;
        }
      }

      return {'food': food, 'fuzzyScore': fuzzyScore, 'usageScore': usageScore};
    }).toList();

    // Sort by fuzzyScore (ascending), then usageScore (descending), then alphabetical
    scoredFoods.sort((a, b) {
      final fuzzyA = a['fuzzyScore'] as int;
      final fuzzyB = b['fuzzyScore'] as int;
      if (fuzzyA != fuzzyB) {
        return fuzzyA.compareTo(fuzzyB);
      }

      final usageA = a['usageScore'] as double;
      final usageB = b['usageScore'] as double;
      if ((usageA - usageB).abs() > 0.001) {
        return usageB.compareTo(usageA); // Descending usage
      }

      return (a['food'] as Food).name.toLowerCase().compareTo(
        (b['food'] as Food).name.toLowerCase(),
      );
    });

    return scoredFoods.map((e) => e['food'] as Food).toList();
  }

  /// Sort reference foods with fuzzy matching
  /// Uses same fuzzy matching algorithm as final search
  /// Alphabetical as tie-breaker for same scores
  List<Food> sortReferenceFoods(List<Food> foods, String query) {
    if (query.isEmpty) {
      return _sortAlphabetically(foods);
    }

    return _applyFuzzyMatching(query, foods);
  }

  /// Pre-filter recipes with fuzzy matching, then sort by usage statistics
  /// Alphabetical as tie-breaker for same frequency
  List<Recipe> sortRecipes(
    List<Recipe> recipes,
    Map<int, FoodUsageStats>? usageStats,
    String query,
  ) {
    if (recipes.isEmpty) return [];

    final now = DateTime.now();
    final currentHour = now.hour;

    final scoredRecipes = recipes.map((recipe) {
      final lowerCaseName = _normalize(recipe.name.toLowerCase());
      final lowerCaseQuery = _normalize(query.toLowerCase());

      // 1. Calculate fuzzy match score (lower is better)
      int fuzzyScore = 0;
      if (query.isNotEmpty) {
        if (lowerCaseName == lowerCaseQuery) {
          fuzzyScore = 0;
        } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
          fuzzyScore = 1;
        } else if (lowerCaseName.contains(' $lowerCaseQuery')) {
          fuzzyScore = 2;
        } else {
          fuzzyScore = 100 - fuzzy.tokenSetRatio(lowerCaseName, lowerCaseQuery);
          if (fuzzyScore < 0) fuzzyScore = 0;
          fuzzyScore += 3;
        }
      }

      // 2. Calculate weighted usage score (higher is better)
      double usageScore = 0.0;
      final stats = usageStats?[recipe.id];
      if (stats != null) {
        usageScore += stats.logCount.clamp(0, 50);
        final daysSince = stats.daysSinceLastLogged;
        usageScore += (10.0 / (daysSince + 1.0));

        final diff = (stats.typicalHour - currentHour).abs();
        final hourMatch = diff <= 2 || diff >= 22;
        if (hourMatch) {
          usageScore += 5.0;
        }
      }

      return {
        'recipe': recipe,
        'fuzzyScore': fuzzyScore,
        'usageScore': usageScore,
      };
    }).toList();

    scoredRecipes.sort((a, b) {
      final fuzzyA = a['fuzzyScore'] as int;
      final fuzzyB = b['fuzzyScore'] as int;
      if (fuzzyA != fuzzyB) {
        return fuzzyA.compareTo(fuzzyB);
      }

      final usageA = a['usageScore'] as double;
      final usageB = b['usageScore'] as double;
      if ((usageA - usageB).abs() > 0.001) {
        return usageB.compareTo(usageA);
      }

      return (a['recipe'] as Recipe).name.toLowerCase().compareTo(
        (b['recipe'] as Recipe).name.toLowerCase(),
      );
    });

    return scoredRecipes.map((e) => e['recipe'] as Recipe).toList();
  }

  /// Apply fuzzy matching to foods
  /// Same algorithm as SearchService._applyFuzzyMatching
  List<Food> _applyFuzzyMatching(String query, List<Food> foods) {
    if (query.isEmpty || foods.isEmpty) {
      return [];
    }
    final lowerCaseQuery = _normalize(query.toLowerCase());

    // Score each food based on match quality
    final scoredFoods = foods.map((food) {
      final lowerCaseName = _normalize(food.name.toLowerCase());
      int score;

      if (lowerCaseName == lowerCaseQuery) {
        score = 0; // Exact match = perfect score
      } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
        score = 1; // Starts with = very high score
      } else if (lowerCaseName.contains(' $lowerCaseQuery')) {
        score = 2; // Contains as whole word = high score
      } else {
        // Use token set ratio for everything else
        score = 100 - fuzzy.tokenSetRatio(lowerCaseName, lowerCaseQuery);
      }
      return {'food': food, 'score': score};
    }).toList();

    // Sort by score (lower is better), then alphabetically as tie-breaker
    scoredFoods.sort((a, b) {
      final scoreA = a['score'] as int;
      final scoreB = b['score'] as int;
      if (scoreA != scoreB) {
        return scoreA.compareTo(scoreB);
      }
      return (a['food'] as Food).name.toLowerCase().compareTo(
        (b['food'] as Food).name.toLowerCase(),
      );
    });

    return scoredFoods.map((e) => e['food'] as Food).toList();
  }

  /// Score solo-logged foods by time-of-day proximity and recency.
  /// Returns food IDs sorted descending by total score, limited to [maxResults].
  List<int> scoreSuggestions({
    required List<({int foodId, int logTimestamp})> soloLogs,
    required DateTime now,
    int maxResults = 20,
  }) {
    if (soloLogs.isEmpty) return [];

    final nowHour = now.hour + now.minute / 60.0;
    final Map<int, double> scores = {};

    for (final log in soloLogs) {
      final logTime = DateTime.fromMillisecondsSinceEpoch(log.logTimestamp);

      // Circular time-of-day delta (handles midnight wrapping)
      final logHour = logTime.hour + logTime.minute / 60.0;
      double deltaHours = (nowHour - logHour).abs();
      if (deltaHours > 12) deltaHours = 24 - deltaHours;
      final timeOfDayScore = math.exp(-deltaHours * deltaHours / 18);

      // Recency: fractional days for finer granularity
      final daysSince = now.difference(logTime).inHours / 24.0;
      final recencyScore = math.exp(-0.693 * daysSince / 30);

      final contribution = timeOfDayScore + recencyScore;
      scores[log.foodId] = (scores[log.foodId] ?? 0) + contribution;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.take(maxResults).map((e) => e.key).toList();
  }

  /// Sort foods alphabetically (case-insensitive)
  List<Food> _sortAlphabetically(List<Food> foods) {
    final sorted = List<Food>.from(foods);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }
}
