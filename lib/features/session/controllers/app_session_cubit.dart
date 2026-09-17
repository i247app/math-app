import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/session/controllers/app_session_state.dart';
import 'package:numi/features/session/data/profile_session_resolver.dart';

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
  int _operationRevision = 0;
  Future<void>? _pendingLogout;
  Future<void>? _pendingProfileSelection;

  bool _isCurrent(int revision) => !isClosed && revision == _operationRevision;

  void beginRestore() {
    if (isClosed ||
        _pendingLogout != null ||
        state.isAuthenticated ||
        state.status == SessionStatus.restoring) {
      return;
    }
    _operationRevision++;
    emit(state.copyWith(status: SessionStatus.restoring));
  }

  Future<void> restoreSession() async {
    if (isClosed ||
        _pendingLogout != null ||
        state.isAuthenticated ||
        state.status == SessionStatus.restoring) {
      return;
    }
    beginRestore();
    final revision = _operationRevision;
    try {
      final user = await _authService.restoreSession();
      if (!_isCurrent(revision)) return;
      if (user == null) {
        clear();
        return;
      }
      await _resolveSession(
        user: user,
        revision: revision,
        showHomeWhileResolving: false,
      );
    } catch (_) {
      if (_isCurrent(revision)) clear();
    }
  }

  Future<void> establishSession({
    required LoginUser user,
    bool isNewlyRegistered = false,
    bool showHomeWhileResolving = true,
  }) async {
    if (isClosed) return;
    final revision = ++_operationRevision;
    final logout = _pendingLogout;
    if (logout != null) {
      try {
        // Finish clearing the old account before accepting a new session.
        await logout;
      } catch (_) {
        // The logout caller receives its error; a newer login may still proceed.
      }
      if (!_isCurrent(revision)) return;
    }
    await _resolveSession(
      user: user,
      revision: revision,
      isNewlyRegistered: isNewlyRegistered,
      showHomeWhileResolving: showHomeWhileResolving,
    );
  }

  Future<void> _resolveSession({
    required LoginUser user,
    required int revision,
    bool isNewlyRegistered = false,
    required bool showHomeWhileResolving,
  }) async {
    if (user.id <= 0) {
      clear();
      return;
    }
    if (showHomeWhileResolving) {
      _showAuthenticatedShell(user);
    } else if (!state.isAuthenticated) {
      emit(state.copyWith(status: SessionStatus.restoring));
    }
    final resolution = await _profileResolver.resolveForUserId(
      user.id,
      isCurrent: () => _isCurrent(revision),
    );
    if (!_isCurrent(revision)) return;
    _applySession(
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

  Future<void> logout() {
    if (isClosed) return Future<void>.value();
    final existing = _pendingLogout;
    if (existing != null) return existing;

    // End the local session immediately, including its cache epoch. Pending
    // token cleanup must not later clear a newer login, even for the same user.
    clear();
    late final Future<void> pending;
    pending = Future<void>.sync(_authService.logout).whenComplete(() {
      if (identical(_pendingLogout, pending)) _pendingLogout = null;
    });
    _pendingLogout = pending;
    return pending;
  }

  void authenticate(AuthenticatedSession session) {
    if (isClosed) return;
    _operationRevision++;
    _applySession(session);
  }

  void _applySession(AuthenticatedSession session) {
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
    if (isClosed) return;
    _operationRevision++;
    if (state.status == SessionStatus.unauthenticated) return;
    _sessionEpoch++;
    emit(AppSessionState(sessionEpoch: _sessionEpoch));
  }

  Future<void> refreshProfiles() async {
    final user = state.user;
    if (isClosed || _pendingLogout != null || user == null || user.id <= 0) {
      return;
    }

    // A refresh requested during a selection must read the newly saved choice,
    // rather than invalidate the selection before it reaches storage.
    final selection = _pendingProfileSelection;
    if (selection != null) {
      final revision = _operationRevision;
      try {
        await selection;
      } catch (_) {
        // The selection caller reports the error; refresh can reload profiles.
      }
      if (!_isCurrent(revision)) return;
    }
    final revision = ++_operationRevision;
    final resolution = await _profileResolver.resolveForUserId(
      user.id,
      isCurrent: () => _isCurrent(revision),
    );
    if (!_isCurrent(revision)) return;
    _applySession(
      AuthenticatedSession(
        user: user,
        profiles: resolution.profiles,
        activeProfile: resolution.activeProfile,
        profileLoadError: resolution.errorMessage,
      ),
    );
  }

  Future<void> activateProfile(StudentProfile profile) {
    final user = state.user;
    final profileId = profileStableId(profile);
    if (isClosed ||
        _pendingLogout != null ||
        user == null ||
        user.id <= 0 ||
        profileId == null) {
      return Future<void>.value();
    }

    final revision = ++_operationRevision;
    late final Future<void> pending;
    pending = _activateProfile(user, profile, profileId, revision).whenComplete(
      () {
        if (identical(_pendingProfileSelection, pending)) {
          _pendingProfileSelection = null;
        }
      },
    );
    _pendingProfileSelection = pending;
    return pending;
  }

  Future<void> _activateProfile(
    LoginUser user,
    StudentProfile profile,
    int profileId,
    int revision,
  ) async {
    try {
      await _profileResolver.rememberActiveProfile(
        userId: user.id,
        profile: profile,
        isCurrent: () => _isCurrent(revision),
      );
    } catch (_) {
      if (!_isCurrent(revision)) return;
      rethrow;
    }
    if (!_isCurrent(revision)) return;

    final profiles = <StudentProfile>[
      for (final existing in state.profiles)
        if (profileStableId(existing) != profileId) existing,
      profile,
    ];
    _applySession(
      AuthenticatedSession(
        user: user,
        profiles: profiles,
        activeProfile: profile,
      ),
    );
  }

  @override
  Future<void> close() {
    _operationRevision++;
    return super.close();
  }
}
