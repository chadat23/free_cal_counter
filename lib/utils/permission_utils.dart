import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling camera permissions
class PermissionUtils {
  /// Check if camera permission is granted
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is permanently denied
  static Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings so user can enable camera permission
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
