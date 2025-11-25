import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String? _authToken;
  bool _is2FARequired = true;
  bool _isSessionDataInit = false;
  String? _temp2FACode;
  DateTime? _lastSend2FACode;
  String? _jwtToken;
  bool _isReadOnly = false;

  bool get isLoggedIn => (_authToken?.isNotEmpty ?? false) && !_is2FARequired && _isSessionDataInit;

  String? get authToken => _authToken;

  bool get is2FARequired => _is2FARequired;

  bool get isSessionDataInit => _isSessionDataInit;

  String? get temp2FACode => _temp2FACode;

  DateTime? get lastSend2FACode => _lastSend2FACode;

  String? get jwtToken => _jwtToken;

  bool get isReadOnly => _isReadOnly;

  set jwtToken(String? newValue) {
    _jwtToken = newValue;
    notifyListeners();
  }

  set authToken(String? newValue) {
    _authToken = newValue;
    notifyListeners();
  }

  set is2FARequired(bool newValue) {
    _is2FARequired = newValue;
    notifyListeners();
  }

  set isSessionDataInit(bool newValue) {
    _isSessionDataInit = newValue;
    notifyListeners();
  }

  set temp2FACode(String? newValue) {
    _temp2FACode = newValue;
    notifyListeners();
  }

  set lastSend2FACode(DateTime? newValue) {
    _lastSend2FACode = newValue;
    notifyListeners();
  }

  set isReadOnly(bool newValue) {
    _isReadOnly = newValue;
    notifyListeners();
  }
}
