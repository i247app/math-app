import 'package:flutter/material.dart';

import 'package:numi/features/settings/helpers/setting_page_builders.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/setting_tab.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';

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
      child: buildPushedSettingPage(
        context: context,
        args: args,
        initialView: SettingPageView.profile,
        openAddProfileOnStart: openAddProfileOnStart,
      ),
    );
  }
}
