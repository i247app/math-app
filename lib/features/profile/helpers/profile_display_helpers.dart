import 'package:flutter/widgets.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';

String profileDisplayName(BuildContext context, StudentProfile profile) {
  final name = profile.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final profileCode = profile.profileCode?.trim();
  if (profileCode != null && profileCode.isNotEmpty) {
    return profileCode;
  }

  return context.getText(AppKeys.student);
}

String compactProfileName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length <= 2) {
    return parts.join(' ');
  }
  return '${parts.first} ${parts.last}';
}
