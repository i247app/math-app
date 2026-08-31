import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/application/app_session_cubit.dart';
import 'package:numi/features/session/application/app_session_state.dart';
import 'package:numi/main.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class _FakeAuthService implements AuthService {
  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('authentication entry characterization', () {
    testWidgets('starts on the welcome screen', (tester) async {
      await tester.pumpWidget(const NumiApp());

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
    });

    testWidgets('returns login to the welcome screen that opened it', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(const NumiApp());

      final welcomeLogin = find.text('ĐĂNG NHẬP');
      await tester.ensureVisible(welcomeLogin);
      await tester.tap(welcomeLogin);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
    });

    testWidgets(
      'reveals the phone region for digits and delays email errors until submit',
      (tester) async {
        FlutterSecureStorage.setMockInitialValues(<String, String>{});
        await tester.pumpWidget(const NumiApp());

        final welcomeLogin = find.text('ĐĂNG NHẬP');
        await tester.ensureVisible(welcomeLogin);
        await tester.tap(welcomeLogin);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login')), findsOneWidget);
        expect(find.text('🇻🇳'), findsNothing);

        final input = find.byType(EditableText);
        await tester.enterText(input, 'learner');
        await tester.pump();

        expect(find.text('🇻🇳'), findsNothing);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);

        final submitButton = find.byType(ElevatedButton);
        expect(
          tester.widget<ElevatedButton>(submitButton).onPressed,
          isNotNull,
        );

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);

        await tester.enterText(input, '090');
        await tester.pumpAndSettle();

        expect(find.text('🇻🇳'), findsOneWidget);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);
      },
    );

    testWidgets('clears the login input after logout', (tester) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(NumiApp(authService: _FakeAuthService()));

      final welcomeLogin = find.text('ĐĂNG NHẬP');
      await tester.ensureVisible(welcomeLogin);
      await tester.tap(welcomeLogin);
      await tester.pumpAndSettle();

      final input = find.byType(EditableText);
      await tester.enterText(input, 'learner@example.com');
      await tester.pump();

      final sessionCubit = tester
          .element(find.byKey(const ValueKey('login')))
          .read<AppSessionCubit>();
      sessionCubit.authenticate(
        const AuthenticatedSession(user: LoginUser(id: 7, role: 'STUDENT')),
      );
      await tester.pumpAndSettle();

      expect(sessionCubit.state.status, SessionStatus.authenticated);

      await sessionCubit.logout();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    });
  });
}
