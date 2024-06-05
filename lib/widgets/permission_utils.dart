import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<PermissionStatus> requestPermissions() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    // For Android 11 and above
    if (status.isGranted && await Permission.manageExternalStorage.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return status;
  }
}
