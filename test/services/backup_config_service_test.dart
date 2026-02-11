import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/services/backup_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('default values are correct', () async {
    final service = BackupConfigService.instance;
    // No init method, values are fetched async
    expect(
      await service.isAutoBackupEnabled(),
      isFalse,
    ); // Default is false per code line 20
    expect(await service.getRetentionCount(), 7);
    expect(await service.getLastBackupTime(), isNull);
    expect(await service.isDirty(), isFalse);
  });

  test('setAutoBackupEnabled updates state and prefs', () async {
    final service = BackupConfigService.instance;

    await service.setAutoBackupEnabled(true);
    expect(await service.isAutoBackupEnabled(), isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('backup_auto_enabled'), isTrue);
  });

  test('setRetentionCount updates state and prefs', () async {
    final service = BackupConfigService.instance;

    await service.setRetentionCount(14);
    expect(await service.getRetentionCount(), 14);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('backup_retention_count'), 14);
  });

  test('markDirty updates state and prefs', () async {
    final service = BackupConfigService.instance;

    await service.markDirty();
    expect(await service.isDirty(), isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('backup_is_dirty'), isTrue);
  });

  test('clearDirty updates state and prefs', () async {
    final service = BackupConfigService.instance;
    await service.markDirty();

    await service.clearDirty();
    expect(await service.isDirty(), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('backup_is_dirty'), isFalse);
  });

  test('updateLastBackupTime updates state and prefs', () async {
    final service = BackupConfigService.instance;

    await service.updateLastBackupTime();
    final time = await service.getLastBackupTime();
    expect(time, isNotNull);

    // Check that it's recent (within last minute)
    final diff = DateTime.now().difference(time!).inSeconds;
    expect(diff, lessThan(60));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('backup_last_time'), isNotNull);
  });
}
