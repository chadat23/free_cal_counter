import 'dart:io';
import 'package:flutter/material.dart';
import 'package:free_cal_counter1/services/database_service.dart';
import 'package:free_cal_counter1/widgets/screen_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:free_cal_counter1/services/backup_config_service.dart';
import 'package:free_cal_counter1/services/google_drive_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:free_cal_counter1/services/background_backup_worker.dart';
import 'package:intl/intl.dart';
import 'package:free_cal_counter1/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:free_cal_counter1/providers/goals_provider.dart';

class DataManagementScreen extends StatefulWidget {
  final GoogleDriveService? googleDriveService;
  final BackupConfigService? backupConfigService;

  const DataManagementScreen({
    super.key,
    this.googleDriveService,
    this.backupConfigService,
  });

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isRestoring = false;

  // Cloud Backup State
  bool _isAutoBackupEnabled = false;
  int _retentionCount = 7;
  String? _googleEmail;
  DateTime? _lastBackupTime;
  bool _isLoadingCloudSettings = true;

  late final GoogleDriveService _driveService;
  late final BackupConfigService _backupConfigService;

  @override
  void initState() {
    super.initState();
    _driveService = widget.googleDriveService ?? GoogleDriveService.instance;
    _backupConfigService =
        widget.backupConfigService ?? BackupConfigService.instance;
    _loadCloudSettings();
  }

  Future<void> _loadCloudSettings() async {
    final config = _backupConfigService;
    final drive = _driveService;

    // Try silent sign-in to get email if possible
    final account = await drive.refreshCurrentUser();

    final enabled = await config.isAutoBackupEnabled();
    final retention = await config.getRetentionCount();
    final lastTime = await config.getLastBackupTime();

    if (mounted) {
      setState(() {
        _isAutoBackupEnabled = enabled;
        _retentionCount = retention;
        _lastBackupTime = lastTime;
        _googleEmail = account?.email;
        _isLoadingCloudSettings = false;
      });
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    setState(() => _isLoadingCloudSettings = true);

    try {
      if (value) {
        // Turning ON
        // 1. Ensure Signed In
        var account = _driveService.currentUser;
        if (account == null) {
          debugPrint(
            'DataManagementScreen: Not signed in, requesting sign-in...',
          );
          try {
            account = await _driveService.signIn();
          } catch (e) {
            debugPrint('DataManagementScreen: Sign-in error: $e');
            if (mounted) {
              setState(() {
                _isAutoBackupEnabled = false;
                _isLoadingCloudSettings = false;
              });
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign In Failed'),
                  content: Text(
                    'Unable to sign in to Google Drive.\n\nError: $e\n\nWould you like to try again?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleAutoBackup(true); // Retry
                      },
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              );
            }
            return;
          }

          if (account == null) {
            if (mounted) {
              setState(() {
                _isAutoBackupEnabled = false;
                _isLoadingCloudSettings = false;
              });
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign In Required'),
                  content: const Text(
                    'You need a Google account to enable cloud backup. Would you like to sign in now?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleAutoBackup(true); // Retry
                      },
                      child: const Text('SIGN IN'),
                    ),
                  ],
                ),
              );
            }
            return;
          }

          // Verify sign-in state is properly established
          account = await _driveService.refreshCurrentUser();

          if (account == null) {
            debugPrint('DataManagementScreen: Sign-in verification failed');
            if (mounted) {
              setState(() {
                _isAutoBackupEnabled = false;
                _isLoadingCloudSettings = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Failed to verify Google account. Please try again.',
                  ),
                ),
              );
            }
            return;
          }
        }
        _googleEmail = account.email;
        debugPrint('DataManagementScreen: Signed in as $_googleEmail');

        // 2. Enable Config
        await _backupConfigService.setAutoBackupEnabled(true);

        // 3. Perform first backup immediately
        debugPrint('DataManagementScreen: Running first backup...');
        tryAutoBackup(force: true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cloud backup enabled!')),
          );
        }
      } else {
        // Turning OFF
        debugPrint('DataManagementScreen: Disabling auto-backup...');
        await _backupConfigService.setAutoBackupEnabled(false);
        debugPrint('DataManagementScreen: Auto-backup disabled.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cloud backup disabled.')),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isAutoBackupEnabled = value;
          _isLoadingCloudSettings = false;
        });
      }
    } catch (e, stack) {
      debugPrint('DataManagementScreen: Error toggling backup: $e');
      debugPrint(stack.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update backup settings: $e')),
        );
        setState(() {
          _isLoadingCloudSettings = false;
        });
      }
    }
  }

  Future<void> _updateRetention(double value) async {
    final intVal = value.toInt();
    setState(() => _retentionCount = intVal);
    await _backupConfigService.setRetentionCount(intVal);
  }

  Future<void> _exportBackup() async {
    try {
      setState(
        () => _isRestoring = true,
      ); // Use same loading state or another one
      final zipFile = await DatabaseService.instance.exportBackupAsZip();

      if (await zipFile.exists()) {
        await Share.shareXFiles([
          XFile(
            zipFile.path,
            name:
                'free_cal_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
          ),
        ], text: 'FreeCal Counter Backup (with images)');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database file could not be created.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _backupToCloud() async {
    try {
      setState(() => _isRestoring = true);
      final zipFile = await DatabaseService.instance.exportBackupAsZip();

      final retention = await _backupConfigService.getRetentionCount();
      final success = await _driveService.uploadBackup(
        zipFile,
        retentionCount: retention,
      );

      // Clean up temp zip
      try {
        await zipFile.delete();
      } catch (_) {}

      if (success) {
        await _backupConfigService.clearDirty();
        await _backupConfigService.updateLastBackupTime();
        final lastTime = await _backupConfigService.getLastBackupTime();
        if (mounted) {
          setState(() => _lastBackupTime = lastTime);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cloud backup successful!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cloud backup upload failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cloud backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Backup?'),
          content: const Text(
            'This will overwrite all your current logs and recipes. This action cannot be undone unless you have another backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('RESTORE', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() => _isRestoring = true);
        // Capture provider before async gap
        final goalsProvider = context.read<GoalsProvider>();
        try {
          final backupFile = File(result.files.single.path!);
          await DatabaseService.instance.restoreDatabase(backupFile);
          // Reload goal settings from restored SharedPreferences
          await goalsProvider.reload();
          if (mounted) {
            await UiUtils.showAutoDismissDialog(
              context,
              'Backup restored successfully!',
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
          }
        } finally {
          if (mounted) setState(() => _isRestoring = false);
        }
      }
    }
  }

  Future<void> _restoreFromCloud() async {
    setState(() => _isRestoring = true);
    try {
      final driveService = _driveService;
      final backups = await driveService.listBackups();

      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cloud backups found.')),
          );
        }
        return;
      }

      if (!mounted) return;

      final selectedBackup = await showDialog<drive.File>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Cloud Backup'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final b = backups[index];
                final date = b.createdTime != null
                    ? DateFormat('MM/dd/yyyy HH:mm').format(b.createdTime!)
                    : 'Unknown Date';
                final size = b.size != null
                    ? '${(int.parse(b.size!) / 1024).toStringAsFixed(1)} KB'
                    : 'Unknown Size';

                return ListTile(
                  title: Text(date),
                  subtitle: Text(size),
                  onTap: () => Navigator.pop(context, b),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      );

      if (selectedBackup != null && selectedBackup.id != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Cloud Backup?'),
            content: const Text(
              'This will overwrite all your current logs and recipes. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'RESTORE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Capture provider before async gap
          final goalsProvider = context.read<GoalsProvider>();
          final tempFile = await driveService.downloadBackup(
            selectedBackup.id!,
          );
          if (tempFile != null) {
            await DatabaseService.instance.restoreDatabase(tempFile);
            await tempFile.delete();
            // Reload goal settings from restored SharedPreferences
            await goalsProvider.reload();
            if (mounted) {
              await UiUtils.showAutoDismissDialog(
                context,
                'Cloud backup restored successfully!',
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Download failed.')));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: _isRestoring
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCloudBackupCard(),
                const SizedBox(height: 24),
                const Text(
                  'Manual Backup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: const Icon(Icons.file_upload, color: Colors.blue),
                    title: const Text('Export to File'),
                    subtitle: const Text(
                      'Export database and images as a .zip file.',
                    ),
                    onTap: _exportBackup,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: const Icon(
                      Icons.file_download,
                      color: Colors.green,
                    ),
                    title: const Text('Restore from File'),
                    subtitle: const Text(
                      'Import from a backup .zip or .db file.',
                    ),
                    onTap: _importBackup,
                  ),
                ),
                if (_googleEmail != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(
                        Icons.cloud_upload,
                        color: Colors.orange,
                      ),
                      title: const Text('Backup to Cloud'),
                      subtitle: const Text(
                        'Upload a backup to Google Drive now.',
                      ),
                      onTap: _backupToCloud,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(
                        Icons.cloud_download,
                        color: Colors.orange,
                      ),
                      title: const Text('Restore from Cloud'),
                      subtitle: const Text(
                        'Select a backup to restore from Google Drive.',
                      ),
                      onTap: _restoreFromCloud,
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Note: Restoring data will replace your current recipes and food logs. Make sure you have a backup of your current data if you still need it.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCloudBackupCard() {
    if (_isLoadingCloudSettings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload, color: Colors.orange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Google Drive Backup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: _isAutoBackupEnabled,
                  onChanged: _toggleAutoBackup,
                  activeColor: Colors.orange,
                ),
              ],
            ),
            if (_googleEmail != null)
              Padding(
                padding: const EdgeInsets.only(left: 36.0, bottom: 12.0),
                child: InkWell(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Google Account'),
                        content: Text('Signed in as $_googleEmail'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CLOSE'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _driveService.signOut();
                              _loadCloudSettings();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('SIGN OUT'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Account: $_googleEmail',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 12, color: Colors.blue),
                    ],
                  ),
                ),
              ),

            if (_isAutoBackupEnabled) ...[
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              const Text(
                'Retention Policy',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _retentionCount.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '$_retentionCount days',
                      activeColor: Colors.orange,
                      onChanged: _updateRetention,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_retentionCount',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Text(
                'Backups older than this number of days will be deleted.',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Frequency: Daily',
                style: TextStyle(color: Colors.grey),
              ), // Hardcoded for MVP
            ],

            if (_lastBackupTime != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last successful backup: ${DateFormat('MM/dd HH:mm').format(_lastBackupTime!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
