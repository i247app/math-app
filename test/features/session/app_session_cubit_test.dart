import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/session/application/app_session_cubit.dart';
import 'package:numi/features/session/application/app_session_state.dart';
import 'package:numi/features/session/models/profile_session_resolution.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

class _FakeProfileSessionResolver implements ProfileSessionResolver {
  int? rememberedUserId;
  StudentProfile? rememberedProfile;

  @override
  Future<ProfileSessionResolution> resolveForUserId(int userId) async {
    return const ProfileSessionResolution.empty();
  }

  @override
  Future<void> rememberActiveProfile({
    required int userId,
    required StudentProfile profile,
  }) async {
    rememberedUserId = userId;
    rememberedProfile = profile;
  }
}

class _ControlledProfileSessionResolver implements ProfileSessionResolver {
  final Completer<ProfileSessionResolution> resolution =
      Completer<ProfileSessionResolution>();

  @override
  Future<ProfileSessionResolution> resolveForUserId(int userId) =>
      resolution.future;

  @override
  Future<void> rememberActiveProfile({
    required int userId,
    required StudentProfile profile,
  }) async {}
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.restoredUser});

  final LoginUser? restoredUser;
  int logoutCalls = 0;

  @override
  Future<LoginUser?> restoreSession() async => restoredUser;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationPingService implements NotificationPingService {
  int calls = 0;

  @override
  Future<void> ping() async {
    calls++;
  }
}

AppSessionCubit _buildCubit({
  _FakeAuthService? authService,
  ProfileSessionResolver? profileResolver,
  _FakeNotificationPingService? notificationPingService,
}) => AppSessionCubit(
  authService: authService ?? _FakeAuthService(),
  profileResolver: profileResolver ?? _FakeProfileSessionResolver(),
  notificationPingService:
      notificationPingService ?? _FakeNotificationPingService(),
);

void main() {
  group('AppSessionCubit', () {
    test(
      'owns an authenticated session independently from auth flow state',
      () async {
        final cubit = _buildCubit();
        const session = AuthenticatedSession(
          user: LoginUser(id: 7, phone: '0901234567'),
        );

        cubit.authenticate(session);

        expect(cubit.state.status, SessionStatus.authenticated);
        expect(cubit.state.user?.id, 7);
        expect(cubit.state.isAuthenticated, isTrue);
        await cubit.close();
      },
    );

    test(
      'tracks restore then clears all session-owned data on logout',
      () async {
        final cubit = _buildCubit();

        cubit.beginRestore();
        expect(cubit.state.status, SessionStatus.restoring);

        cubit.authenticate(const AuthenticatedSession(user: LoginUser(id: 7)));
        cubit.clear();

        expect(cubit.state.status, SessionStatus.unauthenticated);
        expect(cubit.state.user, isNull);
        expect(cubit.state.profiles, isEmpty);
        expect(cubit.state.activeProfile, isNull);
        await cubit.close();
      },
    );

    test(
      'advances the session epoch across logout and the next login',
      () async {
        final cubit = _buildCubit();

        cubit.authenticate(const AuthenticatedSession(user: LoginUser(id: 7)));
        final firstEpoch = cubit.state.sessionEpoch;
        cubit.clear();
        final loggedOutEpoch = cubit.state.sessionEpoch;
        cubit.authenticate(const AuthenticatedSession(user: LoginUser(id: 7)));

        expect(firstEpoch, greaterThan(0));
        expect(loggedOutEpoch, greaterThan(firstEpoch));
        expect(cubit.state.sessionEpoch, greaterThan(loggedOutEpoch));
        await cubit.close();
      },
    );

    test(
      'offers the child-profile dialog only for a new parent account',
      () async {
        final cubit = _buildCubit();

        cubit.authenticate(
          const AuthenticatedSession(
            user: LoginUser(id: 8, role: 'PARENT'),
            isNewlyRegistered: true,
          ),
        );
        expect(cubit.state.shouldShowChildProfileDialog, isTrue);

        cubit.consumeChildProfileDialog();
        expect(cubit.state.shouldShowChildProfileDialog, isFalse);

        cubit.authenticate(
          const AuthenticatedSession(
            user: LoginUser(id: 8, role: 'PARENT'),
            profiles: [
              StudentProfile(profileId: 81, role: 'STUDENT', name: 'Child'),
            ],
          ),
        );
        expect(cubit.state.shouldShowChildProfileDialog, isFalse);

        await cubit.close();
      },
    );

    test(
      'owns restore, notification ping, active profile and logout',
      () async {
        final authService = _FakeAuthService(
          restoredUser: const LoginUser(id: 9, role: 'STUDENT'),
        );
        final resolver = _FakeProfileSessionResolver();
        final ping = _FakeNotificationPingService();
        final cubit = _buildCubit(
          authService: authService,
          profileResolver: resolver,
          notificationPingService: ping,
        );

        await cubit.restoreSession();
        expect(cubit.state.user?.id, 9);
        expect(cubit.state.status, SessionStatus.authenticated);
        expect(ping.calls, 1);

        const profile = StudentProfile(profileId: 91, role: 'STUDENT');
        await cubit.activateProfile(profile);
        expect(cubit.state.activeProfile?.profileId, 91);
        expect(resolver.rememberedUserId, 9);

        await cubit.logout();
        expect(authService.logoutCalls, 1);
        expect(cubit.state.status, SessionStatus.unauthenticated);
        await cubit.close();
      },
    );

    test('shows Home while a new login resolves profiles', () async {
      final resolver = _ControlledProfileSessionResolver();
      final cubit = _buildCubit(profileResolver: resolver);

      final establish = cubit.establishSession(
        user: const LoginUser(id: 10, role: 'STUDENT'),
      );

      expect(cubit.state.status, SessionStatus.authenticated);
      expect(cubit.state.user?.id, 10);
      expect(cubit.state.isResolvingProfile, isTrue);

      resolver.resolution.complete(
        const ProfileSessionResolution(
          profiles: [StudentProfile(profileId: 101, role: 'STUDENT')],
          activeProfile: StudentProfile(profileId: 101, role: 'STUDENT'),
        ),
      );
      await establish;

      expect(cubit.state.isResolvingProfile, isFalse);
      expect(cubit.state.activeProfile?.profileId, 101);
      await cubit.close();
    });

    test(
      'keeps an explicit session restore behind the restoring state',
      () async {
        final resolver = _ControlledProfileSessionResolver();
        final cubit = _buildCubit(
          authService: _FakeAuthService(
            restoredUser: const LoginUser(id: 11, role: 'STUDENT'),
          ),
          profileResolver: resolver,
        );

        final restore = cubit.restoreSession();
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.status, SessionStatus.restoring);
        expect(cubit.state.user, isNull);

        resolver.resolution.complete(const ProfileSessionResolution.empty());
        await restore;

        expect(cubit.state.status, SessionStatus.authenticated);
        expect(cubit.state.user?.id, 11);
        expect(cubit.state.isResolvingProfile, isFalse);
        await cubit.close();
      },
    );
  });
}
