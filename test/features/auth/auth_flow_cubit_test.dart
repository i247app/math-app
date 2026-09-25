import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/controllers/auth_cubit.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService({
    this.accountExists = true,
    this.verifyOtpIsValid = false,
    this.isTrusted,
    this.trustedDevices = const <AuthTrustedDevice>[],
    this.lookupFailure,
  });

  final bool accountExists;
  final bool verifyOtpIsValid;
  final bool? isTrusted;
  final List<AuthTrustedDevice> trustedDevices;
  final Object? lookupFailure;
  String? lookedUpLoginName;
  String? sentOtpLoginName;
  String? verifiedOtpLoginName;
  String? signupEmail;
  AuthOtpKind? sentOtpKind;
  int? sentOtpUserId;
  int? sentOtpTargetDeviceId;
  int? listedDeviceUserId;

  @override
  Future<AuthLoginLookupResult> lookupLoginName(String loginName) async {
    lookedUpLoginName = loginName;
    if (lookupFailure != null) {
      throw lookupFailure!;
    }
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
      isTrusted: isTrusted,
    );
  }

  @override
  Future<List<AuthTrustedDevice>> listTrustedDevices({
    required int userId,
  }) async {
    listedDeviceUserId = userId;
    return trustedDevices;
  }

  @override
  Future<SendOtpResult> sendOtp({
    required String loginName,
    required AuthOtpKind kind,
    int? userId,
    int? targetDeviceId,
  }) async {
    sentOtpLoginName = loginName;
    sentOtpKind = kind;
    sentOtpUserId = userId;
    sentOtpTargetDeviceId = targetDeviceId;
    return const SendOtpResult(expiresIn: 30);
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String loginName,
    required String otpCode,
    required AuthOtpKind kind,
  }) async {
    verifiedOtpLoginName = loginName;
    return VerifyOtpResult(
      isValid: verifyOtpIsValid,
      user: verifyOtpIsValid
          ? LoginUser(
              id: 7,
              email: loginName.contains('@') ? loginName : null,
              phone: loginName.contains('@') ? null : loginName,
            )
          : null,
    );
  }

  @override
  Future<void> clearPendingLogin(String loginName) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<LoginUser?> restoreSession() async => null;

  @override
  Future<LoginUser> signupWithEmail({
    required String email,
    required String name,
    required String role,
  }) async {
    signupEmail = email;
    return LoginUser(id: 0, email: email, name: name, role: role);
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
    authService: authService ?? _FakeAuthService(),
    initialState: initialState,
  );
}

void main() {
  test(
    'preserves the welcome-to-signup entry flow without a session',
    () async {
      final cubit = AuthFlowCubit(authService: _FakeAuthService());

      cubit.openWelcomeDetails();
      expect(cubit.state.screen, AuthScreen.welcomeDetails);

      cubit.openSignupEntry();
      expect(cubit.state.screen, AuthScreen.signup);
      expect(cubit.state.authEntryMode, AuthEntryMode.signup);
      await cubit.close();
    },
  );

  test('uses an email login_name for login lookup and OTP', () async {
    final authService = _FakeAuthService();
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(screen: AuthScreen.login),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(authService.lookedUpLoginName, 'learner@example.com');
    expect(authService.sentOtpLoginName, 'learner@example.com');
    expect(authService.sentOtpKind, AuthOtpKind.login);
    expect(cubit.state.loginName, 'learner@example.com');
    expect(cubit.state.screen, AuthScreen.otp);
    await cubit.close();
  });

  test('untrusted login requires selecting a verified device', () async {
    final authService = _FakeAuthService(
      isTrusted: false,
      trustedDevices: const <AuthTrustedDevice>[
        AuthTrustedDevice(
          deviceId: 4,
          deviceName: 'TECNO SPARK Go 1',
          platform: 'android',
        ),
      ],
    );
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(screen: AuthScreen.login),
    );

    await cubit.submitLoginName('+84905666666');

    expect(authService.listedDeviceUserId, 7);
    expect(authService.sentOtpLoginName, isNull);
    expect(cubit.state.screen, AuthScreen.deviceVerification);
    expect(cubit.state.trustedDevices.single.deviceId, 4);

    cubit.selectTrustedDevice(4);
    await cubit.sendOtpToTrustedDevice();

    expect(authService.sentOtpLoginName, '+84905666666');
    expect(authService.sentOtpKind, AuthOtpKind.login);
    expect(authService.sentOtpUserId, 7);
    expect(authService.sentOtpTargetDeviceId, 4);
    expect(cubit.state.screen, AuthScreen.otp);
    expect(cubit.state.selectedTrustedDeviceId, 4);
    await cubit.close();
  });

  test(
    'untrusted login without verified devices sends OTP without exposing it',
    () async {
      final authService = _FakeAuthService(
        isTrusted: false,
        verifyOtpIsValid: true,
      );
      final cubit = _buildCubit(
        authService: authService,
        initialState: const AuthFlowState(screen: AuthScreen.login),
      );

      await cubit.submitLoginName('+84905666666');

      expect(authService.listedDeviceUserId, 7);
      expect(authService.sentOtpLoginName, '+84905666666');
      expect(authService.sentOtpKind, AuthOtpKind.login);
      expect(authService.sentOtpUserId, isNull);
      expect(authService.sentOtpTargetDeviceId, isNull);
      expect(cubit.state.screen, AuthScreen.otp);
      await cubit.verifyOtp('1234');

      expect(cubit.state.screen, AuthScreen.otp);
      expect(cubit.state.authenticationResult?.user.id, 7);
      await cubit.close();
    },
  );

  test('uses the same email login_name when verifying OTP', () async {
    final authService = _FakeAuthService();
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.otp,
        loginName: 'learner@example.com',
      ),
    );

    await cubit.verifyOtp('1234');

    expect(authService.verifiedOtpLoginName, 'learner@example.com');
    await cubit.close();
  });

  test('valid login OTP opens home directly', () async {
    final authService = _FakeAuthService(verifyOtpIsValid: true);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.otp,
        loginName: 'learner@example.com',
        otpFlow: OtpFlow.login,
      ),
    );

    await cubit.verifyOtp('1234');

    expect(cubit.state.screen, AuthScreen.otp);
    expect(cubit.state.authenticationResult?.user.id, 7);
    await cubit.close();
  });

  test(
    'checks a signup email only on submit before opening the form',
    () async {
      final authService = _FakeAuthService(accountExists: false);
      final cubit = _buildCubit(
        authService: authService,
        initialState: const AuthFlowState(
          screen: AuthScreen.signup,
          authEntryMode: AuthEntryMode.signup,
        ),
      );

      expect(authService.lookedUpLoginName, isNull);
      await cubit.submitLoginName('learner@example.com');

      expect(authService.lookedUpLoginName, 'learner@example.com');
      expect(cubit.state.loginNameExists, isFalse);
      expect(authService.sentOtpLoginName, isNull);
      expect(cubit.state.screen, AuthScreen.registrationProfile);
      await cubit.close();
    },
  );

  test('keeps signup email lookup failures on signup screen', () async {
    final authService = _FakeAuthService(
      accountExists: false,
      lookupFailure: const AuthException('Service unavailable', status: 503),
    );
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(authService.lookedUpLoginName, 'learner@example.com');
    expect(cubit.state.authError, isNull);
    expect(cubit.state.loginLookupError, 'Service unavailable');
    expect(cubit.state.loginLookupErrorStatus, 503);
    expect(cubit.state.isCheckingLoginName, isFalse);
    expect(cubit.state.screen, AuthScreen.signup);
    await cubit.close();
  });

  test('treats a 4206 signup lookup response as an available email', () async {
    final authService = _FakeAuthService(
      lookupFailure: const AuthException('User not found', status: 4206),
    );
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(cubit.state.authError, isNull);
    expect(cubit.state.loginNameExists, isFalse);
    expect(cubit.state.loginLookupErrorStatus, 4206);
    expect(cubit.state.screen, AuthScreen.registrationProfile);
    await cubit.close();
  });

  test('existing signup email stays on signup and does not send OTP', () async {
    final authService = _FakeAuthService(accountExists: true);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');

    expect(authService.lookedUpLoginName, 'learner@example.com');
    expect(authService.sentOtpLoginName, isNull);
    expect(cubit.state.loginNameExists, isTrue);
    expect(cubit.state.screen, AuthScreen.signup);
    await cubit.close();
  });

  test('signup uses the checked email even when the form omits it', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');
    await cubit.submitSignup(
      const SignupFormData(
        name: 'Learner',
        role: SignupRole.student,
        gender: SignupGender.studentMale,
      ),
    );

    expect(authService.sentOtpLoginName, 'learner@example.com');
    expect(authService.signupEmail, isNull);
    expect(cubit.state.screen, AuthScreen.otp);
    await cubit.close();
  });

  test(
    'signup with email verifies email OTP before creating account',
    () async {
      final authService = _FakeAuthService(
        accountExists: false,
        verifyOtpIsValid: true,
      );
      final cubit = _buildCubit(
        authService: authService,
        initialState: const AuthFlowState(
          screen: AuthScreen.signup,
          authEntryMode: AuthEntryMode.signup,
        ),
      );

      await cubit.submitLoginName('learner@example.com');
      await cubit.submitSignup(
        const SignupFormData(
          name: 'Learner',
          email: 'learner@example.com',
          role: SignupRole.student,
          gender: SignupGender.studentMale,
        ),
      );

      expect(authService.sentOtpLoginName, 'learner@example.com');
      expect(authService.sentOtpKind, AuthOtpKind.signup);
      expect(authService.signupEmail, isNull);
      expect(cubit.state.screen, AuthScreen.otp);

      await cubit.verifyOtp('1234');

      expect(authService.verifiedOtpLoginName, 'learner@example.com');
      expect(authService.signupEmail, 'learner@example.com');
      expect(cubit.state.authenticationResult?.user.phone, isNull);
      expect(cubit.state.screen, AuthScreen.otp);
      expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
      await cubit.close();
    },
  );

  test('back from signup OTP restores the signup form and email', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');
    await cubit.submitSignup(
      const SignupFormData(
        name: 'Learner',
        email: 'learner@example.com',
        role: SignupRole.student,
        gender: SignupGender.studentMale,
      ),
    );
    cubit.backFromOtp();

    expect(cubit.state.screen, AuthScreen.registrationProfile);
    expect(cubit.state.loginName, 'learner@example.com');
    expect(cubit.pendingSignupForm?.email, 'learner@example.com');
    await cubit.close();
  });

  test(
    'accepts an email in the signup flow and opens registration profile',
    () async {
      final authService = _FakeAuthService(accountExists: false);
      final cubit = _buildCubit(
        authService: authService,
        initialState: const AuthFlowState(
          screen: AuthScreen.signup,
          authEntryMode: AuthEntryMode.signup,
        ),
      );

      await cubit.submitLoginName('learner@example.com');

      expect(authService.lookedUpLoginName, 'learner@example.com');
      expect(authService.sentOtpLoginName, isNull);
      expect(cubit.state.screen, AuthScreen.registrationProfile);
      expect(cubit.state.loginName, 'learner@example.com');
      await cubit.close();
    },
  );

  test('Back from registration profile returns to signup', () async {
    final cubit = _buildCubit(
      authService: _FakeAuthService(accountExists: false),
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitLoginName('learner@example.com');
    expect(cubit.state.screen, AuthScreen.registrationProfile);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.state.authEntryMode, AuthEntryMode.signup);
    expect(cubit.state.loginName, isNull);
    await cubit.close();
  });

  test(
    'handles Back for state-driven auth screens before leaving the app',
    () async {
      final cubit = AuthFlowCubit(authService: _FakeAuthService());

      cubit.openWelcomeDetails();
      expect(cubit.handleSystemBack(), isTrue);
      expect(cubit.state.screen, AuthScreen.welcome);

      await cubit.close();
      final otpCubit = AuthFlowCubit(
        authService: _FakeAuthService(),
        initialState: const AuthFlowState(screen: AuthScreen.otp),
      );
      expect(otpCubit.handleSystemBack(), isTrue);
      expect(otpCubit.state.screen, AuthScreen.login);

      expect(otpCubit.handleSystemBack(), isTrue);
      expect(otpCubit.state.screen, AuthScreen.welcomeDetails);

      otpCubit.openWelcome();
      expect(otpCubit.handleSystemBack(), isFalse);
      await otpCubit.close();
    },
  );

  test('returns auth entry to the screen that opened it', () async {
    final cubit = _buildCubit();

    cubit.openAuthEntry();
    expect(cubit.state.screen, AuthScreen.login);

    cubit.switchAuthEntryMode(AuthEntryMode.signup);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.login);
    expect(cubit.state.authEntryMode, AuthEntryMode.login);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.welcome);

    cubit.openWelcomeDetails();
    cubit.openSignupEntry();
    expect(cubit.state.screen, AuthScreen.signup);

    cubit.switchAuthEntryMode(AuthEntryMode.login);
    expect(cubit.state.screen, AuthScreen.login);
    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.state.authEntryMode, AuthEntryMode.signup);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.welcomeDetails);

    await cubit.close();
  });
}
