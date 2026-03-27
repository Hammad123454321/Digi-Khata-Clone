import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../di/injection.dart';

/// Device Utilities
class DeviceUtils {
  DeviceUtils._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const Uuid _uuid = Uuid();
  static const String _deviceIdKey = 'device_id';
  static const String _deviceNameKey = 'device_name';

  /// Get unique device ID
  static Future<String> getDeviceId() async {
    // Web platform
    if (kIsWeb) {
      final prefs = getIt<SharedPreferences>();
      String? deviceId = prefs.getString(_deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = 'web_${_uuid.v4()}';
        await prefs.setString(_deviceIdKey, deviceId);
      }
      return deviceId;
    }

    // Mobile/Desktop platforms
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _uuid.v4();
      } else {
        // For other platforms (Windows, macOS, Linux), use stored UUID
        final prefs = getIt<SharedPreferences>();
        String? deviceId = prefs.getString(_deviceIdKey);
        if (deviceId == null || deviceId.isEmpty) {
          deviceId = _uuid.v4();
          await prefs.setString(_deviceIdKey, deviceId);
        }
        return deviceId;
      }
    } catch (e) {
      // Fallback: generate and store UUID
      final prefs = getIt<SharedPreferences>();
      String? deviceId = prefs.getString(_deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }
      return deviceId;
    }
  }

  /// Get device name
  static Future<String> getDeviceName() async {
    // Web platform
    if (kIsWeb) {
      final prefs = getIt<SharedPreferences>();
      String? deviceName = prefs.getString(_deviceNameKey);
      if (deviceName == null || deviceName.isEmpty) {
        deviceName = 'Web Browser';
        await prefs.setString(_deviceNameKey, deviceName);
      }
      return deviceName;
    }

    // Mobile/Desktop platforms
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.name;
      } else {
        // For other platforms, use stored name or default
        final prefs = getIt<SharedPreferences>();
        String? deviceName = prefs.getString(_deviceNameKey);
        if (deviceName == null || deviceName.isEmpty) {
          deviceName = _getPlatformName();
          await prefs.setString(_deviceNameKey, deviceName);
        }
        return deviceName;
      }
    } catch (e) {
      // Fallback: use platform name
      return _getPlatformName();
    }
  }

  /// Get platform name
  static String _getPlatformName() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'Windows Device';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macOS Device';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'Linux Device';
    } else {
      return 'Unknown Device';
    }
  }

  /// Get device type
  static String getDeviceType() {
    if (kIsWeb) {
      return 'web';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'windows';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Get app version
  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Get app build number
  static Future<String> getAppBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  /// Get package name
  static Future<String> getPackageName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }
}
