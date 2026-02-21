import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/search_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/screens/recipe_edit_screen.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:drift/native.dart';
import 'package:meal_of_record/services/live_database.dart' as live_db;
import 'package:meal_of_record/services/reference_database.dart' as ref_db;

import 'dump_functionality_test.mocks.dart';

@GenerateMocks([
  LogProvider,
  RecipeProvider,
  SearchProvider,
  NavigationProvider,
  DatabaseService,
])
void main() {
  setUpAll(() async {
    final liveDb = live_db.LiveDatabase(connection: NativeDatabase.memory());
    final refDb = ref_db.ReferenceDatabase(connection: NativeDatabase.memory());
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });
  late MockLogProvider mockLogProvider;
  late MockRecipeProvider mockRecipeProvider;
  late MockSearchProvider mockSearchProvider;
  late MockNavigationProvider mockNavigationProvider;

  final mockFood = Food(
    id: 1,
    name: 'Apple',
    source: 'recipe',
    calories: 0.52,
    protein: 0.003,
    fat: 0.002,
    carbs: 0.14,
    fiber: 0.024,
    servings: [FoodServing(foodId: 1, unit: 'g', grams: 1.0, quantity: 1.0)],
  );

  setUp(() {
    mockLogProvider = MockLogProvider();
    mockRecipeProvider = MockRecipeProvider();
    mockSearchProvider = MockSearchProvider();
    mockNavigationProvider = MockNavigationProvider();

    // Setup defaults
    when(mockRecipeProvider.name).thenReturn('Apple Pie');
    when(mockRecipeProvider.id).thenReturn(1);
    when(mockRecipeProvider.parentId).thenReturn(null);
    when(mockRecipeProvider.servingsCreated).thenReturn(1.0);
    when(mockRecipeProvider.finalWeightGrams).thenReturn(null);
    when(mockRecipeProvider.portionName).thenReturn('portion');
    when(mockRecipeProvider.notes).thenReturn('');
    when(mockRecipeProvider.isTemplate).thenReturn(true);
    when(mockRecipeProvider.items).thenReturn([]);
    when(mockRecipeProvider.selectedCategories).thenReturn([]);
    when(mockRecipeProvider.isLoading).thenReturn(false);
    when(mockRecipeProvider.errorMessage).thenReturn(null);
    when(mockRecipeProvider.caloriesPerPortion).thenReturn(0.0);
    when(mockRecipeProvider.totalCalories).thenReturn(0.0);
    when(mockRecipeProvider.totalProtein).thenReturn(0.0);
    when(mockRecipeProvider.totalFat).thenReturn(0.0);
    when(mockRecipeProvider.totalCarbs).thenReturn(0.0);
    when(mockRecipeProvider.totalFiber).thenReturn(0.0);
    when(mockRecipeProvider.emoji).thenReturn('🍴');
    when(mockRecipeProvider.thumbnail).thenReturn(null);

    when(mockSearchProvider.searchResults).thenReturn([mockFood]);
    when(mockSearchProvider.isLoading).thenReturn(false);

    when(mockNavigationProvider.showConsumed).thenReturn(true);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LogProvider>.value(value: mockLogProvider),
        ChangeNotifierProvider<RecipeProvider>.value(value: mockRecipeProvider),
        ChangeNotifierProvider<SearchProvider>.value(value: mockSearchProvider),
        ChangeNotifierProvider<NavigationProvider>.value(
          value: mockNavigationProvider,
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('RecipeEditScreen shows "Only Dumpable" label', (tester) async {
    await tester.pumpWidget(createTestWidget(const RecipeEditScreen()));

    expect(find.text('Only Dumpable'), findsOneWidget);
  });
}
