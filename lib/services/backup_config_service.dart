import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupConfigService {
  static const String _keyAutoBackupEnabled = 'backup_auto_enabled';
  static const String _keyRetentionCount = 'backup_retention_count';
  static const String _keyLastBackupTime = 'backup_last_time';
  static const String _keyIsDirty = 'backup_is_dirty';

  // NAS configuration keys
  static const String _keyNasHost = 'nas_host';
  static const String _keyNasPort = 'nas_port';
  static const String _keyNasPath = 'nas_path';
  static const String _keyNasUseHttps = 'nas_use_https';
  static const String _keyNasAllowSelfSigned = 'nas_allow_self_signed';

  // Failure tracking
  static const String _keyConsecutiveFailures = 'backup_consecutive_failures';

  // Secure storage keys
  static const String _keyNasUsername = 'nas_username';
  static const String _keyNasPassword = 'nas_password';

  // Singleton instance
  static final BackupConfigService instance = BackupConfigService._();
  BackupConfigService._();

  // Allow injecting a custom FlutterSecureStorage for testing
  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  set secureStorage(FlutterSecureStorage storage) =>
      _secureStorage = storage;

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabled, enabled);
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackupEnabled) ?? false;
  }

  Future<void> setRetentionCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRetentionCount, count);
  }

  Future<int> getRetentionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRetentionCount) ?? 7; // Default to 7
  }

  Future<void> markDirty() async {
    final prefs = await SharedPreferences.getInstance();
    // Only write if not already dirty to save IO
    if (prefs.getBool(_keyIsDirty) != true) {
      await prefs.setBool(_keyIsDirty, true);
    }
  }

  Future<void> clearDirty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDirty, false);
  }

  Future<bool> isDirty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDirty) ?? false;
  }

  Future<void> updateLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keyLastBackupTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyLastBackupTime);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  // --- NAS Configuration ---

  Future<void> setNasHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNasHost, host);
  }

  Future<String?> getNasHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNasHost);
  }

  Future<void> setNasPort(int? port) async {
    final prefs = await SharedPreferences.getInstance();
    if (port != null) {
      await prefs.setInt(_keyNasPort, port);
    } else {
      await prefs.remove(_keyNasPort);
    }
  }

  Future<int?> getNasPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNasPort);
  }

  Future<void> setNasPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNasPath, path);
  }

  Future<String?> getNasPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNasPath);
  }

  Future<void> setNasUseHttps(bool useHttps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNasUseHttps, useHttps);
  }

  Future<bool> getNasUseHttps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNasUseHttps) ?? true;
  }

  Future<void> setNasAllowSelfSigned(bool allow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNasAllowSelfSigned, allow);
  }

  Future<bool> getNasAllowSelfSigned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNasAllowSelfSigned) ?? false;
  }

  // --- Failure Tracking ---

  Future<void> recordBackupFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyConsecutiveFailures) ?? 0;
    await prefs.setInt(_keyConsecutiveFailures, current + 1);
  }

  Future<void> recordBackupSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyConsecutiveFailures, 0);
  }

  Future<int> getConsecutiveFailures() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyConsecutiveFailures) ?? 0;
  }

  // --- NAS Credentials (Secure Storage) ---

  Future<void> saveNasCredentials(String username, String password) async {
    await _secureStorage.write(key: _keyNasUsername, value: username);
    await _secureStorage.write(key: _keyNasPassword, value: password);
  }

  Future<(String?, String?)> getNasCredentials() async {
    final username = await _secureStorage.read(key: _keyNasUsername);
    final password = await _secureStorage.read(key: _keyNasPassword);
    return (username, password);
  }

  Future<void> clearNasCredentials() async {
    await _secureStorage.delete(key: _keyNasUsername);
    await _secureStorage.delete(key: _keyNasPassword);
  }

  /// Returns true if host, path, and credentials are all set.
  Future<bool> isNasConfigured() async {
    final host = await getNasHost();
    final path = await getNasPath();
    final (username, password) = await getNasCredentials();
    return host != null &&
        host.isNotEmpty &&
        path != null &&
        path.isNotEmpty &&
        username != null &&
        username.isNotEmpty &&
        password != null &&
        password.isNotEmpty;
  }
}
