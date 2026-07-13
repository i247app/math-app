import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/profile/models/profile_role.dart';

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
  if (parts.length < 3) {
    return parts.join(' ');
  }
  return '${parts.first} ${parts.last}';
}

String localizedProfileRoleLabel(BuildContext context, ProfileRole role) {
  return switch (role) {
    ProfileRole.teacher => context.getText(AppKeys.roleTeacher),
    ProfileRole.parent => context.getText(AppKeys.roleParent),
    ProfileRole.student => context.getText(AppKeys.roleStudent),
  };
}
