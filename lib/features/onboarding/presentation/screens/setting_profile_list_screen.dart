part of '../tabs/setting_tab.dart';

class _SettingProfileListScreen extends StatelessWidget {
  const _SettingProfileListScreen({
    required this.args,
    this.openAddProfileOnStart = false,
  });

  final _SettingScreenArgs args;
  final bool openAddProfileOnStart;

  @override
  Widget build(BuildContext context) {
    return _SettingSafeScreen(
      child: SettingTab.page(
        user: args.user,
        profiles: args.profiles,
        activeProfile: args.activeProfile,
        profileLoadError: args.profileLoadError,
        onLogout: args.onLogout,
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
