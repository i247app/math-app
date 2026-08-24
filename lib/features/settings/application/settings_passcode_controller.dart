import 'package:flutter/foundation.dart';

import 'package:numi/features/session/services/passcode_service.dart';

class SettingsPasscodeController extends ChangeNotifier {
  SettingsPasscodeController({required PasscodeService service})
    : _service = service;

  final PasscodeService _service;

  bool _isDisposed = false;
  bool _isLoading = false;
  bool _hasPasscode = false;
  int? _requestedUserId;

  bool get isLoading => _isLoading;
  bool get hasPasscode => _hasPasscode;

  Future<void> load(int? userId) async {
    _requestedUserId = userId;
    if (userId == null || userId <= 0) {
      _update(isLoading: false, hasPasscode: false);
      return;
    }

    _update(isLoading: true);
    final hasPasscode = await _service.hasPasscode(userId);
    if (_isDisposed || _requestedUserId != userId) {
      return;
    }
    _update(isLoading: false, hasPasscode: hasPasscode);
  }

  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {
    await _service.setPasscode(userId: userId, passcode: passcode);
    _update(hasPasscode: true);
  }

  Future<bool> verifyPasscode({required int userId, required String passcode}) {
    return _service.verifyPasscode(userId: userId, passcode: passcode);
  }

  Future<void> clearPasscode(int userId) async {
    await _service.clearPasscode(userId);
    _update(hasPasscode: false);
  }

  void _update({bool? isLoading, bool? hasPasscode}) {
    if (_isDisposed) {
      return;
    }
    _isLoading = isLoading ?? _isLoading;
    _hasPasscode = hasPasscode ?? _hasPasscode;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
