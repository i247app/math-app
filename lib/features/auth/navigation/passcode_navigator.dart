import 'package:flutter/widgets.dart';

/// Returns null on success, or a validation message to display on the PIN form.
typedef PasscodeSubmit = Future<String?> Function(String passcode);

/// Routes into Auth's PIN forms without exposing their screen or UI modes.
/// Both methods return false when the user cancels the route.
abstract interface class PasscodeNavigator {
  Future<bool> setup({
    required BuildContext context,
    required String titleKey,
    required PasscodeSubmit onSubmit,
  });

  Future<bool> verify({
    required BuildContext context,
    required String titleKey,
    required String primaryLabelKey,
    required PasscodeSubmit onSubmit,
  });
}
