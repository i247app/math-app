import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/application/read_models/profile_display_read_model.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';

String settingsProfileName(BuildContext context, StudentProfile profile) {
  final name = profile.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.belovedChild)
      : name;
}

String settingsProfileGrade(BuildContext context, StudentProfile profile) {
  final grade = profile.grade?.label?.trim();
  return grade == null || grade.isEmpty
      ? context.getText(AppKeys.notSelected)
      : grade;
}

String settingsProfileProgram(BuildContext context, StudentProfile profile) {
  final program = profile.program?.label?.trim();
  return program == null || program.isEmpty
      ? context.getText(AppKeys.notSelected)
      : program;
}

String settingsProfileSchool(BuildContext context, StudentProfile profile) {
  final school = profile.school?.name?.trim();
  return school == null || school.isEmpty
      ? context.getText(AppKeys.notSelected)
      : school;
}

String localizedProfileRole(BuildContext context, ProfileRole role) {
  return localizedProfileRoleLabel(context, role);
}
