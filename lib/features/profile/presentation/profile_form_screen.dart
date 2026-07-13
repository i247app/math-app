import 'package:flutter/material.dart';

import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/settings/helpers/setting_page_builders.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/setting_tab.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';

class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key, required this.args, this.editingProfile});

  final SettingScreenArgs args;
  final StudentProfile? editingProfile;

  @override
  Widget build(BuildContext context) {
    return SettingSafeScreen(
      child: buildPushedSettingPage(
        context: context,
        args: args,
        onProfileSaved: () => Navigator.of(context).pop(true),
        initialView: SettingPageView.addProfile,
        initialEditingProfile: editingProfile,
      ),
    );
  }
}
