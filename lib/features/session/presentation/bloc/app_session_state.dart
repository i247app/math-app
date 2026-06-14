import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';

class AppSessionState {
  const AppSessionState({
    this.user,
    this.profiles = const <StudentProfile>[],
    this.activeProfile,
    this.profileLoadError,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;

  ProfileRole get activeRole => ProfileRole.fromProfile(activeProfile);

  bool get isAuthenticated => user != null;
}
