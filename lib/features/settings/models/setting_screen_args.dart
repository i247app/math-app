import 'package:flutter/widgets.dart';

import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';

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
    this.scale = 1,
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
