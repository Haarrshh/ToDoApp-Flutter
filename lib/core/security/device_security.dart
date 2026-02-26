import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

import '../error/app_exceptions.dart';

class DeviceSecurity {
  DeviceSecurity._();

  static final _deviceInfo = DeviceInfoPlugin();

  static Future<bool> get _isSimulatorOrEmulator async {
    try {
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return !info.isPhysicalDevice;
      }
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return !info.isPhysicalDevice;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> get isDeviceCompromised async {
    if (await _isSimulatorOrEmulator) return false;
    try {
      final jailbroken = await FlutterJailbreakDetection.jailbroken;
      final developerMode = await FlutterJailbreakDetection.developerMode;
      return jailbroken || developerMode;
    } catch (e) {
      return false;
    }
  }

  static Future<void> ensureSecure() async {
    final compromised = await isDeviceCompromised;
    if (compromised) {
      throw SecurityException(
        'This app cannot run on rooted or jailbroken devices.',
        code: 'DEVICE_COMPROMISED',
      );
    }
  }
}
