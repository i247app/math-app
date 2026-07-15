import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/models/profile_role.dart';

enum SessionStatus { unauthenticated, restoring, authenticated }

class AuthenticatedSession {
  const AuthenticatedSession({
    required this.user,
    this.profiles = const <StudentProfile>[],
    this.activeProfile,
    this.profileLoadError,
  });

  final LoginUser user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
}

class AppSessionState {
  const AppSessionState({
    this.status = SessionStatus.unauthenticated,
    this.sessionEpoch = 0,
    this.user,
    this.profiles = const <StudentProfile>[],
    this.activeProfile,
    this.profileLoadError,
  });

  final SessionStatus status;
  final int sessionEpoch;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;

  ProfileRole get activeRole {
    if (activeProfile != null) {
      return ProfileRole.fromProfile(activeProfile);
    }
    return ProfileRole.fromRole(user?.role);
  }

  bool get isAuthenticated => user != null;

  AppSessionState copyWith({
    SessionStatus? status,
    int? sessionEpoch,
    LoginUser? user,
    List<StudentProfile>? profiles,
    StudentProfile? activeProfile,
    String? profileLoadError,
    bool clearUser = false,
    bool clearActiveProfile = false,
    bool clearProfileLoadError = false,
  }) {
    final nextStatus = status ?? this.status;
    final clearsSession =
        clearUser || nextStatus == SessionStatus.unauthenticated;
    return AppSessionState(
      status: nextStatus,
      sessionEpoch: sessionEpoch ?? this.sessionEpoch,
      user: clearsSession ? null : user ?? this.user,
      profiles: clearsSession
          ? const <StudentProfile>[]
          : profiles ?? this.profiles,
      activeProfile: clearsSession || clearActiveProfile
          ? null
          : activeProfile ?? this.activeProfile,
      profileLoadError: clearsSession || clearProfileLoadError
          ? null
          : profileLoadError ?? this.profileLoadError,
    );
  }
}
