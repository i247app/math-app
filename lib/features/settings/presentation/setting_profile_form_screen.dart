import 'package:flutter/material.dart';

import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/settings/models/setting_screen_args.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/features/settings/widgets/setting_safe_screen.dart';

class SettingProfileFormScreen extends StatelessWidget {
  const SettingProfileFormScreen({
    super.key,
    required this.args,
    this.editingProfile,
  });

  final SettingScreenArgs args;
  final StudentProfile? editingProfile;

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
        onProfileSaved: () => Navigator.of(context).pop(true),
        bottomPadding: 0,
        scale: args.scale,
        initialView: SettingPageView.addProfile,
        initialEditingProfile: editingProfile,
        isPushedPage: true,
      ),
    );
  }
}
