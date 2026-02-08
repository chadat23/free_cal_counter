import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService {
  // Singleton pattern
  GoogleDriveService._();
  static final GoogleDriveService instance = GoogleDriveService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    debugPrint('GoogleDriveService: Starting sign-in...');
    final account = await _googleSignIn.signIn();
    debugPrint(
      'GoogleDriveService: Sign-in complete. Account: ${account?.email}',
    );

    // Verify the account is properly set as current user
    if (account != null) {
      final currentUser = _googleSignIn.currentUser;
      debugPrint(
        'GoogleDriveService: Current user after sign-in: ${currentUser?.email}',
      );

      // If there's a mismatch, try silent sign-in to sync state
      if (currentUser == null || currentUser.email != account.email) {
        debugPrint(
          'GoogleDriveService: State mismatch detected, attempting silent sign-in...',
        );
        await silentSignIn();
      }
    }

    return account;
  }

  Future<void> signOut() async {
    debugPrint('GoogleDriveService: Signing out...');
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return _googleSignIn.currentUser != null ||
        await _googleSignIn.isSignedIn();
  }

  /// Forces a refresh of the current user state
  Future<GoogleSignInAccount?> refreshCurrentUser() async {
    try {
      debugPrint('GoogleDriveService: Refreshing current user...');
      await silentSignIn();
      final user = _googleSignIn.currentUser;
      debugPrint(
        'GoogleDriveService: Current user after refresh: ${user?.email}',
      );
      return user;
    } catch (e) {
      debugPrint('GoogleDriveService: Error refreshing current user: $e');
      return null;
    }
  }

  Future<void> silentSignIn() async {
    try {
      debugPrint('GoogleDriveService: Starting silent sign-in...');
      final account = await _googleSignIn.signInSilently();
      debugPrint(
        'GoogleDriveService: Silent sign-in complete. Account: ${account?.email}',
      );

      // Force refresh the current user to ensure state is synchronized
      if (account != null) {
        debugPrint(
          'GoogleDriveService: Account verified, current user: ${_googleSignIn.currentUser?.email}',
        );
      }
    } catch (e) {
      debugPrint('GoogleDriveService: Silent Sign-In Error: $e');
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;

    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) return null;

    return drive.DriveApi(authClient);
  }

  /// Uploads a pre-built backup zip to the App Data folder in Google Drive.
  /// If [retentionCount] is provided, it deletes older backups exceeding that count.
  Future<bool> uploadBackup(File zipFile, {int retentionCount = 7}) async {
    try {
      debugPrint('GoogleDriveService: Starting backup upload...');
      final api = await _getDriveApi();
      if (api == null) {
        debugPrint(
          'GoogleDriveService: Failed to get Drive API (not signed in?)',
        );
        return false;
      }

      final fileName =
          'free_cal_backup_${DateTime.now().toIso8601String()}.zip';

      final media = drive.Media(zipFile.openRead(), await zipFile.length());
      final driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = ['appDataFolder'];

      debugPrint('GoogleDriveService: Uploading $fileName to Drive...');
      await api.files.create(driveFile, uploadMedia: media);
      debugPrint('GoogleDriveService: Upload complete.');

      if (retentionCount > 0) {
        await _enforceRetentionPolicy(api, retentionCount);
      }

      return true;
    } catch (e) {
      debugPrint('GoogleDriveService: Drive Upload Error: $e');
      return false;
    }
  }

  Future<void> _enforceRetentionPolicy(
    drive.DriveApi api,
    int maxBackups,
  ) async {
    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime)',
        orderBy: 'createdTime desc', // Newest first
      );

      final files = fileList.files;
      if (files != null && files.length > maxBackups) {
        // Delete excess oldest files
        final toDelete = files.sublist(maxBackups);
        for (final file in toDelete) {
          if (file.id != null) {
            try {
              await api.files.delete(file.id!);
              debugPrint('Deleted old backup: ${file.name}');
            } catch (e) {
              debugPrint('Error deleting file ${file.id}: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Retention Policy Error: $e');
    }
  }

  Future<List<drive.File>> listBackups() async {
    final api = await _getDriveApi();
    if (api == null) return [];

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, size)',
        orderBy: 'createdTime desc',
      );
      return fileList.files ?? [];
    } catch (e) {
      debugPrint('Error listing backups: $e');
      return [];
    }
  }

  Future<File?> downloadBackup(String fileId) async {
    final api = await _getDriveApi();
    if (api == null) return null;

    try {
      final drive.Media response =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final tempDir = await Directory.systemTemp.createTemp();
      final file = File('${tempDir.path}/temp_restore.zip');

      final List<int> data = [];
      await for (final chunk in response.stream) {
        data.addAll(chunk);
      }
      await file.writeAsBytes(data);
      return file;
    } catch (e) {
      debugPrint('Error downloading backup: $e');
      return null;
    }
  }
}
