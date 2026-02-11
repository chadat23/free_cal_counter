import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/models/food_container.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/live_database.dart' hide Food;
import 'package:meal_of_record/services/reference_database.dart' hide Food;
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LiveDatabase liveDb;
  late ReferenceDatabase refDb;
  late DatabaseService dbService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    liveDb = LiveDatabase(connection: NativeDatabase.memory());
    refDb = ReferenceDatabase(connection: NativeDatabase.memory());
    dbService = DatabaseService.forTesting(liveDb, refDb);
    // Initialize singleton just in case
    DatabaseService.initSingletonForTesting(liveDb, refDb);
  });

  tearDown(() async {
    await liveDb.close();
    await refDb.close();
  });

  group('Container Management Tests', () {
    test('CRUD operations for containers', () async {
      // Create
      final newContainer = FoodContainer(
        id: 0,
        name: 'Blue Bowl',
        weight: 150.0,
        unit: 'g',
      );
      final id = await dbService.saveContainer(newContainer);
      expect(id, isPositive);

      // Read
      var containers = await dbService.getAllContainers();
      expect(containers.length, 1);
      expect(containers.first.name, 'Blue Bowl');

      // Update
      final updatedContainer = newContainer.copyWith(id: id, weight: 155.0);
      await dbService.saveContainer(updatedContainer);
      containers = await dbService.getAllContainers();
      expect(containers.first.weight, 155.0);

      // Delete
      await dbService.deleteContainer(id);
      containers = await dbService.getAllContainers();
      expect(containers, isEmpty);
    });
  });
}
