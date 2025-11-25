import 'package:flutter/foundation.dart';

class DeviceInfoProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String? _deviceID;
  String? _systemVersion;
  String? _modelName;
  String? _systemName;
  String? _appVersion;
  String? _appBuildNumber;
  String? _appDomain;
  String? _devicePushToken;

  String? get deviceID => _deviceID;
  String? get systemVersion => _systemVersion;
  String? get modelName => _modelName;
  String? get systemName => _systemName;
  String? get appVersion => _appVersion;
  String? get appBuildNumber => _appBuildNumber;
  String? get appDomain => _appDomain;
  String? get devicePushToken => _devicePushToken;

  set deviceID(String? newValue) {
    _deviceID = newValue;
    notifyListeners();
  }
  set systemVersion(String? newValue) {
    _systemVersion = newValue;
    notifyListeners();
  }
  set modelName(String? newValue) {
    _modelName = newValue;
    notifyListeners();
  }
  set systemName(String? newValue) {
    _systemName = newValue;
    notifyListeners();
  }
  set appVersion(String? newValue) {
    _appVersion = newValue;
    notifyListeners();
  }
  set appBuildNumber(String? newValue) {
    _appBuildNumber = newValue;
    notifyListeners();
  }
  set appDomain(String? newValue) {
    _appDomain = newValue;
    notifyListeners();
  }
  set devicePushToken(String? newValue) {
    _devicePushToken = newValue;
    notifyListeners();
  }
}
