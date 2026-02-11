import 'package:flutter/foundation.dart';
import 'package:meal_of_record/services/backup_config_service.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/google_drive_service.dart';

/// Attempts an automatic cloud backup if all conditions are met:
/// enabled, signed in, data is dirty, and 24h+ since last backup.
///
/// If [force] is true, skips the dirty and cooldown checks (used when
/// the user first enables auto-backup).
///
/// Runs silently — logs via debugPrint but never throws.
Future<bool> tryAutoBackup({
  BackupConfigService? configService,
  GoogleDriveService? driveService,
  bool force = false,
}) async {
  final config = configService ?? BackupConfigService.instance;
  final drive = driveService ?? GoogleDriveService.instance;

  try {
    final isEnabled = await config.isAutoBackupEnabled();
    if (!isEnabled) {
      debugPrint('tryAutoBackup: Auto backup disabled. Skipping.');
      return false;
    }

    if (!force) {
      final isDirty = await config.isDirty();
      if (!isDirty) {
        debugPrint('tryAutoBackup: Database not dirty. Skipping.');
        return false;
      }

      final lastBackup = await config.getLastBackupTime();
      if (lastBackup != null) {
        final elapsed = DateTime.now().difference(lastBackup);
        if (elapsed < const Duration(hours: 24)) {
          debugPrint(
            'tryAutoBackup: Last backup was ${elapsed.inHours}h ago. Skipping.',
          );
          return false;
        }
      }
    }

    final account = await drive.refreshCurrentUser();
    if (account == null) {
      debugPrint('tryAutoBackup: Not signed in to Google. Skipping.');
      return false;
    }

    debugPrint('tryAutoBackup: Starting backup...');
    final zipFile = await DatabaseService.instance.exportBackupAsZip();

    final retention = await config.getRetentionCount();
    final success = await drive.uploadBackup(
      zipFile,
      retentionCount: retention,
    );

    // Clean up temp zip
    try {
      await zipFile.delete();
    } catch (_) {}

    if (success) {
      await config.clearDirty();
      await config.updateLastBackupTime();
      debugPrint('tryAutoBackup: Backup successful!');
      return true;
    } else {
      debugPrint('tryAutoBackup: Upload failed.');
      return false;
    }
  } catch (e) {
    debugPrint('tryAutoBackup: Error: $e');
    return false;
  }
}
