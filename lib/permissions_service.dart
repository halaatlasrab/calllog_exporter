import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> hasCallLogPermission() async {
    final status = await Permission.phone.status;
    return status.isGranted;
  }

  Future<PermissionStatus> requestCallLogPermission() async {
    return Permission.phone.request();
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }
}

