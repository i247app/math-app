import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/services/auth_profile_resolver.dart';
import 'package:numi/features/profile/profile_api.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';

/// Owns authenticated account and profile state for the entire app session.
class AppSessionCubit extends Cubit<AppSessionState> {
  AppSessionCubit({
    AuthenticatedSession? initialSession,
    AuthProfileResolver? profileResolver,
  }) : _profileResolver =
           profileResolver ??
           AuthProfileResolver(
             profileService: ProfileApi(),
             activeProfileSession: const ActiveProfileSession(),
           ),
       super(
         initialSession == null
             ? const AppSessionState()
             : AppSessionState(
                 status: SessionStatus.authenticated,
                 user: initialSession.user,
                 profiles: initialSession.profiles,
                 activeProfile: initialSession.activeProfile,
                 profileLoadError: initialSession.profileLoadError,
               ),
       );

  final AuthProfileResolver _profileResolver;

  void beginRestore() {
    if (state.isAuthenticated || state.status == SessionStatus.restoring) {
      return;
    }
    emit(state.copyWith(status: SessionStatus.restoring));
  }

  void authenticate(AuthenticatedSession session) {
    if (isClosed) {
      return;
    }
    emit(
      AppSessionState(
        status: SessionStatus.authenticated,
        user: session.user,
        profiles: session.profiles,
        activeProfile: session.activeProfile,
        profileLoadError: session.profileLoadError,
      ),
    );
  }

  void clear() {
    if (isClosed || state.status == SessionStatus.unauthenticated) {
      return;
    }
    emit(const AppSessionState());
  }

  Future<void> refreshProfiles() async {
    final user = state.user;
    if (user == null || user.id <= 0) {
      return;
    }

    final resolution = await _profileResolver.resolveForUser(user);
    if (isClosed || state.user?.id != user.id) {
      return;
    }
    authenticate(
      AuthenticatedSession(
        user: user,
        profiles: resolution.profiles,
        activeProfile: resolution.activeProfile,
        profileLoadError: resolution.errorMessage,
      ),
    );
  }

  Future<void> activateProfile(StudentProfile profile) async {
    final user = state.user;
    final profileId = ActiveProfileSession.profileStableId(profile);
    if (user == null || user.id <= 0 || profileId == null) {
      return;
    }

    await _profileResolver.rememberActiveProfile(user: user, profile: profile);
    if (isClosed || state.user?.id != user.id) {
      return;
    }

    final profiles = <StudentProfile>[
      for (final existing in state.profiles)
        if (ActiveProfileSession.profileStableId(existing) != profileId)
          existing,
      profile,
    ];
    authenticate(
      AuthenticatedSession(
        user: user,
        profiles: profiles,
        activeProfile: profile,
      ),
    );
  }
}
