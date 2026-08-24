import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/application/app_session_cubit.dart';
import 'package:numi/features/session/application/app_session_state.dart';

void main() {
  group('AppSessionCubit', () {
    test(
      'owns an authenticated session independently from auth flow state',
      () async {
        final cubit = AppSessionCubit();
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
        final cubit = AppSessionCubit();

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
        final cubit = AppSessionCubit();

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
        final cubit = AppSessionCubit();

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
  });
}
