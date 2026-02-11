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
    expect(await service.isAutoBackupEnabled(), isFalse);
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

  // --- NAS Configuration ---

  group('NAS config fields', () {
    test('getNasHost returns null by default', () async {
      final service = BackupConfigService.instance;
      expect(await service.getNasHost(), isNull);
    });

    test('setNasHost and getNasHost round-trip', () async {
      final service = BackupConfigService.instance;
      await service.setNasHost('192.168.1.100');
      expect(await service.getNasHost(), '192.168.1.100');
    });

    test('getNasPort returns null by default', () async {
      final service = BackupConfigService.instance;
      expect(await service.getNasPort(), isNull);
    });

    test('setNasPort stores and retrieves port', () async {
      final service = BackupConfigService.instance;
      await service.setNasPort(5006);
      expect(await service.getNasPort(), 5006);
    });

    test('setNasPort null removes the entry', () async {
      final service = BackupConfigService.instance;
      await service.setNasPort(5006);
      await service.setNasPort(null);
      expect(await service.getNasPort(), isNull);
    });

    test('getNasPath returns null by default', () async {
      final service = BackupConfigService.instance;
      expect(await service.getNasPath(), isNull);
    });

    test('setNasPath and getNasPath round-trip', () async {
      final service = BackupConfigService.instance;
      await service.setNasPath('/backups/meal_of_record');
      expect(await service.getNasPath(), '/backups/meal_of_record');
    });

    test('getNasUseHttps defaults to true', () async {
      final service = BackupConfigService.instance;
      expect(await service.getNasUseHttps(), isTrue);
    });

    test('setNasUseHttps updates value', () async {
      final service = BackupConfigService.instance;
      await service.setNasUseHttps(false);
      expect(await service.getNasUseHttps(), isFalse);
    });

    test('getNasAllowSelfSigned defaults to false', () async {
      final service = BackupConfigService.instance;
      expect(await service.getNasAllowSelfSigned(), isFalse);
    });

    test('setNasAllowSelfSigned updates value', () async {
      final service = BackupConfigService.instance;
      await service.setNasAllowSelfSigned(true);
      expect(await service.getNasAllowSelfSigned(), isTrue);
    });
  });

  // --- Failure Tracking ---

  group('Failure tracking', () {
    test('getConsecutiveFailures defaults to 0', () async {
      final service = BackupConfigService.instance;
      expect(await service.getConsecutiveFailures(), 0);
    });

    test('recordBackupFailure increments counter', () async {
      final service = BackupConfigService.instance;
      await service.recordBackupFailure();
      expect(await service.getConsecutiveFailures(), 1);
      await service.recordBackupFailure();
      expect(await service.getConsecutiveFailures(), 2);
      await service.recordBackupFailure();
      expect(await service.getConsecutiveFailures(), 3);
    });

    test('recordBackupSuccess resets counter to 0', () async {
      final service = BackupConfigService.instance;
      await service.recordBackupFailure();
      await service.recordBackupFailure();
      expect(await service.getConsecutiveFailures(), 2);

      await service.recordBackupSuccess();
      expect(await service.getConsecutiveFailures(), 0);
    });
  });

  // --- isNasConfigured ---
  // Note: isNasConfigured also checks secure storage credentials.
  // Since FlutterSecureStorage requires platform channels, we only test
  // the SharedPreferences portion here. Integration tests with a mock
  // secure storage would cover the full isNasConfigured path.
}
