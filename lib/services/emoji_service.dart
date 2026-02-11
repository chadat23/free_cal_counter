import 'package:meal_of_record/config/emoji_map.dart';

String emojiForFoodName(String foodName) {
  if (foodName.isEmpty) {
    return '🍴';
  }

  final cleanedName = _cleanFoodName(foodName);
  final sortedKeys = _getSortedKeys();

  // Split into words and try matching from longest suffix to shortest
  // This naturally prioritizes last words ("milk chocolate" → "chocolate")
  final words = cleanedName.split(RegExp(r'\s+'));

  for (int start = 0; start < words.length; start++) {
    final phrase = words.sublist(start).join(' ');

    // Check each key against this phrase
    for (final key in sortedKeys) {
      if (_phraseMatchesKey(phrase, key)) {
        return foodEmojiMap[key] ?? '🍴';
      }
    }
  }

  return '🍴';
}

/// Checks if a phrase matches a key considering plurals and word boundaries
bool _phraseMatchesKey(String phrase, String key) {
  final escapedKey = RegExp.escape(key);

  // 1. Exact match
  if (phrase == key) return true;

  // 2. Plural handling: key + 's' or 'es' (e.g., "banana" matches "bananas")
  //    Must be at a word boundary to prevent "banana" matching "bananasplit"
  final pluralRegex = RegExp('^$escapedKey(?:s|es)?\\b');
  if (pluralRegex.hasMatch(phrase)) return true;

  // 3. Whole word match: key appears as a complete word in the phrase
  //    e.g., "chocolate" appears in "milk chocolate"
  final wordRegex = RegExp(r'\b' + escapedKey + r'\b');
  if (wordRegex.hasMatch(phrase)) return true;

  return false;
}

/// Sorts keys by word count (descending), then by length (descending)
/// This ensures "tuna roll" matches before "tuna" or "roll"
/// and "watermelon" matches before "melon"
List<String>? _cachedSortedKeys;

List<String> _getSortedKeys() {
  if (_cachedSortedKeys != null) {
    return _cachedSortedKeys!;
  }

  _cachedSortedKeys = foodEmojiMap.keys.toList()
    ..sort((a, b) {
      final aWords = a.split(' ').length;
      final bWords = b.split(' ').length;

      if (aWords != bWords) {
        return bWords.compareTo(aWords); // More words first
      }
      return b.length.compareTo(a.length); // Longer first
    });

  return _cachedSortedKeys!;
}

/// Cleans food name by removing descriptors, commas, parentheses, etc.
String _cleanFoodName(String foodName) {
  return foodName
      .toLowerCase()
      .trim()
      .split(',')
      .first
      .trim()
      .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
