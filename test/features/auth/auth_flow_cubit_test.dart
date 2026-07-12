import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/auth_cubit.dart';
import 'package:numi/features/auth/auth_state.dart';
import 'package:numi/features/session/services/passcode_service.dart';

class _FakePasscodeService implements PasscodeService {
  @override
  Future<void> clearPasscode(int userId) async {}

  @override
  Future<bool> hasPasscode(int userId) async => false;

  @override
  Future<PasscodeLoginAccount?> lastPasscodeAccount() async => null;

  @override
  Future<int?> lastPasscodeUserId() async => null;

  @override
  Future<void> rememberLoginAccount({
    required int userId,
    required String phone,
  }) async {}

  @override
  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {}

  @override
  Future<bool> verifyPasscode({
    required int userId,
    required String passcode,
  }) async => false;
}

void main() {
  test(
    'preserves the welcome-to-signup entry flow without a session',
    () async {
      final cubit = AuthFlowCubit(
        passcodeService: _FakePasscodeService(),
        onAuthenticated: (_) {},
        onSessionCleared: () {},
        onSessionRestoreStarted: () {},
      );

      cubit.openWelcomeDetails();
      expect(cubit.state.screen, AppScreen.welcomeDetails);

      cubit.openSignupEntry();
      expect(cubit.state.screen, AppScreen.login);
      expect(cubit.state.authEntryMode, AuthEntryMode.signup);
      await cubit.close();
    },
  );

  test(
    'handles Back for state-driven auth screens before leaving the app',
    () async {
      final cubit = AuthFlowCubit(
        passcodeService: _FakePasscodeService(),
        onAuthenticated: (_) {},
        onSessionCleared: () {},
        onSessionRestoreStarted: () {},
      );

      cubit.openWelcomeDetails();
      expect(cubit.handleSystemBack(), isTrue);
      expect(cubit.state.screen, AppScreen.welcome);

      cubit.openOtp();
      expect(cubit.handleSystemBack(), isTrue);
      expect(cubit.state.screen, AppScreen.login);

      expect(cubit.handleSystemBack(), isTrue);
      expect(cubit.state.screen, AppScreen.welcomeDetails);

      cubit.openWelcome();
      expect(cubit.handleSystemBack(), isFalse);
      await cubit.close();
    },
  );
}
