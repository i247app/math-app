part of '../tabs/setting_tab.dart';

class _SettingProfileListScreen extends StatelessWidget {
  const _SettingProfileListScreen({required this.args});

  final _SettingScreenArgs args;

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
      ),
    );
  }
}
