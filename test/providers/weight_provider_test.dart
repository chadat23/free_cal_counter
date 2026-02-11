import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meal_of_record/providers/weight_provider.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/models/weight.dart';

import 'weight_provider_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late WeightProvider weightProvider;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    weightProvider = WeightProvider(databaseService: mockDatabaseService);
  });

  group('WeightProvider', () {
    test('loadWeights should update state and notify listeners', () async {
      final weights = [
        Weight(weight: 70.0, date: DateTime(2023, 1, 1)),
        Weight(weight: 71.0, date: DateTime(2023, 1, 2)),
      ];
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 1, 2);

      when(
        mockDatabaseService.getWeightsForRange(start, end),
      ).thenAnswer((_) async => weights);

      await weightProvider.loadWeights(start, end);

      expect(weightProvider.weights, weights);
      expect(weightProvider.isLoading, false);
      verify(mockDatabaseService.getWeightsForRange(start, end)).called(1);
    });

    test('saveWeight should update local state and call database', () async {
      final date = DateTime(2023, 1, 1);

      when(mockDatabaseService.saveWeight(any)).thenAnswer((_) async => {});

      await weightProvider.saveWeight(75.5, date);

      expect(weightProvider.weights.length, 1);
      expect(weightProvider.weights.first.weight, 75.5);
      verify(mockDatabaseService.saveWeight(any)).called(1);
    });

    test('hasWeightToday should return correct status', () async {
      final now = DateTime.now();
      final weights = [Weight(weight: 70.0, date: now)];

      final start = DateTime(now.year, now.month, now.day);
      when(
        mockDatabaseService.getWeightsForRange(any, any),
      ).thenAnswer((_) async => weights);

      await weightProvider.loadWeights(start, now);
      expect(weightProvider.hasWeightToday, true);
    });
  });
}
