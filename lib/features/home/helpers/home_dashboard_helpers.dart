part of '../home_screen.dart';

Widget _dashboardSettings(HomeDashboardArgs args) {
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

int? _profileGradeId(StudentProfile? profile) =>
    profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;
