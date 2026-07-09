import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/home/widgets/home_dashboard_args.dart';
import 'package:numi/features/settings/setting_tab.dart';

Widget dashboardSettings(HomeDashboardArgs args) {
  return SettingTab(
    user: args.user,
    profiles: args.profiles,
    activeProfile: args.activeProfile,
    profileLoadError: args.profileLoadError,
    onLogout: args.onLogout,
    onActivateProfile: args.onActivateProfile,
    onRefreshProfiles: args.onRefreshProfiles,
    onProfileSaved: args.onProfileSaved,
    openAddProfileRequestId: args.openAddProfileRequestId,
    bottomPadding: args.bottomPadding,
    scale: args.scale,
    isActive: args.isActive,
  );
}

int? profileGradeId(StudentProfile? profile) =>
    profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;

String classroomDisplayName(BuildContext context, ClassroomModel classroom) {
  final name = classroom.name?.trim();
  return name?.isNotEmpty == true
      ? name!
      : context.getText(AppKeys.teacherClassFallback);
}

String classroomTeacherName(BuildContext context, ClassroomModel classroom) {
  final teacherName = classroom.teacherName?.trim();
  return teacherName?.isNotEmpty == true
      ? teacherName!
      : context.getText(AppKeys.teacherFallback);
}
