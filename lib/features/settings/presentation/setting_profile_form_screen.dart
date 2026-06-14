part of '../setting_tab.dart';

class _SettingProfileFormScreen extends StatelessWidget {
  const _SettingProfileFormScreen({
    required this.args,
    this.editingProfile,
  });

  final _SettingScreenArgs args;
  final StudentProfile? editingProfile;

  @override
  Widget build(BuildContext context) {
    return _SettingSafeScreen(
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
