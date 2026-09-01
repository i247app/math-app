import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/notifications/application/contracts/notification_ping_service.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/features/session/application/controllers/app_session_state.dart';
import 'package:numi/features/session/application/services/profile_session_resolver.dart';

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
      await establishSession(user: user, showHomeWhileResolving: false);
    } catch (_) {
      if (!isClosed) {
        clear();
      }
    }
  }

  Future<void> establishSession({
    required LoginUser user,
    bool isNewlyRegistered = false,
    bool showHomeWhileResolving = true,
  }) async {
    if (user.id <= 0) {
      clear();
      return;
    }
    if (showHomeWhileResolving) {
      _showAuthenticatedShell(user);
    } else {
      beginRestore();
    }
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

  void _showAuthenticatedShell(LoginUser user) {
    final startsNewSession =
        !state.isAuthenticated || state.user?.id != user.id;
    if (startsNewSession) {
      _sessionEpoch++;
    }
    emit(
      AppSessionState(
        status: SessionStatus.authenticated,
        sessionEpoch: _sessionEpoch,
        user: user,
        isResolvingProfile: true,
      ),
    );
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
    final profileId = profileStableId(profile);
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
        if (profileStableId(existing) != profileId) existing,
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
