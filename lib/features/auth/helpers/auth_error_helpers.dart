import 'package:flutter/widgets.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';

bool isSignupUsernameExistsError(String? message) {
  final normalized = message?.toLowerCase().trim();
  if (normalized == null || normalized.isEmpty) {
    return false;
  }

  return normalized.contains('username already exists');
}

String localizedAuthError(BuildContext context, String message) {
  if (isSignupUsernameExistsError(message)) {
    return context.getText(AppKeys.signupUsernameExists);
  }
  return message;
}
