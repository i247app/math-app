import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/application/auth_cubit.dart';
import 'package:numi/features/auth/application/auth_state.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
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
    required String loginName,
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

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.accountExists = true});

  final bool accountExists;
  String? lookedUpLoginName;
  String? sentOtpLoginName;
  String? verifiedOtpLoginName;
  AuthOtpKind? sentOtpKind;

  @override
  Future<AuthLoginLookupResult> lookupLoginName(String loginName) async {
    lookedUpLoginName = loginName;
    return AuthLoginLookupResult(
      loginName: loginName,
      exists: accountExists,
      user: accountExists
          ? LoginUser(
              id: 7,
              email: loginName.contains('@') ? loginName : null,
              phone: loginName.contains('@') ? null : loginName,
            )
          : null,
    );
  }

  @override
  Future<SendOtpResult> sendOtp({
    required String loginName,
    required AuthOtpKind kind,
  }) async {
    sentOtpLoginName = loginName;
    sentOtpKind = kind;
    return const SendOtpResult(expiresIn: 30);
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String loginName,
    required String otpCode,
    required AuthOtpKind kind,
  }) async {
    verifiedOtpLoginName = loginName;
    return const VerifyOtpResult(isValid: false);
  }

  @override
  Future<void> clearPendingLogin(String loginName) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<LoginUser?> restoreSession() async => null;

  @override
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoginUser> updateUser({
    required int userId,
    required String name,
    String? phone,
    String? email,
    String? avatarPath,
  }) {
    throw UnimplementedError();
  }
}

AuthFlowCubit _buildCubit({
  AuthService? authService,
  AuthFlowState? initialState,
}) {
  return AuthFlowCubit(
    authService: authService,
    initialState: initialState,
    passcodeService: _FakePasscodeService(),
    onAuthenticated: (_) {},
    onSessionCleared: () {},
    onSessionRestoreStarted: () {},
  );
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

  test('uses an email login_name for login lookup and OTP', () async {
    final authService = _FakeAuthService();
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(screen: AppScreen.login),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(authService.lookedUpLoginName, 'learner@example.com');
    expect(authService.sentOtpLoginName, 'learner@example.com');
    expect(authService.sentOtpKind, AuthOtpKind.login);
    expect(cubit.state.loginName, 'learner@example.com');
    expect(cubit.state.screen, AppScreen.otp);
    await cubit.close();
  });

  test('uses the same email login_name when verifying OTP', () async {
    final authService = _FakeAuthService();
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AppScreen.otp,
        loginName: 'learner@example.com',
      ),
    );

    await cubit.verifyOtp('1234');

    expect(authService.verifiedOtpLoginName, 'learner@example.com');
    await cubit.close();
  });

  test('checks a signup phone before sending register OTP', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AppScreen.login,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.lookupSignupPhone('+84901234567');

    expect(authService.lookedUpLoginName, '+84901234567');
    expect(cubit.state.loginNameExists, isFalse);

    await cubit.submitLoginName('+84901234567');

    expect(authService.sentOtpLoginName, '+84901234567');
    expect(authService.sentOtpKind, AuthOtpKind.signup);
    expect(cubit.state.screen, AppScreen.otp);
    await cubit.close();
  });

  test('signup submit does not depend on the login lookup', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AppScreen.login,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('+84901234567');

    expect(authService.lookedUpLoginName, isNull);
    expect(authService.sentOtpLoginName, '+84901234567');
    expect(authService.sentOtpKind, AuthOtpKind.signup);
    expect(cubit.state.screen, AppScreen.otp);
    await cubit.close();
  });

  test('does not accept an email in the phone-only signup flow', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AppScreen.login,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(authService.lookedUpLoginName, isNull);
    expect(authService.sentOtpLoginName, isNull);
    expect(cubit.state.screen, AppScreen.login);
    await cubit.close();
  });

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

      await cubit.close();
      final otpCubit = AuthFlowCubit(
        initialState: const AuthFlowState(screen: AppScreen.otp),
        passcodeService: _FakePasscodeService(),
        onAuthenticated: (_) {},
        onSessionCleared: () {},
        onSessionRestoreStarted: () {},
      );
      expect(otpCubit.handleSystemBack(), isTrue);
      expect(otpCubit.state.screen, AppScreen.login);

      expect(otpCubit.handleSystemBack(), isTrue);
      expect(otpCubit.state.screen, AppScreen.welcomeDetails);

      otpCubit.openWelcome();
      expect(otpCubit.handleSystemBack(), isFalse);
      await otpCubit.close();
    },
  );

  test('returns login to the screen that opened it', () async {
    final cubit = _buildCubit();

    cubit.openLogin();
    expect(cubit.state.screen, AppScreen.login);

    cubit.switchAuthEntryMode(AuthEntryMode.signup);
    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AppScreen.login);
    expect(cubit.state.authEntryMode, AuthEntryMode.login);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AppScreen.welcome);

    cubit.openWelcomeDetails();
    cubit.openSignupEntry();
    expect(cubit.state.screen, AppScreen.login);

    cubit.switchAuthEntryMode(AuthEntryMode.login);
    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AppScreen.login);
    expect(cubit.state.authEntryMode, AuthEntryMode.signup);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AppScreen.welcomeDetails);

    await cubit.close();
  });
}
