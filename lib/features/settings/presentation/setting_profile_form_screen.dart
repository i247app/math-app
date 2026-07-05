import 'package:flutter/material.dart';

import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/settings/helpers/setting_page_builders.dart';
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
