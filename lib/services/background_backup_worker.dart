import 'package:flutter/foundation.dart';
import 'package:meal_of_record/services/backup_config_service.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/nas_backup_service.dart';

/// Attempts an automatic NAS backup if all conditions are met:
/// enabled, NAS configured, data is dirty, and 24h+ since last backup.
///
/// If [force] is true, skips the dirty and cooldown checks (used when
/// the user first enables auto-backup).
///
/// Runs silently — logs via debugPrint but never throws.
Future<bool> tryAutoBackup({
  BackupConfigService? configService,
  NasBackupService? nasService,
  bool force = false,
}) async {
  final config = configService ?? BackupConfigService.instance;
  final nas = nasService ?? NasBackupService.instance;

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

    final isConfigured = await config.isNasConfigured();
    if (!isConfigured) {
      debugPrint('tryAutoBackup: NAS not configured. Skipping.');
      return false;
    }

    debugPrint('tryAutoBackup: Starting backup...');
    final zipFile = await DatabaseService.instance.exportBackupAsZip();

    final retention = await config.getRetentionCount();
    final success = await nas.uploadBackup(
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
      await config.recordBackupSuccess();
      debugPrint('tryAutoBackup: Backup successful!');
      return true;
    } else {
      await config.recordBackupFailure();
      debugPrint('tryAutoBackup: Upload failed.');
      return false;
    }
  } catch (e) {
    debugPrint('tryAutoBackup: Error: $e');
    try {
      await config.recordBackupFailure();
    } catch (_) {}
    return false;
  }
}
