import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/utils/math_evaluator.dart';

void main() {
  group('MathEvaluator', () {
    test('evaluates simple addition', () {
      expect(MathEvaluator.evaluate('1+1'), 2.0);
      expect(MathEvaluator.evaluate('10 + 20'), 30.0);
    });

    test('evaluates simple subtraction', () {
      expect(MathEvaluator.evaluate('5-2'), 3.0);
      expect(MathEvaluator.evaluate('10 - 20'), -10.0);
    });

    test('evaluates simple multiplication', () {
      expect(MathEvaluator.evaluate('3*4'), 12.0);
      expect(MathEvaluator.evaluate('2.5 * 2'), 5.0);
    });

    test('evaluates simple division', () {
      expect(MathEvaluator.evaluate('10/2'), 5.0);
      expect(MathEvaluator.evaluate('5 / 2'), 2.5);
    });

    test('evaluates mixed expressions with precedence', () {
      expect(MathEvaluator.evaluate('1 + 2 * 3'), 7.0); // Not 9
      expect(MathEvaluator.evaluate('10 - 5 / 2'), 7.5);
    });

    test('evaluates expressions with parentheses', () {
      expect(MathEvaluator.evaluate('(1 + 2) * 3'), 9.0);
      expect(MathEvaluator.evaluate('10 / (2 + 3)'), 2.0);
    });

    test('handles decimals', () {
      expect(MathEvaluator.evaluate('1.5 + 2.5'), 4.0);
    });

    test('returns null for invalid expressions', () {
      expect(MathEvaluator.evaluate('abc'), isNull);
      expect(MathEvaluator.evaluate('1 + '), isNull);
      expect(
        MathEvaluator.evaluate('1 / 0'),
        double.infinity,
      ); // Dart handles /0 as infinity
    });

    test('handles whitespace', () {
      expect(MathEvaluator.evaluate('  1   +   2  '), 3.0);
    });
  });
}
