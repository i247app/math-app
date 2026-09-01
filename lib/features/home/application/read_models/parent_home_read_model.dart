import 'package:flutter/widgets.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/features/home/presentation/parent/models/parent_child_summary.dart';

List<StudentProfile> studentProfiles(List<StudentProfile> profiles) {
  return profiles
      .where(
        (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
      )
      .toList(growable: false);
}

String parentClassroomName(BuildContext context, ParentChildSummary summary) {
  final name = summary.classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final grade = summary.profile.grade?.label?.trim();
  if (grade != null && grade.isNotEmpty) {
    return grade;
  }
  return context.getText(AppKeys.parentNoClassroom);
}
