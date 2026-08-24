import 'package:flutter/widgets.dart';

import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/settings/application/setting_tab.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';

Widget buildPushedSettingPage({
  required BuildContext context,
  required SettingScreenArgs args,
  required SettingPageView initialView,
  StudentProfile? initialEditingProfile,
  bool openAddProfileOnStart = false,
  VoidCallback? onProfileSaved,
}) {
  return SettingTab.page(
    user: args.user,
    profiles: args.profiles,
    activeProfile: args.activeProfile,
    profileLoadError: args.profileLoadError,
    onLogout: args.onLogout,
    onActivateProfile: args.onActivateProfile,
    onRefreshProfiles: args.onRefreshProfiles,
    onProfileSaved: onProfileSaved ?? args.onProfileSaved,
    bottomPadding: 0,
    scale: args.scale,
    initialView: initialView,
    initialEditingProfile: initialEditingProfile,
    isPushedPage: true,
    openAddProfileOnStart: openAddProfileOnStart,
  );
}
