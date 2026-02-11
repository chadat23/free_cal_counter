import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/widgets/screen_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meal_of_record/services/backup_config_service.dart';
import 'package:meal_of_record/services/nas_backup_service.dart';
import 'package:meal_of_record/services/background_backup_worker.dart';
import 'package:intl/intl.dart';
import 'package:meal_of_record/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';

class DataManagementScreen extends StatefulWidget {
  final NasBackupService? nasBackupService;
  final BackupConfigService? backupConfigService;

  const DataManagementScreen({
    super.key,
    this.nasBackupService,
    this.backupConfigService,
  });

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isRestoring = false;

  // NAS Backup State
  bool _isAutoBackupEnabled = false;
  int _retentionCount = 7;
  bool _isNasConfigured = false;
  String? _nasDisplayAddress;
  String? _nasConnectionNote;
  DateTime? _lastBackupTime;
  bool _isLoadingSettings = true;

  late final NasBackupService _nasService;
  late final BackupConfigService _backupConfigService;

  @override
  void initState() {
    super.initState();
    _nasService = widget.nasBackupService ?? NasBackupService.instance;
    _backupConfigService =
        widget.backupConfigService ?? BackupConfigService.instance;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final config = _backupConfigService;

    final enabled = await config.isAutoBackupEnabled();
    final retention = await config.getRetentionCount();
    final lastTime = await config.getLastBackupTime();
    final configured = await config.isNasConfigured();

    String? displayAddr;
    String? connNote;
    if (configured) {
      final host = await config.getNasHost();
      final port = await config.getNasPort();
      final path = await config.getNasPath();
      final useHttps = await config.getNasUseHttps();
      final allowSelfSigned = await config.getNasAllowSelfSigned();

      final portStr = port != null ? ':$port' : '';
      displayAddr = '$host$portStr$path';

      if (!useHttps) {
        connNote = 'HTTP';
      } else if (allowSelfSigned) {
        connNote = 'HTTPS (self-signed certificate)';
      } else {
        connNote = 'HTTPS';
      }
    }

    if (mounted) {
      setState(() {
        _isAutoBackupEnabled = enabled;
        _retentionCount = retention;
        _lastBackupTime = lastTime;
        _isNasConfigured = configured;
        _nasDisplayAddress = displayAddr;
        _nasConnectionNote = connNote;
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    if (value && !_isNasConfigured) {
      // Need to configure first
      final configured = await _showNasConfigDialog();
      if (configured != true) return;
    }

    setState(() => _isLoadingSettings = true);

    try {
      await _backupConfigService.setAutoBackupEnabled(value);

      if (value) {
        // Perform first backup immediately
        tryAutoBackup(force: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NAS backup enabled!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NAS backup disabled.')),
          );
        }
      }

      await _loadSettings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update backup settings: $e')),
        );
        setState(() => _isLoadingSettings = false);
      }
    }
  }

  Future<void> _updateRetention(double value) async {
    final intVal = value.toInt();
    setState(() => _retentionCount = intVal);
    await _backupConfigService.setRetentionCount(intVal);
  }

  Future<void> _testConnection() async {
    setState(() => _isRestoring = true);
    try {
      final error = await _nasService.testConnection();
      if (!mounted) return;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<bool?> _showNasConfigDialog() async {
    final config = _backupConfigService;
    final hostController = TextEditingController(
      text: await config.getNasHost() ?? '',
    );
    final portText = await config.getNasPort();
    final portController = TextEditingController(
      text: portText?.toString() ?? '',
    );
    final pathController = TextEditingController(
      text: await config.getNasPath() ?? '/backups/meal_of_record',
    );
    final (existingUser, existingPass) = await config.getNasCredentials();
    final usernameController = TextEditingController(
      text: existingUser ?? '',
    );
    final passwordController = TextEditingController(
      text: existingPass ?? '',
    );
    var useHttps = await config.getNasUseHttps();
    var allowSelfSigned = await config.getNasAllowSelfSigned();

    if (!mounted) return null;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('NAS Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    labelText: 'Server Address',
                    hintText: '192.168.1.100 or nas.local',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: portController,
                  decoration: InputDecoration(
                    labelText: 'Port (optional)',
                    hintText: useHttps ? '443' : '80',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pathController,
                  decoration: const InputDecoration(
                    labelText: 'Backup Folder',
                    hintText: '/backups/meal_of_record',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Use HTTPS'),
                  value: useHttps,
                  onChanged: (v) => setDialogState(() => useHttps = v),
                  contentPadding: EdgeInsets.zero,
                ),
                if (useHttps)
                  SwitchListTile(
                    title: const Text('Allow self-signed certificate'),
                    value: allowSelfSigned,
                    onChanged: (v) =>
                        setDialogState(() => allowSelfSigned = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.wifi_find, size: 18),
                    label: const Text('Test Connection'),
                    onPressed: () async {
                      // Save temporarily to test
                      await _saveNasConfig(
                        hostController.text,
                        portController.text,
                        pathController.text,
                        usernameController.text,
                        passwordController.text,
                        useHttps,
                        allowSelfSigned,
                      );
                      final error = await _nasService.testConnection();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Connection successful!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                await _saveNasConfig(
                  hostController.text,
                  portController.text,
                  pathController.text,
                  usernameController.text,
                  passwordController.text,
                  useHttps,
                  allowSelfSigned,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNasConfig(
    String host,
    String portStr,
    String path,
    String username,
    String password,
    bool useHttps,
    bool allowSelfSigned,
  ) async {
    final config = _backupConfigService;
    await config.setNasHost(host.trim());
    final port = int.tryParse(portStr.trim());
    await config.setNasPort(port);
    await config.setNasPath(path.trim());
    await config.setNasUseHttps(useHttps);
    await config.setNasAllowSelfSigned(allowSelfSigned);
    if (username.isNotEmpty && password.isNotEmpty) {
      await config.saveNasCredentials(username.trim(), password);
    }
  }

  Future<void> _exportBackup() async {
    try {
      setState(() => _isRestoring = true);
      final zipFile = await DatabaseService.instance.exportBackupAsZip();

      if (await zipFile.exists()) {
        await Share.shareXFiles([
          XFile(
            zipFile.path,
            name:
                'meal_of_record_${DateTime.now().millisecondsSinceEpoch}.zip',
          ),
        ], text: 'Meal of Record Backup (with images)');
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

  Future<void> _backupToNas() async {
    try {
      setState(() => _isRestoring = true);
      final zipFile = await DatabaseService.instance.exportBackupAsZip();

      final retention = await _backupConfigService.getRetentionCount();
      final success = await _nasService.uploadBackup(
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
        await _backupConfigService.recordBackupSuccess();
        final lastTime = await _backupConfigService.getLastBackupTime();
        if (mounted) {
          setState(() => _lastBackupTime = lastTime);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NAS backup successful!')),
          );
        }
      } else {
        await _backupConfigService.recordBackupFailure();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NAS backup upload failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NAS backup failed: $e')),
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

  Future<void> _restoreFromNas() async {
    setState(() => _isRestoring = true);
    try {
      final backups = await _nasService.listBackups();

      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No NAS backups found.')),
          );
        }
        return;
      }

      if (!mounted) return;

      final selectedBackup = await showDialog<NasBackupFile>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select NAS Backup'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final b = backups[index];
                final date = b.modified != null
                    ? DateFormat('MM/dd/yyyy HH:mm').format(b.modified!)
                    : 'Unknown Date';
                final size = b.size != null
                    ? '${(b.size! / 1024).toStringAsFixed(1)} KB'
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

      if (selectedBackup != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore NAS Backup?'),
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
          final tempFile = await _nasService.downloadBackup(
            selectedBackup.href,
          );
          if (tempFile != null) {
            await DatabaseService.instance.restoreDatabase(tempFile);
            await tempFile.delete();
            // Reload goal settings from restored SharedPreferences
            await goalsProvider.reload();
            if (mounted) {
              await UiUtils.showAutoDismissDialog(
                context,
                'NAS backup restored successfully!',
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
                _buildNasBackupCard(),
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
                if (_isNasConfigured) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(
                        Icons.cloud_upload,
                        color: Colors.orange,
                      ),
                      title: const Text('Backup to NAS'),
                      subtitle: const Text(
                        'Upload a backup to your NAS now.',
                      ),
                      onTap: _backupToNas,
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
                      title: const Text('Restore from NAS'),
                      subtitle: const Text(
                        'Select a backup to restore from your NAS.',
                      ),
                      onTap: _restoreFromNas,
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

  Widget _buildNasBackupCard() {
    if (_isLoadingSettings) {
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
                const Icon(Icons.dns, color: Colors.orange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'NAS Backup',
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

            if (!_isNasConfigured)
              Padding(
                padding: const EdgeInsets.only(left: 36.0, top: 8.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Configure NAS'),
                  onPressed: () async {
                    final result = await _showNasConfigDialog();
                    if (result == true) await _loadSettings();
                  },
                ),
              ),

            if (_isNasConfigured) ...[
              Padding(
                padding: const EdgeInsets.only(left: 36.0, top: 4.0),
                child: Text(
                  _nasDisplayAddress ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              if (_nasConnectionNote != null)
                Padding(
                  padding: const EdgeInsets.only(left: 36.0),
                  child: Text(
                    _nasConnectionNote!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 36.0, top: 8.0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final result = await _showNasConfigDialog();
                        if (result == true) await _loadSettings();
                      },
                      child: const Text('Edit Settings'),
                    ),
                    OutlinedButton(
                      onPressed: _testConnection,
                      child: const Text('Test Connection'),
                    ),
                  ],
                ),
              ),
            ],

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
                      label: '$_retentionCount backups',
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
                'Backups exceeding this count will be deleted (oldest first).',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Backs up when app opens (at most once per day)',
                style: TextStyle(color: Colors.grey),
              ),
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
