import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:meal_of_record/data/database/tables.dart';

part 'reference_database.g.dart';

@DriftDatabase(tables: [Foods, FoodPortions])
class ReferenceDatabase extends _$ReferenceDatabase {
  ReferenceDatabase({required QueryExecutor connection}) : super(connection);

  @override
  int get schemaVersion => 1;
}

const int kCurrentReferenceDbVersion =
    1; // Increment this when updating assets/reference.db

QueryExecutor openReferenceConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reference.db'));
    final versionFile = File(p.join(dbFolder.path, '.reference.version'));

    bool needsUpdate = false;
    if (!await file.exists()) {
      needsUpdate = true;
    } else {
      int version = 0;
      if (await versionFile.exists()) {
        final versionStr = await versionFile.readAsString();
        version = int.tryParse(versionStr) ?? 0;
      }
      if (version < kCurrentReferenceDbVersion) {
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      final blob = await rootBundle.load('assets/reference.db');
      final buffer = blob.buffer;
      await file.writeAsBytes(
        buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes),
        flush: true,
      );
      await versionFile.writeAsString(kCurrentReferenceDbVersion.toString());
    }

    return NativeDatabase(file);
  });
}
