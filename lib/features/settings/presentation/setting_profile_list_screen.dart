import 'package:flutter/material.dart';

import 'package:numi_flutter/features/settings/models/setting_screen_args.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/features/settings/widgets/setting_safe_screen.dart';

class SettingProfileListScreen extends StatelessWidget {
  const SettingProfileListScreen({
    super.key,
    required this.args,
    this.openAddProfileOnStart = false,
  });

  final SettingScreenArgs args;
  final bool openAddProfileOnStart;

  @override
  Widget build(BuildContext context) {
    return SettingSafeScreen(
      child: SettingTab.page(
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        profileLoadError: args.profileLoadError,
        onLogout: args.onLogout,
        onActivateProfile: args.onActivateProfile,
        onRefreshProfiles: args.onRefreshProfiles,
        onProfileSaved: args.onProfileSaved,
        bottomPadding: 0,
        scale: args.scale,
        initialView: SettingPageView.profile,
        isPushedPage: true,
        openAddProfileOnStart: openAddProfileOnStart,
      ),
    );
  }
}
