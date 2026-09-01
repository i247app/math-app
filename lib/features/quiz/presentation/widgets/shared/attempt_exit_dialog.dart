import 'package:flutter/material.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';

Future<bool> showAttemptExitDialog(BuildContext context) async {
  return showExitConfirmationDialog(
    context,
    titleKey: AppKeys.attemptExitTitle,
    messageKey: AppKeys.attemptExitMessage,
    stayActionKey: AppKeys.continueUpper,
    exitActionKey: AppKeys.exitUpper,
  );
}
