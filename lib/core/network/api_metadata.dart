import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../localization/app_language.dart';

abstract class ApiMetadataProvider {
  Future<Map<String, Object>> buildMetadata();
}

class AppApiMetadataProvider implements ApiMetadataProvider {
  AppApiMetadataProvider({
    DeviceInfoPlugin? deviceInfoPlugin,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
       _storage = storage;

  static final instance = AppApiMetadataProvider();

  static const _deviceIdKey = 'client_device_id';

  final DeviceInfoPlugin _deviceInfoPlugin;
  final FlutterSecureStorage _storage;
  AppClientInfo? _cachedClientInfo;

  @override
  Future<Map<String, Object>> buildMetadata() async {
    final clientInfo = await loadClientInfo();
    return <String, Object>{
      'device_id': clientInfo.deviceId,
      'device_name': clientInfo.deviceName,
      'device_push_token': clientInfo.devicePushToken,
      'push_token': clientInfo.devicePushToken,
      'model_name': clientInfo.modelName,
      'platform': clientInfo.platform,
      'system_version': clientInfo.systemVersion,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'version': clientInfo.version,
      'build': clientInfo.buildNumber,
      'app_version': clientInfo.appVersionLabel,
      'language': AppLanguageState.currentApiCode,
      'ip_address': await _ipAddress(),
    };
  }

  Future<AppClientInfo> loadClientInfo() async {
    final cachedClientInfo = _cachedClientInfo;
    if (cachedClientInfo != null) {
      return cachedClientInfo;
    }

    final deviceInfo = await _loadDeviceInfo();
    final packageInfo = await _loadPackageInfo();
    final clientInfo = AppClientInfo(
      deviceId: await _deviceId(deviceInfo.deviceId),
      deviceName: deviceInfo.deviceName,
      modelName: deviceInfo.modelName,
      platform: deviceInfo.platform,
      systemVersion: deviceInfo.systemVersion,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
    );
    _cachedClientInfo = clientInfo;
    return clientInfo;
  }

  Future<String> _deviceId(String? pluginDeviceId) async {
    final trimmedPluginDeviceId = pluginDeviceId?.trim();
    if (trimmedPluginDeviceId != null && trimmedPluginDeviceId.isNotEmpty) {
      return trimmedPluginDeviceId;
    }

    final generatedDeviceId = _generateDeviceId();
    try {
      final existingDeviceId = (await _storage.read(key: _deviceIdKey))?.trim();
      if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
        return existingDeviceId;
      }

      await _storage.write(key: _deviceIdKey, value: generatedDeviceId);
    } catch (_) {
      return generatedDeviceId;
    }

    return generatedDeviceId;
  }

  Future<_DeviceMetadata> _loadDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = await _deviceInfoPlugin.androidInfo;
        return _DeviceMetadata(
          deviceId: deviceInfo.id,
          deviceName: deviceInfo.name,
          modelName: deviceInfo.brand,
          platform: 'android',
          systemVersion: deviceInfo.version.sdkInt.toString(),
        );
      }

      if (Platform.isIOS) {
        final deviceInfo = await _deviceInfoPlugin.iosInfo;
        return _DeviceMetadata(
          deviceId: deviceInfo.identifierForVendor,
          deviceName: deviceInfo.modelName,
          modelName: deviceInfo.systemName,
          platform: 'ios',
          systemVersion: deviceInfo.systemVersion,
        );
      }
    } catch (error) {
      debugPrint('AppApiMetadataProvider device info error: $error');
    }

    return _DeviceMetadata(
      deviceName: _fallbackDeviceName,
      modelName: _fallbackPlatform,
      platform: _fallbackPlatform,
      systemVersion: Platform.operatingSystemVersion,
    );
  }

  Future<PackageInfo> _loadPackageInfo() async {
    try {
      return PackageInfo.fromPlatform();
    } catch (error) {
      debugPrint('AppApiMetadataProvider package info error: $error');
      return PackageInfo(
        appName: 'NUMI',
        packageName: 'numi_flutter',
        version: 'unknown',
        buildNumber: 'unknown',
      );
    }
  }

  static String get _fallbackPlatform {
    final platform = Platform.operatingSystem.trim();
    return platform.isEmpty ? 'unknown' : platform;
  }

  static String get _fallbackDeviceName {
    try {
      final hostname = Platform.localHostname.trim();
      return hostname.isEmpty ? _fallbackPlatform : hostname;
    } catch (_) {
      return _fallbackPlatform;
    }
  }

  static String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    return hex.join();
  }

  static Future<String> _ipAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
        includeLoopback: false,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ipAddress = address.address.trim();
          if (ipAddress.isNotEmpty) {
            return ipAddress;
          }
        }
      }
    } catch (error) {
      debugPrint('AppApiMetadataProvider ip address error: $error');
    }

    return '';
  }
}

class AppClientInfo {
  const AppClientInfo({
    required this.deviceId,
    required this.deviceName,
    required this.modelName,
    required this.platform,
    required this.systemVersion,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    this.devicePushToken = '',
  });

  final String deviceId;
  final String deviceName;
  final String modelName;
  final String platform;
  final String systemVersion;
  final String version;
  final String buildNumber;
  final String packageName;
  final String devicePushToken;

  String get appVersionLabel => 'Version: $version + $buildNumber';
}

// Device metadata model
class _DeviceMetadata {
  const _DeviceMetadata({
    this.deviceId,
    required this.deviceName,
    required this.modelName,
    required this.platform,
    required this.systemVersion,
  });

  final String? deviceId;
  final String deviceName;
  final String modelName;
  final String platform;
  final String systemVersion;
}
