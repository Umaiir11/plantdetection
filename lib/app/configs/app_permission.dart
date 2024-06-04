import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
class PermissonsConfig {
  Future<PermissionStatus> requestfor_Photos() async {
    Permission permission;

    if (await _isAndroid12OrAbove()) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    var status = await permission.status;

    if (status != PermissionStatus.granted) {
      status = await permission.request();

      if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    }

    // Handle permission status accordingly
    if (status == PermissionStatus.granted) {
      // Access external storage here
    } else {
      // Handle denied or restricted permission
    }

    return status; // Return the permission status after the request process
  }

  Future<bool> _isAndroid12OrAbove() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 31; // SDK Int for Android 12 is 31
  }

  Future<PermissionStatus> requestfor_Notifications() async {
    var permission = await Permission.notification.status;
    if (permission != PermissionStatus.granted) {
      await Permission.notification.request().then((value) {
        permission = value;
      });
    }

    return permission;
  }
}
