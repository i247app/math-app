part of '../tabs/setting_tab.dart';

class _SettingScreenArgs {
  const _SettingScreenArgs({
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    required this.onActivateProfile,
    required this.onRefreshProfiles,
    required this.onProfileSaved,
    required this.scale,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final VoidCallback onLogout;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final Future<void> Function()? onRefreshProfiles;
  final VoidCallback? onProfileSaved;
  final double scale;
}

class _SettingAccountScreen extends StatelessWidget {
  const _SettingAccountScreen({required this.args});

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
        onActivateProfile: args.onActivateProfile,
        onRefreshProfiles: args.onRefreshProfiles,
        onProfileSaved: args.onProfileSaved,
        bottomPadding: 0,
        scale: args.scale,
        initialView: SettingPageView.account,
        isPushedPage: true,
      ),
    );
  }
}

class _SettingSafeScreen extends StatelessWidget {
  const _SettingSafeScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(child: child),
    );
  }
}
