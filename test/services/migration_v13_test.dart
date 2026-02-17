import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/services/live_database.dart';
import 'package:drift/native.dart';

/// Runs the migration v13 SQL statements against a live database.
/// We insert pre-migration data via raw SQL, then execute the migration
/// statements directly, then verify results.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late LiveDatabase liveDatabase;

  setUp(() {
    // LiveDatabase at schema v13 will run migrations automatically,
    // so the DB is already at v13. We'll insert test data and then
    // run the migration SQL manually to simulate the migration path.
    liveDatabase = LiveDatabase(connection: NativeDatabase.memory());
  });

  tearDown(() async {
    await liveDatabase.close();
  });

  /// Helper: inserts a food row with specific fields via raw SQL.
  /// Column names match drift schema: sourceBarcode, sourceFdcId, parentId (camelCase).
  Future<void> insertRawFood({
    required int id,
    required String name,
    required String source,
    String? sourceBarcode,
    int? sourceFdcId,
    int? parentId,
  }) async {
    await liveDatabase.customStatement(
      '''INSERT INTO foods (id, name, source, sourceBarcode, sourceFdcId, parentId,
            caloriesPerGram, proteinPerGram, fatPerGram, carbsPerGram, fiberPerGram, hidden)
         VALUES (?, ?, ?, ?, ?, ?, 1.0, 0.1, 0.1, 0.5, 0.05, 0)''',
      [id, name, source, sourceBarcode, sourceFdcId, parentId],
    );
  }

  /// Helper: runs the migration v13 SQL statements using actual column names.
  Future<void> runMigrationV13() async {
    // 1. OFF foods
    await liveDatabase.customStatement('''
      UPDATE foods SET source = 'off'
      WHERE source = 'live'
        AND sourceBarcode IS NOT NULL
        AND sourceFdcId IS NULL
        AND parentId IS NULL
    ''');
    // 2. USDA foods
    await liveDatabase.customStatement('''
      UPDATE foods SET source = 'FOUNDATION'
      WHERE source = 'live'
        AND sourceFdcId IS NOT NULL
        AND parentId IS NULL
    ''');
    // 3. User-created foods
    await liveDatabase.customStatement('''
      UPDATE foods SET source = 'user'
      WHERE source = 'live'
        AND sourceFdcId IS NULL
        AND sourceBarcode IS NULL
        AND parentId IS NULL
        AND name != 'Fasted'
        AND name != 'Quick Add'
    ''');
    // 4. Fix corrupt parentId
    await liveDatabase.customStatement('''
      UPDATE foods SET parentId = NULL
      WHERE parentId IS NOT NULL
        AND parentId NOT IN (SELECT id FROM foods)
    ''');
  }

  /// Helper: reads a food row by id
  Future<Map<String, dynamic>> getRawFood(int id) async {
    final rows = await liveDatabase.customSelect(
      'SELECT * FROM foods WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    return rows.first.data;
  }

  group('migration v13', () {
    test('OFF foods get source=off', () async {
      await insertRawFood(
        id: 1,
        name: 'OFF Cereal',
        source: 'live',
        sourceBarcode: '123',
      );

      await runMigrationV13();

      final food = await getRawFood(1);
      expect(food['source'], 'off');
    });

    test('USDA foods get source=FOUNDATION', () async {
      await insertRawFood(
        id: 1,
        name: 'USDA Broccoli',
        source: 'live',
        sourceFdcId: 100,
      );

      await runMigrationV13();

      final food = await getRawFood(1);
      expect(food['source'], 'FOUNDATION');
    });

    test('User-created foods get source=user', () async {
      await insertRawFood(
        id: 1,
        name: 'My Custom Food',
        source: 'live',
      );

      await runMigrationV13();

      final food = await getRawFood(1);
      expect(food['source'], 'user');
    });

    test('System foods unchanged', () async {
      await insertRawFood(
        id: 1,
        name: 'Fasted',
        source: 'live',
      );

      await runMigrationV13();

      final food = await getRawFood(1);
      // 'Fasted' is excluded from the user-created rule, stays 'live'
      expect(food['source'], 'live');
    });

    test('Corrupt parentId cleared', () async {
      // Disable FK checks to insert corrupt data
      await liveDatabase.customStatement('PRAGMA foreign_keys = OFF');
      await insertRawFood(
        id: 1,
        name: 'Orphan Food',
        source: 'user',
        parentId: 999, // nonexistent parent
      );
      await liveDatabase.customStatement('PRAGMA foreign_keys = ON');

      await runMigrationV13();

      final food = await getRawFood(1);
      expect(food['parentId'], isNull);
    });

    test('Valid parentId preserved', () async {
      await insertRawFood(
        id: 1,
        name: 'Parent Food',
        source: 'user',
      );
      await insertRawFood(
        id: 2,
        name: 'Child Food',
        source: 'user',
        parentId: 1,
      );

      await runMigrationV13();

      final child = await getRawFood(2);
      expect(child['parentId'], 1);
    });
  });
}
