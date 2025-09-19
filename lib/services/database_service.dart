import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/food.dart';
import '../models/food_portion.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the application documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'foods.db');

    // Ensure DB exists and contains the expected table
    await _ensureDatabasePresent(path);

    final db = await openDatabase(path, version: 1);

    // Validate that both tables exist; if not, recopy from assets
    final isValid = await _hasRequiredTables(db);
    if (!isValid) {
      await db.close();
      await _copyDatabaseFromAssets(path, overwrite: true);
      return await openDatabase(path, version: 1);
    }

    return db;
  }

  Future<void> _ensureDatabasePresent(String dstPath) async {
    final file = File(dstPath);
    if (await file.exists()) return;
    await _copyDatabaseFromAssets(dstPath, overwrite: true);
  }

  Future<void> _copyDatabaseFromAssets(
    String dstPath, {
    bool overwrite = false,
  }) async {
    final dstFile = File(dstPath);
    if (await dstFile.exists()) {
      if (!overwrite) return;
      await dstFile.delete();
    }

    // Prefer bundled asset; fall back to local etl file in debug/dev
    try {
      final ByteData data = await rootBundle.load('etl/foods.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dstFile.create(recursive: true);
      await dstFile.writeAsBytes(bytes, flush: true);
      return;
    } catch (_) {
      // Ignore and fall back below
    }

    final sourceFile = File('etl/foods.db');
    if (await sourceFile.exists()) {
      await dstFile.create(recursive: true);
      await sourceFile.copy(dstPath);
      return;
    }

    // Last resort: create empty db so app does not crash
    final database = await openDatabase(dstPath, version: 1);
    await database.close();
  }

  Future<bool> _hasRequiredTables(Database db) async {
    try {
      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('foods','food_portions')",
      );
      final names = rows
          .map((e) => (e['name'] as String?)?.toLowerCase())
          .whereType<String>()
          .toSet();
      return names.contains('foods') && names.contains('food_portions');
    } catch (_) {
      return false;
    }
  }

  Future<List<Food>> searchFoods(String query, {int limit = 20}) async {
    final db = await database;

    if (query.trim().isEmpty) {
      return [];
    }

    // Case-insensitive contains search, prioritized by match position (starts-with first)
    final q = query.trim().toLowerCase();
    final containsPattern = '%$q%';

    final results = await db.rawQuery(
      '''
      SELECT *
      FROM foods
      WHERE is_active = 1
        AND LOWER(description) LIKE ?
      ORDER BY
        INSTR(LOWER(description), ?) ASC,
        description ASC
      LIMIT ?
      ''',
      [containsPattern, q, limit],
    );

    final ids = results.map((e) => e['id'] as int).toList();
    final Map<int, List<FoodPortion>> portionsByFoodId = {};
    if (ids.isNotEmpty) {
      final placeholders = List.filled(ids.length, '?').join(',');
      final portionRows = await db.rawQuery(
        'SELECT * FROM food_portions WHERE food_id IN ($placeholders)',
        ids,
      );
      for (final row in portionRows) {
        final portion = FoodPortion.fromMap(row);
        portionsByFoodId.putIfAbsent(portion.foodId, () => []).add(portion);
      }
    }

    return results.map((map) {
      final portions = portionsByFoodId[map['id'] as int] ?? const [];
      return Food.fromMap(map, portions: portions);
    }).toList();
  }

  Future<List<Food>> getRandomFoods({int limit = 10}) async {
    final db = await database;

    final results = await db.rawQuery(
      'SELECT * FROM foods WHERE is_active = 1 ORDER BY RANDOM() LIMIT ?',
      [limit],
    );

    final ids = results.map((e) => e['id'] as int).toList();
    final Map<int, List<FoodPortion>> portionsByFoodId = {};
    if (ids.isNotEmpty) {
      final placeholders = List.filled(ids.length, '?').join(',');
      final portionRows = await db.rawQuery(
        'SELECT * FROM food_portions WHERE food_id IN ($placeholders)',
        ids,
      );
      for (final row in portionRows) {
        final portion = FoodPortion.fromMap(row);
        portionsByFoodId.putIfAbsent(portion.foodId, () => []).add(portion);
      }
    }

    return results.map((map) {
      final portions = portionsByFoodId[map['id'] as int] ?? const [];
      return Food.fromMap(map, portions: portions);
    }).toList();
  }

  Future<Food?> getFoodById(int id) async {
    final db = await database;

    final results = await db.query(
      'foods',
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Food.fromMap(results.first);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}