import 'package:flutter/material.dart';

import 'package:numi/features/auth/navigation/passcode_navigator.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';

class AppPasscodeNavigator implements PasscodeNavigator {
  const AppPasscodeNavigator();

  @override
  Future<bool> setup({
    required BuildContext context,
    required String titleKey,
    required PasscodeSubmit onSubmit,
  }) => _open(
    context: context,
    mode: PasscodeScreenMode.setup,
    titleKey: titleKey,
    onSubmit: onSubmit,
  );

  @override
  Future<bool> verify({
    required BuildContext context,
    required String titleKey,
    required String primaryLabelKey,
    required PasscodeSubmit onSubmit,
  }) => _open(
    context: context,
    mode: PasscodeScreenMode.verify,
    titleKey: titleKey,
    primaryLabelKey: primaryLabelKey,
    onSubmit: onSubmit,
  );

  Future<bool> _open({
    required BuildContext context,
    required PasscodeScreenMode mode,
    required String titleKey,
    required PasscodeSubmit onSubmit,
    String? primaryLabelKey,
  }) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) => PasscodeScreen(
          mode: mode,
          titleKey: titleKey,
          primaryLabelKey: primaryLabelKey,
          onBack: () => Navigator.of(routeContext).pop(false),
          onSubmit: (passcode) async {
            final error = await onSubmit(passcode);
            if (error == null &&
                routeContext.mounted &&
                ModalRoute.of(routeContext)?.isCurrent == true) {
              Navigator.of(routeContext).pop(true);
            }
            return error;
          },
        ),
      ),
    );
    return completed == true;
  }
}
