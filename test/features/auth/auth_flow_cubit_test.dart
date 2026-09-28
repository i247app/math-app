import 'dart:async';

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
    this.identifierResponse,
    this.sendOtpFailure,
    this.signupFailure,
    this.verificationResult,
    this.sendOtpResult,
  });

  final bool accountExists;
  final bool verifyOtpIsValid;
  final bool? isTrusted;
  final List<AuthTrustedDevice> trustedDevices;
  final Object? lookupFailure;
  final Object? identifierResponse;
  final Object? sendOtpFailure;
  Object? signupFailure;
  final Future<VerifyOtpResult>? verificationResult;
  final Future<SendOtpResult>? sendOtpResult;
  int sentOtpCount = 0;
  String? checkedIdentifier;
  String? lookedUpLoginName;
  String? sentOtpLoginName;
  String? verifiedOtpLoginName;
  String? signupEmail;
  String? signupPhone;
  AuthOtpKind? sentOtpKind;
  int? sentOtpUserId;
  int? sentOtpTargetDeviceId;
  int? listedDeviceUserId;

  @override
  Future<dynamic> checkIdentifier(String identifier) async {
    checkedIdentifier = identifier;
    if (lookupFailure != null) throw lookupFailure!;
    return identifierResponse ??
        <String, dynamic>{
          'mstatus': accountExists ? 409 : 200,
          'status': 'Success',
          'email_otp_enable': true,
          'phone_otp_enable': false,
        };
  }

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
    sentOtpCount++;
    sentOtpLoginName = loginName;
    sentOtpKind = kind;
    sentOtpUserId = userId;
    sentOtpTargetDeviceId = targetDeviceId;
    if (sendOtpFailure != null) throw sendOtpFailure!;
    if (sendOtpResult != null) return sendOtpResult!;
    return const SendOtpResult(expiresIn: 30);
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String loginName,
    required String otpCode,
    required AuthOtpKind kind,
  }) async {
    verifiedOtpLoginName = loginName;
    if (verificationResult != null) return verificationResult!;
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
    if (signupFailure != null) throw signupFailure!;
    return LoginUser(id: 0, email: email, name: name, role: role);
  }

  @override
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
  }) async {
    signupPhone = phone;
    if (signupFailure != null) throw signupFailure!;
    return LoginUser(id: 0, phone: phone, name: name, role: role);
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

const _studentSignupForm = SignupFormData(
  name: 'Learner',
  role: SignupRole.student,
  gender: SignupGender.studentMale,
);

AuthFlowCubit _buildSignupCubit(_FakeAuthService service) => _buildCubit(
  authService: service,
  initialState: const AuthFlowState(
    screen: AuthScreen.signup,
    authEntryMode: AuthEntryMode.signup,
    initialEntryMode: AuthEntryMode.signup,
  ),
);

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

    await cubit.submitAuthIdentifier('learner@example.com');

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

    await cubit.submitAuthIdentifier('+84905666666');

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

      await cubit.submitAuthIdentifier('+84905666666');

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

  test('checks a signup email only on submit before sending OTP', () async {
    final authService = _FakeAuthService(accountExists: false);
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    expect(authService.checkedIdentifier, isNull);
    await cubit.submitAuthIdentifier('learner@example.com');

    expect(authService.checkedIdentifier, 'learner@example.com');
    expect(authService.lookedUpLoginName, isNull);
    expect(cubit.state.identifierExists, isFalse);
    expect(authService.sentOtpLoginName, 'learner@example.com');
    expect(cubit.state.screen, AuthScreen.otp);
    expect(cubit.state.otpExpiresIn, 30);
    expect(cubit.pendingSignupForm, isNull);
    await cubit.close();
  });

  test('phone signup verifies OTP and creates a phone account', () async {
    final service = _FakeAuthService(
      verifyOtpIsValid: true,
      identifierResponse: const <String, dynamic>{
        'mstatus': 200,
        'phone_otp_enable': true,
      },
    );
    final cubit = _buildSignupCubit(service);

    await cubit.submitAuthIdentifier('+84905666666');

    expect(service.checkedIdentifier, '+84905666666');
    expect(service.sentOtpLoginName, '+84905666666');
    expect(cubit.state.screen, AuthScreen.otp);

    await cubit.verifyOtp('1234');
    expect(service.verifiedOtpLoginName, '+84905666666');
    expect(cubit.state.screen, AuthScreen.registrationProfile);

    await cubit.submitSignup(_studentSignupForm);
    expect(service.signupPhone, '+84905666666');
    expect(service.signupEmail, isNull);
    expect(cubit.state.authenticationResult?.user.phone, '+84905666666');
    await cubit.close();
  });

  test('phone signup skips disabled OTP and creates a phone account', () async {
    final service = _FakeAuthService(
      identifierResponse: const <String, dynamic>{
        'mstatus': 200,
        'phone_otp_enable': false,
        'email_otp_enable': false,
      },
    );
    final cubit = _buildSignupCubit(service);

    await cubit.submitAuthIdentifier('+84905666666');
    expect(cubit.state.screen, AuthScreen.registrationProfile);
    expect(cubit.state.identifierLookupError, isNull);
    expect(service.sentOtpCount, 0);

    await cubit.submitSignup(_studentSignupForm);
    expect(service.signupPhone, '+84905666666');
    expect(service.signupEmail, isNull);
    expect(service.verifiedOtpLoginName, isNull);
    expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
    await cubit.close();
  });

  test('Back from profile without phone OTP returns to phone entry', () async {
    final service = _FakeAuthService(
      identifierResponse: const <String, dynamic>{
        'mstatus': 200,
        'phone_otp_enable': false,
      },
    );
    final cubit = _buildSignupCubit(service);

    await cubit.submitAuthIdentifier('+84905666666');
    expect(cubit.state.screen, AuthScreen.registrationProfile);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.state.loginName, '+84905666666');
    expect(service.sentOtpCount, 0);

    await cubit.submitSignup(_studentSignupForm);
    expect(service.signupPhone, isNull);
    await cubit.close();
  });

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

    await cubit.submitAuthIdentifier('learner@example.com');

    expect(authService.checkedIdentifier, 'learner@example.com');
    expect(cubit.state.authError, isNull);
    expect(cubit.state.identifierLookupError, 'Service unavailable');
    expect(cubit.state.identifierLookupErrorStatus, 503);
    expect(cubit.state.isCheckingIdentifier, isFalse);
    expect(cubit.state.screen, AuthScreen.signup);
    await cubit.close();
  });

  test('unknown identifier response keeps signup blocked', () async {
    final authService = _FakeAuthService(
      identifierResponse: const <String, dynamic>{'mstatus': 200},
    );
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitAuthIdentifier('learner@example.com');

    expect(cubit.state.identifierExists, isNull);
    expect(cubit.state.identifierLookupError, isNotEmpty);
    expect(cubit.state.isCheckingIdentifier, isFalse);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(authService.sentOtpLoginName, isNull);
    await cubit.close();
  });

  test('non-200 signup availability keeps the email on signup', () async {
    final authService = _FakeAuthService(
      identifierResponse: const <String, dynamic>{'mstatus': 4206},
    );
    final cubit = _buildCubit(
      authService: authService,
      initialState: const AuthFlowState(
        screen: AuthScreen.signup,
        authEntryMode: AuthEntryMode.signup,
      ),
    );

    await cubit.submitAuthIdentifier('learner@example.com');

    expect(cubit.state.authError, isNull);
    expect(cubit.state.identifierExists, isTrue);
    expect(cubit.state.identifierLookupErrorStatus, 4206);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(authService.sentOtpLoginName, isNull);
    await cubit.close();
  });

  test(
    'signup skips disabled email OTP and creates the user from the profile',
    () async {
      final service = _FakeAuthService(
        identifierResponse: const <String, dynamic>{
          'mstatus': 200,
          'email_otp_enable': false,
          'phone_otp_enable': true,
        },
      );
      final cubit = _buildSignupCubit(service);

      await cubit.submitAuthIdentifier('learner@example.com');

      expect(cubit.state.identifierExists, isFalse);
      expect(cubit.state.identifierLookupError, isNull);
      expect(cubit.state.screen, AuthScreen.registrationProfile);
      expect(service.sentOtpCount, 0);
      expect(service.signupEmail, isNull);

      await cubit.submitSignup(_studentSignupForm);

      expect(service.signupEmail, 'learner@example.com');
      expect(service.verifiedOtpLoginName, isNull);
      expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
      await cubit.close();
    },
  );

  test('Back from profile without OTP returns to email entry', () async {
    final service = _FakeAuthService(
      identifierResponse: const <String, dynamic>{
        'mstatus': 200,
        'email_otp_enable': false,
      },
    );
    final cubit = _buildSignupCubit(service);

    await cubit.submitAuthIdentifier('learner@example.com');
    expect(cubit.state.screen, AuthScreen.registrationProfile);

    expect(cubit.handleSystemBack(), isTrue);
    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.state.loginName, 'learner@example.com');
    expect(service.sentOtpCount, 0);

    await cubit.submitSignup(_studentSignupForm);
    expect(service.signupEmail, isNull);
    await cubit.close();
  });

  test(
    'signup email uses mstatus and email OTP without an availability field',
    () async {
      final service = _FakeAuthService(
        identifierResponse: const <String, dynamic>{
          'mstatus': 200,
          'email_otp_enable': true,
        },
      );
      final cubit = _buildSignupCubit(service);

      await cubit.submitAuthIdentifier('learner@example.com');

      expect(cubit.state.identifierExists, isFalse);
      expect(cubit.state.screen, AuthScreen.otp);
      expect(service.sentOtpCount, 1);
      await cubit.close();
    },
  );

  test(
    'returned user keeps existing email on signup without sending OTP',
    () async {
      final authService = _FakeAuthService(accountExists: true);
      final cubit = _buildCubit(
        authService: authService,
        initialState: const AuthFlowState(
          screen: AuthScreen.signup,
          authEntryMode: AuthEntryMode.signup,
        ),
      );

      await cubit.submitAuthIdentifier('learner@example.com');

      expect(authService.checkedIdentifier, 'learner@example.com');
      expect(authService.sentOtpLoginName, isNull);
      expect(cubit.state.identifierExists, isTrue);
      expect(cubit.state.screen, AuthScreen.signup);
      await cubit.close();
    },
  );

  test('signup uses the verified email even when the form omits it', () async {
    final service = _FakeAuthService(
      accountExists: false,
      verifyOtpIsValid: true,
    );
    final cubit = _buildSignupCubit(service);
    await cubit.submitAuthIdentifier('learner@example.com');
    await cubit.verifyOtp('1234');
    await cubit.submitSignup(_studentSignupForm);

    expect(service.signupEmail, 'learner@example.com');
    expect(service.sentOtpCount, 1);
    expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
    await cubit.close();
  });

  test(
    'email signup verifies OTP before collecting profile and creating account',
    () async {
      final service = _FakeAuthService(
        accountExists: false,
        verifyOtpIsValid: true,
      );
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');

      expect(service.sentOtpLoginName, 'learner@example.com');
      expect(service.sentOtpKind, AuthOtpKind.signup);
      expect(service.signupEmail, isNull);
      expect(cubit.state.screen, AuthScreen.otp);
      expect(cubit.pendingSignupForm, isNull);

      await cubit.verifyOtp('1234');

      expect(service.verifiedOtpLoginName, 'learner@example.com');
      expect(service.signupEmail, isNull);
      expect(cubit.state.screen, AuthScreen.registrationProfile);
      expect(cubit.state.isVerifyingOtp, isFalse);
      expect(cubit.state.authenticationResult, isNull);

      await cubit.submitSignup(_studentSignupForm);

      expect(service.signupEmail, 'learner@example.com');
      expect(cubit.state.authenticationResult?.user.phone, isNull);
      expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
      expect(cubit.state.isSigningUp, isFalse);
      await cubit.close();
    },
  );

  test(
    'Back from signup OTP restores email entry and requires verification again',
    () async {
      final service = _FakeAuthService(
        accountExists: false,
        verifyOtpIsValid: true,
      );
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');
      expect(cubit.handleSystemBack(), isTrue);

      expect(cubit.state.screen, AuthScreen.signup);
      expect(cubit.state.loginName, 'learner@example.com');
      expect(cubit.pendingSignupForm, isNull);
      await cubit.submitSignup(_studentSignupForm);
      expect(service.signupEmail, isNull);

      await cubit.submitAuthIdentifier('another@example.com');
      await cubit.verifyOtp('1234');
      await cubit.submitSignup(_studentSignupForm);
      expect(service.signupEmail, 'another@example.com');
      await cubit.close();
    },
  );

  test(
    'Back from registration profile returns to OTP and requests a fresh code',
    () async {
      final service = _FakeAuthService(
        accountExists: false,
        verifyOtpIsValid: true,
      );
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');
      await cubit.verifyOtp('1234');
      expect(cubit.state.screen, AuthScreen.registrationProfile);

      expect(cubit.handleSystemBack(), isTrue);
      expect(cubit.state.screen, AuthScreen.otp);
      expect(cubit.state.authEntryMode, AuthEntryMode.signup);
      expect(cubit.state.loginName, 'learner@example.com');
      await Future<void>.delayed(Duration.zero);
      expect(service.sentOtpCount, 2);

      await cubit.submitSignup(_studentSignupForm);
      expect(service.signupEmail, isNull);
      await cubit.verifyOtp('1234');
      expect(cubit.state.screen, AuthScreen.registrationProfile);
      await cubit.close();
    },
  );

  test(
    'a failed signup OTP send keeps the email entry available for retry',
    () async {
      final service = _FakeAuthService(
        accountExists: false,
        sendOtpFailure: const AuthException('Send failed', status: 503),
      );
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');

      expect(cubit.state.screen, AuthScreen.signup);
      expect(cubit.state.authError, 'Send failed');
      expect(cubit.state.isSendingOtp, isFalse);
      expect(service.signupEmail, isNull);
      await cubit.close();
    },
  );

  test(
    'an invalid signup OTP cannot open the profile or create an account',
    () async {
      final service = _FakeAuthService(accountExists: false);
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');
      await cubit.verifyOtp('0000');
      await cubit.submitSignup(_studentSignupForm);

      expect(cubit.state.screen, AuthScreen.otp);
      expect(cubit.state.otpError, isNotEmpty);
      expect(cubit.state.isVerifyingOtp, isFalse);
      expect(service.signupEmail, isNull);
      expect(cubit.state.authenticationResult, isNull);
      await cubit.close();
    },
  );

  test(
    'account creation failure retains the verified email and profile for retry',
    () async {
      final service = _FakeAuthService(
        accountExists: false,
        verifyOtpIsValid: true,
        signupFailure: const AuthException('Name already exists'),
      );
      final cubit = _buildSignupCubit(service);
      await cubit.submitAuthIdentifier('learner@example.com');
      await cubit.verifyOtp('1234');
      await cubit.submitSignup(_studentSignupForm);

      expect(cubit.state.screen, AuthScreen.registrationProfile);
      expect(cubit.state.authError, 'Name already exists');
      expect(cubit.state.isSigningUp, isFalse);
      expect(cubit.pendingSignupForm?.name, 'Learner');
      expect(cubit.pendingSignupForm?.email, 'learner@example.com');
      expect(cubit.state.authenticationResult, isNull);

      service.signupFailure = null;
      await cubit.submitSignup(_studentSignupForm);
      expect(service.sentOtpCount, 1);
      expect(cubit.state.authenticationResult?.isNewlyRegistered, isTrue);
      await cubit.close();
    },
  );

  test('a late signup OTP verification cannot advance after Back', () async {
    final verification = Completer<VerifyOtpResult>();
    final service = _FakeAuthService(
      accountExists: false,
      verificationResult: verification.future,
    );
    final cubit = _buildSignupCubit(service);
    await cubit.submitAuthIdentifier('learner@example.com');
    final pendingVerification = cubit.verifyOtp('1234');
    cubit.backFromOtp();
    verification.complete(const VerifyOtpResult(isValid: true));
    await pendingVerification;

    expect(cubit.state.screen, AuthScreen.signup);
    expect(cubit.state.isVerifyingOtp, isFalse);
    expect(cubit.state.authenticationResult, isNull);
    expect(service.signupEmail, isNull);
    await cubit.close();
  });

  test(
    'a late signup OTP send cannot reopen OTP after leaving signup',
    () async {
      final send = Completer<SendOtpResult>();
      final service = _FakeAuthService(
        accountExists: false,
        sendOtpResult: send.future,
      );
      final cubit = _buildSignupCubit(service);
      final submission = cubit.submitAuthIdentifier('learner@example.com');
      await Future<void>.delayed(Duration.zero);
      cubit.backFromAuthEntry();
      send.complete(const SendOtpResult(expiresIn: 30));
      await submission;

      expect(cubit.state.screen, AuthScreen.welcomeDetails);
      expect(cubit.state.isSendingOtp, isFalse);
      await cubit.close();
    },
  );

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
