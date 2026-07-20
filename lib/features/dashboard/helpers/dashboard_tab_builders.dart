import 'package:flutter/widgets.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/settings/application/setting_tab.dart';

Widget buildSettingsTab(DashboardTabArgs args) {
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
    isActive: args.isActive,
  );
}
