import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/auth/presentation/screens/passcode_screen.dart';
import 'package:numi/features/settings/application/controllers/settings_passcode_controller.dart';
import 'package:numi/features/settings/presentation/widgets/menu/passcode_settings_sheet.dart';

class SettingsPasscodeFlow {
  const SettingsPasscodeFlow();

  Future<void> open({
    required BuildContext context,
    required int? userId,
    required SettingsPasscodeController controller,
  }) async {
    HapticFeedback.selectionClick();
    if (userId == null || userId <= 0 || controller.isLoading) {
      return;
    }

    if (!controller.hasPasscode) {
      await _setPasscode(context, userId, controller);
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
        await _changePasscode(context, userId, controller);
      case PasscodeSettingsAction.remove:
        await _removePasscode(context, userId, controller);
    }
  }

  Future<void> _setPasscode(
    BuildContext context,
    int userId,
    SettingsPasscodeController controller,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.createPasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await controller.setPasscode(userId: userId, passcode: passcode);
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Future<void> _changePasscode(
    BuildContext context,
    int userId,
    SettingsPasscodeController controller,
  ) async {
    final verified = await _verifyCurrentPasscode(
      context,
      userId: userId,
      titleKey: AppKeys.enterCurrentPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeContinue,
      controller: controller,
    );
    if (!context.mounted || !verified) {
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.changePasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await controller.setPasscode(userId: userId, passcode: passcode);
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Future<void> _removePasscode(
    BuildContext context,
    int userId,
    SettingsPasscodeController controller,
  ) async {
    final verified = await _verifyCurrentPasscode(
      context,
      userId: userId,
      titleKey: AppKeys.verifyPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeRemove,
      controller: controller,
    );
    if (!context.mounted || !verified) {
      return;
    }

    try {
      await controller.clearPasscode(userId);
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
    required SettingsPasscodeController controller,
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
              final isValid = await controller.verifyPasscode(
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
}
