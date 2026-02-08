import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/services/backup_config_service.dart';
import 'package:free_cal_counter1/services/google_drive_service.dart';
import 'package:free_cal_counter1/services/background_backup_worker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([GoogleDriveService, BackupConfigService, GoogleSignInAccount])
import 'try_auto_backup_test.mocks.dart';

void main() {
  late MockGoogleDriveService mockDrive;
  late MockBackupConfigService mockConfig;

  setUp(() {
    mockDrive = MockGoogleDriveService();
    mockConfig = MockBackupConfigService();
  });

  test('skips when auto-backup is disabled', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => false);

    final result = await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    expect(result, isFalse);
    verifyNever(mockDrive.refreshCurrentUser());
  });

  test('skips when database is not dirty', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    when(mockConfig.isDirty()).thenAnswer((_) async => false);

    final result = await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    expect(result, isFalse);
    verifyNever(mockDrive.refreshCurrentUser());
  });

  test('skips when last backup was less than 24h ago', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    when(mockConfig.isDirty()).thenAnswer((_) async => true);
    when(mockConfig.getLastBackupTime()).thenAnswer(
      (_) async => DateTime.now().subtract(const Duration(hours: 12)),
    );

    final result = await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    expect(result, isFalse);
    verifyNever(mockDrive.refreshCurrentUser());
  });

  test('skips when not signed in to Google', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    when(mockConfig.isDirty()).thenAnswer((_) async => true);
    when(mockConfig.getLastBackupTime()).thenAnswer((_) async => null);
    when(mockDrive.refreshCurrentUser()).thenAnswer((_) async => null);

    final result = await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    expect(result, isFalse);
    verifyNever(mockDrive.uploadBackup(any, retentionCount: anyNamed('retentionCount')));
  });

  test('force=true skips dirty and cooldown checks', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    // Not stubbing isDirty/getLastBackupTime — they shouldn't be called
    when(mockDrive.refreshCurrentUser()).thenAnswer((_) async => null);

    await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
      force: true,
    );

    verifyNever(mockConfig.isDirty());
    verifyNever(mockConfig.getLastBackupTime());
    // Still checks sign-in
    verify(mockDrive.refreshCurrentUser()).called(1);
  });

  test('proceeds when last backup was more than 24h ago', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    when(mockConfig.isDirty()).thenAnswer((_) async => true);
    when(mockConfig.getLastBackupTime()).thenAnswer(
      (_) async => DateTime.now().subtract(const Duration(hours: 25)),
    );
    // Will fail at sign-in, but we verify it gets past the cooldown check
    when(mockDrive.refreshCurrentUser()).thenAnswer((_) async => null);

    await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    verify(mockDrive.refreshCurrentUser()).called(1);
  });

  test('proceeds when no previous backup exists', () async {
    when(mockConfig.isAutoBackupEnabled()).thenAnswer((_) async => true);
    when(mockConfig.isDirty()).thenAnswer((_) async => true);
    when(mockConfig.getLastBackupTime()).thenAnswer((_) async => null);
    when(mockDrive.refreshCurrentUser()).thenAnswer((_) async => null);

    await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    verify(mockDrive.refreshCurrentUser()).called(1);
  });

  test('returns false and does not throw on exceptions', () async {
    when(mockConfig.isAutoBackupEnabled()).thenThrow(Exception('prefs error'));

    final result = await tryAutoBackup(
      configService: mockConfig,
      driveService: mockDrive,
    );

    expect(result, isFalse);
  });
}
