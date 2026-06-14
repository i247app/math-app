import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/session/presentation/bloc/app_session_state.dart';

class AppSessionCubit extends Cubit<AppSessionState> {
  AppSessionCubit() : super(const AppSessionState());

  void sync({
    required LoginUser? user,
    required List<StudentProfile> profiles,
    required StudentProfile? activeProfile,
    required String? profileLoadError,
  }) {
    if (identical(state.user, user) &&
        identical(state.profiles, profiles) &&
        identical(state.activeProfile, activeProfile) &&
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
}
