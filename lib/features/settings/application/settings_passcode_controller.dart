import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/auth/presentation/passcode_screen.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/settings/widgets/menu/passcode_settings_sheet.dart';

class SettingsPasscodeController extends ChangeNotifier {
  SettingsPasscodeController({
    PasscodeService service = const SecurePasscodeService(),
  }) : _service = service;

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

  Future<void> open(BuildContext context, int? userId) async {
    HapticFeedback.selectionClick();
    if (userId == null || userId <= 0 || _isLoading) {
      return;
    }

    if (!_hasPasscode) {
      await _setPasscode(context, userId);
      return;
    }

    final action = await showModalBottomSheet<PasscodeSettingsAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return PasscodeSettingsSheet(
          onChange: () =>
              Navigator.of(sheetContext).pop(PasscodeSettingsAction.change),
          onRemove: () =>
              Navigator.of(sheetContext).pop(PasscodeSettingsAction.remove),
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case PasscodeSettingsAction.change:
        await _changePasscode(context, userId);
      case PasscodeSettingsAction.remove:
        await _removePasscode(context, userId);
    }
  }

  Future<void> _setPasscode(BuildContext context, int userId) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.createPasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await _service.setPasscode(userId: userId, passcode: passcode);
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );

    if (!_isDisposed && saved == true) {
      _update(hasPasscode: true);
    }
  }

  Future<void> _changePasscode(BuildContext context, int userId) async {
    final verified = await _verifyCurrentPasscode(
      context,
      userId: userId,
      titleKey: AppKeys.enterCurrentPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeContinue,
    );
    if (!context.mounted || !verified) {
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.changePasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await _service.setPasscode(userId: userId, passcode: passcode);
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );

    if (!_isDisposed && changed == true) {
      _update(hasPasscode: true);
    }
  }

  Future<void> _removePasscode(BuildContext context, int userId) async {
    final verified = await _verifyCurrentPasscode(
      context,
      userId: userId,
      titleKey: AppKeys.verifyPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeRemove,
    );
    if (!context.mounted || !verified) {
      return;
    }

    try {
      await _service.clearPasscode(userId);
      if (!_isDisposed) {
        _update(hasPasscode: false);
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorDialog(context.getText(AppKeys.passcodeRemoveFailed));
      }
    }
  }

  Future<bool> _verifyCurrentPasscode(
    BuildContext context, {
    required int userId,
    required String titleKey,
    required String primaryLabelKey,
  }) async {
    final incorrectMessage = context.getText(AppKeys.passcodeIncorrect);
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.verify,
            titleKey: titleKey,
            primaryLabelKey: primaryLabelKey,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              final isValid = await _service.verifyPasscode(
                userId: userId,
                passcode: passcode,
              );
              if (!isValid) {
                return incorrectMessage;
              }
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );
    return verified == true;
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
