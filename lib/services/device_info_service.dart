import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/recording_response.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  static DeviceInfoService get instance => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<DeviceInfo> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return DeviceInfo(
          platform: 'android',
          osVersion: androidInfo.version.release,
          model: androidInfo.model,
          manufacturer: androidInfo.manufacturer,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return DeviceInfo(
          platform: 'ios',
          osVersion: iosInfo.systemVersion,
          model: iosInfo.model,
          manufacturer: 'Apple',
        );
      } else {
        // Fallback for other platforms
        return DeviceInfo(
          platform: Platform.operatingSystem,
          osVersion: Platform.operatingSystemVersion,
          model: 'Unknown',
          manufacturer: 'Unknown',
        );
      }
    } catch (e) {
      // Fallback device info if collection fails
      return DeviceInfo(
        platform: Platform.operatingSystem,
        osVersion: 'Unknown',
        model: 'Unknown',
        manufacturer: 'Unknown',
      );
    }
  }
} 