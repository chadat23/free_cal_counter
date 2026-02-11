import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/services/database_service.dart';

class DebugSeeder {
  static Future<void> seed() async {
    print('DebugSeeder: Starting seed process...');
    final now = DateTime.now();

    print('DebugSeeder: Checking for existing logs...');
    final todayLogs = await DatabaseService.instance.getLoggedPortionsForDate(
      now,
    );
    print('DebugSeeder: Found ${todayLogs.length} logs for today.');

    if (todayLogs.isNotEmpty) {
      print('DebugSeeder: Logs already exist for today. Skipping seed.');
      return;
    }

    print('DebugSeeder: Seeding database with test data...');

    // Fetch some foods from the database to log
    // We'll search for common items
    print('DebugSeeder: Searching for "apple"...');
    final foods = await DatabaseService.instance.searchFoodsByName('apple');
    print('DebugSeeder: Found ${foods.length} foods matching "apple".');

    if (foods.isEmpty) {
      print(
        'DebugSeeder: No foods found to seed. Make sure the DB is initialized.',
      );
      return;
    }

    final apple = foods.first;

    // Create portions for Today
    final todayPortions = [FoodPortion(food: apple, grams: 150, unit: 'g')];

    // Create portions for Yesterday
    final yesterdayPortions = [FoodPortion(food: apple, grams: 100, unit: 'g')];

    print('DebugSeeder: Logging today portions...');
    await DatabaseService.instance.logPortions(todayPortions, now);
    print('DebugSeeder: Today portions logged.');

    print('DebugSeeder: Logging yesterday portions...');
    await DatabaseService.instance.logPortions(
      yesterdayPortions,
      now.subtract(const Duration(days: 1)),
    );
    print('DebugSeeder: Yesterday portions logged.');

    print('DebugSeeder: Seeding complete.');
  }
}
