import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

bool isSignupUsernameExistsError(String? message) {
  final normalized = message?.toLowerCase().trim();
  if (normalized == null || normalized.isEmpty) {
    return false;
  }
  return normalized.contains('username already exists');
}

String localizedAuthError(BuildContext context, String message) {
  final normalized = message.trim();
  if (normalized.isEmpty) {
    return context.getText(AppKeys.invalidServerResponse);
  }
  if (isSignupUsernameExistsError(normalized)) {
    return context.getText(AppKeys.signupUsernameExists);
  }
  return normalized;
}
