import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';

class AppSessionCubit extends Cubit<AppSessionState> {
  AppSessionCubit([AppSessionState? initialState])
    : super(initialState ?? const AppSessionState());

  void sync({
    required LoginUser? user,
    required List<StudentProfile> profiles,
    required StudentProfile? activeProfile,
    required String? profileLoadError,
  }) {
    if (_sameUser(state.user, user) &&
        _sameProfiles(state.profiles, profiles) &&
        _sameProfile(state.activeProfile, activeProfile) &&
        state.profileLoadError == profileLoadError) {
      return;
    }

    emit(
      AppSessionState(
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
      ),
    );
  }

  static bool _sameUser(LoginUser? a, LoginUser? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    return a.id == b.id &&
        a.email == b.email &&
        a.name == b.name &&
        a.phone == b.phone &&
        a.avatarUrl == b.avatarUrl &&
        a.role == b.role;
  }

  static bool _sameProfiles(List<StudentProfile> a, List<StudentProfile> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      if (!_sameProfile(a[index], b[index])) {
        return false;
      }
    }
    return true;
  }

  static bool _sameProfile(StudentProfile? a, StudentProfile? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    return ActiveProfileSession.profileStableId(a) ==
            ActiveProfileSession.profileStableId(b) &&
        a.profileCode == b.profileCode &&
        a.name == b.name &&
        a.avatarKey == b.avatarKey &&
        a.avatarUrl == b.avatarUrl &&
        a.gradeId == b.gradeId &&
        a.programId == b.programId &&
        a.semesterId == b.semesterId &&
        a.isDefault == b.isDefault &&
        a.role == b.role &&
        a.profileStatus == b.profileStatus;
  }
}
