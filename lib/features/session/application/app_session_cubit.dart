import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/session/application/app_session_state.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

/// Owns authenticated account and profile state for the entire app session.
class AppSessionCubit extends Cubit<AppSessionState> {
  AppSessionCubit({
    AuthenticatedSession? initialSession,
    required AuthService authService,
    required ProfileSessionResolver profileResolver,
    required NotificationPingService notificationPingService,
  }) : _sessionEpoch = initialSession == null ? 0 : 1,
       _authService = authService,
       _profileResolver = profileResolver,
       _notificationPingService = notificationPingService,
       super(
         initialSession == null
             ? const AppSessionState()
             : AppSessionState(
                 status: SessionStatus.authenticated,
                 sessionEpoch: 1,
                 user: initialSession.user,
                 profiles: initialSession.profiles,
                 activeProfile: initialSession.activeProfile,
                 profileLoadError: initialSession.profileLoadError,
                 shouldShowChildProfileDialog: false,
               ),
       );

  final ProfileSessionResolver _profileResolver;
  final AuthService _authService;
  final NotificationPingService _notificationPingService;
  int _sessionEpoch;

  void beginRestore() {
    if (state.isAuthenticated || state.status == SessionStatus.restoring) {
      return;
    }
    emit(state.copyWith(status: SessionStatus.restoring));
  }

  Future<void> restoreSession() async {
    if (state.status == SessionStatus.restoring) {
      return;
    }
    beginRestore();
    try {
      final user = await _authService.restoreSession();
      if (isClosed) {
        return;
      }
      if (user == null) {
        clear();
        return;
      }
      await establishSession(user: user);
    } catch (_) {
      if (!isClosed) {
        clear();
      }
    }
  }

  Future<void> establishSession({
    required LoginUser user,
    bool isNewlyRegistered = false,
  }) async {
    if (user.id <= 0) {
      clear();
      return;
    }
    beginRestore();
    final resolution = await _profileResolver.resolveForUserId(user.id);
    if (isClosed) {
      return;
    }
    authenticate(
      AuthenticatedSession(
        user: user,
        profiles: resolution.profiles,
        activeProfile: resolution.activeProfile,
        profileLoadError: resolution.errorMessage,
        isNewlyRegistered: isNewlyRegistered,
      ),
    );
    unawaited(_notificationPingService.ping());
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      if (!isClosed) {
        clear();
      }
    }
  }

  void authenticate(AuthenticatedSession session) {
    if (isClosed) {
      return;
    }
    final startsNewSession =
        !state.isAuthenticated || state.user?.id != session.user.id;
    if (startsNewSession) {
      _sessionEpoch++;
    }
    final hasChildProfile = session.profiles.any(
      (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
    );
    final isNewParentAccount =
        session.isNewlyRegistered &&
        ProfileRole.fromRole(session.user.role) == ProfileRole.parent;
    emit(
      AppSessionState(
        status: SessionStatus.authenticated,
        sessionEpoch: _sessionEpoch,
        user: session.user,
        profiles: session.profiles,
        activeProfile: session.activeProfile,
        profileLoadError: session.profileLoadError,
        shouldShowChildProfileDialog:
            !hasChildProfile &&
            (isNewParentAccount || state.shouldShowChildProfileDialog),
      ),
    );
  }

  void consumeChildProfileDialog() {
    if (isClosed || !state.shouldShowChildProfileDialog) {
      return;
    }
    emit(state.copyWith(shouldShowChildProfileDialog: false));
  }

  void clear() {
    if (isClosed || state.status == SessionStatus.unauthenticated) {
      return;
    }
    _sessionEpoch++;
    emit(AppSessionState(sessionEpoch: _sessionEpoch));
  }

  Future<void> refreshProfiles() async {
    final user = state.user;
    if (user == null || user.id <= 0) {
      return;
    }

    final resolution = await _profileResolver.resolveForUserId(user.id);
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

    await _profileResolver.rememberActiveProfile(
      userId: user.id,
      profile: profile,
    );
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
