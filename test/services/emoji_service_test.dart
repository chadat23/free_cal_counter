import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/services/emoji_service.dart';

void main() {
  group('emojiForFoodName', () {
    test(
      'should return the correct emoji for a food name with a matching keyword',
      () {
        expect(emojiForFoodName('Peanut Butter'), '🧈');
        expect(emojiForFoodName('Milk Chocolate'), '🍫');
        expect(emojiForFoodName('Apple Juice'), '🍎');
        expect(emojiForFoodName('bananas, raw'), '🍌');
      },
    );

    test('should return the default emoji if no keyword is found', () {
      expect(emojiForFoodName('Soy Sauce'), '🍴');
      expect(emojiForFoodName('Ketchup'), '🍴');
    });

    test('should prioritize longer matching phrases over shorter ones', () {
      expect(emojiForFoodName('Tuna Roll'), '🍣');
      expect(emojiForFoodName('Green Apple'), '🍏');
    });

    test('should handle case-insensitivity', () {
      expect(emojiForFoodName('pEaNuT bUtTeR'), '🧈');
      expect(emojiForFoodName('TUNA ROLL'), '🍣');
    });

    test('should return default emoji for empty string', () {
      expect(emojiForFoodName(''), '🍴');
    });

    test('should return the correct emoji for a single word food name', () {
      expect(emojiForFoodName('Apple'), '🍎');
    });
  });
}
