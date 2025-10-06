import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceInfo() async {
    Map<String, String> deviceInfo = {};

    try {
      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      deviceInfo['app_version'] = packageInfo.version;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceInfo['device_type'] = 'Android';
        deviceInfo['device_model'] = '${androidInfo.brand} ${androidInfo.model}';
        deviceInfo['device_os'] = 'Android';
        deviceInfo['device_os_version'] = androidInfo.version.release;
        deviceInfo['device_id'] = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceInfo['device_type'] = 'iOS';
        deviceInfo['device_model'] = '${iosInfo.name} ${iosInfo.model}';
        deviceInfo['device_os'] = 'iOS';
        deviceInfo['device_os_version'] = iosInfo.systemVersion;
        deviceInfo['device_id'] = iosInfo.identifierForVendor ?? 'unknown_ios';
      } else if (kIsWeb) {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        deviceInfo['device_type'] = 'Web';
        deviceInfo['device_model'] = '${webInfo.browserName.name} Browser';
        deviceInfo['device_os'] = 'Web';
        deviceInfo['device_os_version'] = webInfo.appVersion!;
        deviceInfo['device_id'] = 'web_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Fallback for other platforms
        deviceInfo['device_type'] = 'Unknown';
        deviceInfo['device_model'] = 'Unknown';
        deviceInfo['device_os'] = 'Unknown';
        deviceInfo['device_os_version'] = 'Unknown';
        deviceInfo['device_id'] = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      // Handle any errors gracefully
      deviceInfo['device_type'] = 'Unknown';
      deviceInfo['device_model'] = 'Unknown';
      deviceInfo['device_os'] = 'Unknown';
      deviceInfo['device_os_version'] = 'Unknown';
      deviceInfo['device_id'] = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }

    return deviceInfo;
  }
}
