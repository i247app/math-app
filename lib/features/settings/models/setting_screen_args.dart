import 'package:flutter/widgets.dart';

import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/otp_auth_api.dart';

class SettingScreenArgs {
  const SettingScreenArgs({
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
