import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/errors/auth_status.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';

import 'package:numi/features/auth/application/auth_state.dart';

class AuthFlowCubit extends Cubit<AuthFlowState> {
  AuthFlowCubit({required AuthService authService, AuthFlowState? initialState})
    : _authService = authService,
      super(initialState ?? const AuthFlowState());

  final AuthService _authService;
  SignupFormData? _pendingSignupForm;
  String? _pendingSignupPhone;

  SignupFormData? get pendingSignupForm => _pendingSignupForm;

  void openWelcome() => emit(state.copyWith(screen: AuthScreen.welcome));

  void openWelcomeDetails() =>
      emit(state.copyWith(screen: AuthScreen.welcomeDetails));

  /// Handles a platform Back gesture for the auth flow, whose screens are
  /// state-driven rather than separate Navigator routes.
  ///
  /// Returns false at root screens so Android can perform its normal task
  /// backgrounding behavior.
  bool handleSystemBack() {
    switch (state.screen) {
      case AuthScreen.welcomeDetails:
        openWelcome();
        return true;
      case AuthScreen.login:
        backFromLogin();
        return true;
      case AuthScreen.deviceVerification:
        backFromDeviceVerification();
        return true;
      case AuthScreen.otp:
        backFromOtp();
        return true;
      case AuthScreen.signup:
        cancelSignupToLogin();
        return true;
      case AuthScreen.welcome:
        return false;
    }
  }

  AuthScreen _loginBackScreenForCurrentFlow() {
    return switch (state.screen) {
      AuthScreen.login ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.signup => state.loginBackScreen,
      final screen => screen,
    };
  }

  AuthEntryMode _loginEntryModeForCurrentFlow(AuthEntryMode nextMode) {
    return switch (state.screen) {
      AuthScreen.login ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.signup => state.loginEntryMode,
      AuthScreen.welcome || AuthScreen.welcomeDetails => nextMode,
    };
  }

  bool get backFromLoginSwitchesEntryMode =>
      state.screen == AuthScreen.login &&
      state.authEntryMode != state.loginEntryMode;

  void backFromLogin() {
    if (state.screen != AuthScreen.login) {
      return;
    }

    if (backFromLoginSwitchesEntryMode) {
      switchAuthEntryMode(state.loginEntryMode);
      return;
    }

    final target = switch (state.loginBackScreen) {
      AuthScreen.login ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.signup => AuthScreen.welcomeDetails,
      final screen => screen,
    };
    emit(
      state.copyWith(
        screen: target,
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearLoginName: true,
        clearLoginLookup: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );
  }

  void openLogin({AuthEntryMode? mode}) {
    final nextMode = mode ?? state.authEntryMode;
    emit(
      state.copyWith(
        screen: AuthScreen.login,
        loginBackScreen: _loginBackScreenForCurrentFlow(),
        loginEntryMode: _loginEntryModeForCurrentFlow(nextMode),
        authEntryMode: nextMode,
        clearOtpError: true,
      ),
    );
  }

  void backFromOtp() {
    if (state.screen != AuthScreen.otp) {
      return;
    }

    final signupPhone = _pendingSignupPhone;
    if (state.otpFlow == OtpFlow.signup &&
        signupPhone != null &&
        _pendingSignupForm != null) {
      final otpIdentifier = state.loginName?.trim();
      if (otpIdentifier != null && otpIdentifier.isNotEmpty) {
        unawaited(_authService.clearPendingLogin(otpIdentifier));
      }
      emit(
        state.copyWith(
          screen: AuthScreen.signup,
          loginName: signupPhone,
          isSendingOtp: false,
          isVerifyingOtp: false,
          isSigningUp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      return;
    }

    if (state.otpFlow == OtpFlow.login &&
        state.selectedTrustedDeviceId != null &&
        state.trustedDevices.isNotEmpty) {
      emit(
        state.copyWith(
          screen: AuthScreen.deviceVerification,
          isSendingOtp: false,
          isVerifyingOtp: false,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
          clearTrustedDeviceError: true,
        ),
      );
      return;
    }

    openLogin();
  }

  void backFromDeviceVerification() {
    if (state.screen != AuthScreen.deviceVerification) {
      return;
    }

    emit(
      state.copyWith(
        screen: AuthScreen.login,
        isLoadingTrustedDevices: false,
        isSendingOtp: false,
        clearAuthError: true,
        clearOtpError: true,
        clearTrustedDeviceState: true,
      ),
    );
  }

  void openLoginFromWelcome() {
    openLogin(mode: AuthEntryMode.login);
  }

  void openSignupEntry() {
    emit(
      state.copyWith(
        screen: AuthScreen.login,
        loginBackScreen: _loginBackScreenForCurrentFlow(),
        loginEntryMode: AuthEntryMode.signup,
        authEntryMode: AuthEntryMode.signup,
        clearAuthError: true,
        clearOtpError: true,
        clearLoginName: true,
        clearLoginLookup: true,
        clearTrustedDeviceState: true,
      ),
    );
  }

  void switchAuthEntryMode(AuthEntryMode mode) {
    if (state.authEntryMode == mode) {
      return;
    }

    emit(
      state.copyWith(
        authEntryMode: mode,
        clearAuthError: true,
        clearOtpError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearLoginName: true,
        clearLoginLookup: true,
        clearTrustedDeviceState: true,
      ),
    );
  }

  void cancelSignupToLogin() {
    final loginName = state.loginName?.trim();
    if (loginName != null && loginName.isNotEmpty) {
      unawaited(_authService.clearPendingLogin(loginName));
    }
    _clearPendingSignup();

    emit(
      state.copyWith(
        screen: AuthScreen.login,
        clearLoginName: true,
        isVerifyingOtp: false,
        isSigningUp: false,
        otpFlow: OtpFlow.login,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
        clearLoginLookup: true,
        clearTrustedDeviceState: true,
      ),
    );
  }

  void selectPhoneRegion(PhoneRegion region) {
    emit(state.copyWith(phoneRegion: region));
  }

  void clearLoginLookup() {
    if (!state.isCheckingLoginName &&
        !state.isSendingOtp &&
        state.checkedLoginName == null &&
        state.loginNameExists == null &&
        state.loginLookupUser == null &&
        state.loginLookupError == null &&
        state.loginLookupErrorStatus == null &&
        state.authError == null) {
      return;
    }

    emit(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearAuthError: true,
        clearLoginLookup: true,
      ),
    );
  }

  Future<void> lookupSignupPhone(String phone) async {
    if (state.authEntryMode != AuthEntryMode.signup ||
        (state.isCheckingLoginName && state.checkedLoginName == phone)) {
      return;
    }

    emit(
      state.copyWith(
        loginName: phone,
        checkedLoginName: phone,
        isCheckingLoginName: true,
        clearLoginNameExists: true,
        clearLoginLookupUser: true,
        clearLoginLookupError: true,
        clearLoginLookupErrorStatus: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginName(phone);
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.checkedLoginName != phone) {
        return;
      }

      emit(
        state.copyWith(
          loginName: phone,
          checkedLoginName: phone,
          isCheckingLoginName: false,
          loginNameExists: result.exists,
          loginLookupUser: result.user,
          loginLookupError: result.exists ? null : result.message,
          loginLookupErrorStatus: result.exists ? null : result.status,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearLoginLookupError: result.exists,
          clearLoginLookupErrorStatus: result.exists,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (isClosed || state.checkedLoginName != phone) {
        return;
      }

      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            loginName: phone,
            checkedLoginName: phone,
            isCheckingLoginName: false,
            loginNameExists: false,
            loginLookupError: error.message,
            loginLookupErrorStatus: error.status,
            clearAuthError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isCheckingLoginName: false,
          authError: error.message,
          clearLoginLookup: true,
        ),
      );
    } catch (_) {
      if (isClosed || state.checkedLoginName != phone) {
        return;
      }

      emit(
        state.copyWith(
          isCheckingLoginName: false,
          authError: AppStrings.current(AppKeys.authLoginNameCheckFailed),
          clearLoginLookup: true,
        ),
      );
    }
  }

  Future<void> submitLoginName(String loginName) async {
    if (state.isSendingOtp) {
      return;
    }

    final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
    if (isSignupEntry && loginName.contains('@')) {
      emit(state.copyWith(authError: AppStrings.current(AppKeys.invalidPhone)));
      return;
    }

    if (isSignupEntry) {
      if (state.loginNameExists == true &&
          state.checkedLoginName == loginName) {
        emit(
          state.copyWith(
            authError: AppStrings.current(AppKeys.signupPhoneAlreadyRegistered),
          ),
        );
        return;
      }

      _pendingSignupPhone = loginName;
      _pendingSignupForm = null;
      emit(
        state.copyWith(
          screen: AuthScreen.signup,
          loginName: loginName,
          isCheckingLoginName: false,
          isSendingOtp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loginName: loginName,
        checkedLoginName: loginName,
        isCheckingLoginName: true,
        isSendingOtp: true,
        clearLoginNameExists: true,
        clearLoginLookupUser: true,
        clearLoginLookupError: true,
        clearLoginLookupErrorStatus: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginName(loginName);
      final user = result.user;
      if (isClosed || state.checkedLoginName != loginName) {
        return;
      }

      emit(
        state.copyWith(
          isCheckingLoginName: false,
          loginNameExists: result.exists,
          loginLookupUser: user,
          loginLookupError: result.exists ? null : result.message,
          loginLookupErrorStatus: result.exists ? null : result.status,
          clearLoginLookupError: result.exists,
          clearLoginLookupErrorStatus: result.exists,
        ),
      );

      if (!result.exists) {
        emit(
          state.copyWith(
            screen: AuthScreen.login,
            loginName: loginName,
            checkedLoginName: loginName,
            loginNameExists: false,
            loginLookupError: result.message,
            loginLookupErrorStatus: result.status,
            isCheckingLoginName: false,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      if (user == null) {
        emit(
          state.copyWith(
            isCheckingLoginName: false,
            isSendingOtp: false,
            authError: AppStrings.current(AppKeys.missingOtpUser),
          ),
        );
        return;
      }

      if (result.isTrusted == false) {
        await _openDeviceVerification(user);
        return;
      }

      if (_canSkipLoginOtp(result)) {
        _emitAuthenticationSucceeded(user, isSendingOtp: false);
        return;
      }

      emit(
        state.copyWith(
          screen: AuthScreen.otp,
          loginName: loginName,
          otpFlow: OtpFlow.login,
          isCheckingLoginName: false,
          isSendingOtp: true,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendLoginOtp(loginName);
    } on AuthException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            screen: AuthScreen.login,
            loginName: loginName,
            checkedLoginName: loginName,
            loginNameExists: false,
            loginLookupError: error.message,
            loginLookupErrorStatus: error.status,
            isCheckingLoginName: false,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      _emitAuthError(
        error.message,
        isCheckingLoginName: false,
        isSendingOtp: false,
      );
    } catch (_) {
      _emitAuthError(
        AppStrings.current(AppKeys.authLoginNameCheckFailed),
        isCheckingLoginName: false,
        isSendingOtp: false,
      );
    }
  }

  Future<void> _openDeviceVerification(LoginUser user) async {
    emit(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: true,
        isLoadingTrustedDevices: true,
        trustedDevices: const <AuthTrustedDevice>[],
        clearSelectedTrustedDevice: true,
        clearTrustedDeviceError: true,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );

    try {
      final devices = await _authService.listTrustedDevices(userId: user.id);
      if (isClosed ||
          state.loginLookupUser?.id != user.id ||
          state.loginName == null) {
        return;
      }

      if (devices.isEmpty) {
        final loginName = state.loginName!;
        emit(
          state.copyWith(
            screen: AuthScreen.otp,
            trustedDevices: devices,
            isLoadingTrustedDevices: false,
            otpFlow: OtpFlow.login,
            showDevOtpPreview: true,
            clearSelectedTrustedDevice: true,
            clearTrustedDeviceError: true,
            clearAuthError: true,
            clearOtpError: true,
          ),
        );
        await _sendLoginOtp(loginName);
        return;
      }

      emit(
        state.copyWith(
          screen: AuthScreen.deviceVerification,
          trustedDevices: devices,
          isSendingOtp: false,
          isLoadingTrustedDevices: false,
          clearSelectedTrustedDevice: true,
          clearTrustedDeviceError: true,
        ),
      );
    } on AuthException catch (error) {
      _emitAuthError(
        error.message,
        isCheckingLoginName: false,
        isSendingOtp: false,
      );
    } catch (_) {
      _emitAuthError(
        AppStrings.current(AppKeys.trustedDeviceLoadFailed),
        isCheckingLoginName: false,
        isSendingOtp: false,
      );
    }
  }

  Future<void> reloadTrustedDevices() async {
    final user = state.loginLookupUser;
    if (state.isLoadingTrustedDevices ||
        state.isSendingOtp ||
        state.screen != AuthScreen.deviceVerification ||
        user == null ||
        user.id <= 0) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingTrustedDevices: true,
        trustedDevices: const <AuthTrustedDevice>[],
        clearSelectedTrustedDevice: true,
        clearTrustedDeviceError: true,
      ),
    );
    await _loadTrustedDevices(user);
  }

  Future<void> _loadTrustedDevices(LoginUser user) async {
    try {
      final devices = await _authService.listTrustedDevices(userId: user.id);
      if (isClosed ||
          state.screen != AuthScreen.deviceVerification ||
          state.loginLookupUser?.id != user.id) {
        return;
      }

      emit(
        state.copyWith(
          trustedDevices: devices,
          isLoadingTrustedDevices: false,
          clearSelectedTrustedDevice: true,
          clearTrustedDeviceError: true,
        ),
      );
    } on AuthException catch (error) {
      if (isClosed || state.screen != AuthScreen.deviceVerification) {
        return;
      }
      emit(
        state.copyWith(
          isLoadingTrustedDevices: false,
          trustedDeviceError: error.message,
          clearSelectedTrustedDevice: true,
        ),
      );
    } catch (_) {
      if (isClosed || state.screen != AuthScreen.deviceVerification) {
        return;
      }
      emit(
        state.copyWith(
          isLoadingTrustedDevices: false,
          trustedDeviceError: AppStrings.current(
            AppKeys.trustedDeviceLoadFailed,
          ),
          clearSelectedTrustedDevice: true,
        ),
      );
    }
  }

  void selectTrustedDevice(int deviceId) {
    if (state.screen != AuthScreen.deviceVerification ||
        state.isLoadingTrustedDevices ||
        state.isSendingOtp ||
        !state.trustedDevices.any((device) => device.deviceId == deviceId)) {
      return;
    }

    emit(
      state.copyWith(
        selectedTrustedDeviceId: deviceId,
        clearTrustedDeviceError: true,
      ),
    );
  }

  Future<void> sendOtpToTrustedDevice() async {
    final loginName = state.loginName;
    final user = state.loginLookupUser;
    final targetDeviceId = state.selectedTrustedDeviceId;
    if (state.screen != AuthScreen.deviceVerification ||
        state.isSendingOtp ||
        loginName == null ||
        user == null ||
        user.id <= 0 ||
        targetDeviceId == null) {
      return;
    }

    await _sendLoginOtp(
      loginName,
      userId: user.id,
      targetDeviceId: targetDeviceId,
    );
  }

  Future<void> resendLoginOtp() async {
    final loginName = state.loginName;
    if (state.isSendingOtp || loginName == null || loginName.trim().isEmpty) {
      return;
    }

    if (state.otpFlow == OtpFlow.signup) {
      await _sendSignupOtp(loginName);
      return;
    }

    await _sendLoginOtp(loginName);
  }

  Future<void> _sendSignupOtp(String email) async {
    emit(
      state.copyWith(
        isSendingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final otp = await _authService.sendOtp(
        loginName: email,
        kind: AuthOtpKind.signup,
      );
      if (state.loginName != email || state.otpFlow != OtpFlow.signup) {
        return;
      }

      _emitOtpSent(loginName: email, otp: otp, flow: OtpFlow.signup);
    } on AuthException catch (error) {
      if (state.loginName != email || state.otpFlow != OtpFlow.signup) {
        return;
      }
      _emitAuthError(error.message, isSendingOtp: false, isSigningUp: false);
    } catch (_) {
      if (state.loginName != email || state.otpFlow != OtpFlow.signup) {
        return;
      }
      _emitAuthError(
        AppStrings.current(AppKeys.signupOtpFailed),
        isSendingOtp: false,
        isSigningUp: false,
      );
    }
  }

  Future<void> _sendLoginOtp(
    String loginName, {
    int? userId,
    int? targetDeviceId,
  }) async {
    final resolvedTargetDeviceId =
        targetDeviceId ?? state.selectedTrustedDeviceId;
    final resolvedUserId =
        userId ??
        (resolvedTargetDeviceId == null ? null : state.loginLookupUser?.id);
    emit(
      state.copyWith(
        isSendingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
        clearTrustedDeviceError: true,
      ),
    );

    try {
      final otp = await _authService.sendOtp(
        loginName: loginName,
        kind: AuthOtpKind.login,
        userId: resolvedUserId,
        targetDeviceId: resolvedTargetDeviceId,
      );
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      _emitOtpSent(loginName: loginName, otp: otp, flow: OtpFlow.login);
    } on AuthException catch (error) {
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      _emitLoginOtpSendError(error.message);
    } catch (_) {
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      _emitLoginOtpSendError(AppStrings.current(AppKeys.loginOtpFailed));
    }
  }

  void _emitLoginOtpSendError(String message) {
    if (state.screen == AuthScreen.deviceVerification) {
      emit(
        state.copyWith(
          isSendingOtp: false,
          trustedDeviceError: message,
          clearAuthError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSendingOtp: false,
        otpError: message,
        otpErrorId: state.otpErrorId + 1,
        clearAuthError: true,
      ),
    );
  }

  void _emitOtpSent({
    required String loginName,
    required SendOtpResult otp,
    required OtpFlow flow,
  }) {
    final exposesOtpPreview = flow == OtpFlow.signup || state.showDevOtpPreview;
    emit(
      state.copyWith(
        screen: AuthScreen.otp,
        loginName: loginName,
        otpExpiresAt: otp.expiresAt,
        otpExpiresIn: otp.expiresIn,
        devOtpCode: exposesOtpPreview ? otp.otpCode : null,
        devOtpPurpose: exposesOtpPreview ? otp.purpose : null,
        showDevOtpPreview: exposesOtpPreview,
        otpPreviewId: state.otpPreviewId + 1,
        otpFlow: flow,
        isSendingOtp: false,
        isSigningUp: false,
        clearAuthError: true,
        clearDevOtp: !exposesOtpPreview || otp.otpCode == null,
        clearOtpExpiry: otp.expiresAt == null,
        clearOtpError: true,
      ),
    );
  }

  Future<void> verifyOtp(String otpCode) async {
    final loginName = state.loginName;
    if (state.isVerifyingOtp || loginName == null) {
      return;
    }

    emit(
      state.copyWith(
        isVerifyingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final otpFlow = state.otpFlow;
      final result = await _authService.verifyOtp(
        loginName: loginName,
        otpCode: otpCode,
        kind: otpFlow == OtpFlow.signup
            ? AuthOtpKind.signup
            : AuthOtpKind.login,
      );

      if (!result.isValid) {
        emit(
          state.copyWith(
            isVerifyingOtp: false,
            otpError: result.message ?? AppStrings.current(AppKeys.invalidOtp),
            otpErrorId: state.otpErrorId + 1,
            clearAuthError: true,
          ),
        );
        return;
      }

      if (otpFlow == OtpFlow.signup) {
        final signupPhone = _pendingSignupPhone;
        final signupForm = _pendingSignupForm;
        if (signupPhone == null || signupForm == null) {
          emit(
            state.copyWith(
              isVerifyingOtp: false,
              otpError: AppStrings.current(AppKeys.signupFailed),
              otpErrorId: state.otpErrorId + 1,
              clearAuthError: true,
            ),
          );
          return;
        }

        try {
          await _completeSignup(
            phone: signupPhone,
            form: signupForm,
            isVerifyingOtp: false,
          );
        } on AuthException catch (error) {
          _returnToSignupAfterOtp(error.message);
        } catch (_) {
          _returnToSignupAfterOtp(AppStrings.current(AppKeys.signupFailed));
        }
        return;
      }

      if (result.user == null) {
        emit(
          state.copyWith(
            isVerifyingOtp: false,
            otpError: AppStrings.current(AppKeys.missingOtpUser),
            otpErrorId: state.otpErrorId + 1,
            clearAuthError: true,
          ),
        );
        return;
      }

      _emitAuthenticationSucceeded(result.user!, isVerifyingOtp: false);
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: error.message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: AppStrings.current(AppKeys.verifyOtpFailed),
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    }
  }

  static bool _canSkipLoginOtp(AuthLoginLookupResult result) {
    return result.isTrusted == true && !result.requiredOtp;
  }

  Future<void> submitSignup(SignupFormData form) async {
    final phone = _pendingSignupPhone ?? state.loginName;
    final trimmedName = form.name.trim();
    final emailValue = form.email?.trim();
    final trimmedEmail = emailValue == null || emailValue.isEmpty
        ? null
        : emailValue;
    if (state.isSigningUp || phone == null) {
      return;
    }

    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.childNameRequired),
        ),
      );
      return;
    }

    if (trimmedEmail != null && !isValidEmailInput(trimmedEmail)) {
      emit(state.copyWith(authError: AppStrings.current(AppKeys.invalidEmail)));
      return;
    }

    final normalizedForm = SignupFormData(
      name: trimmedName,
      email: trimmedEmail,
      role: form.role,
      gender: form.gender,
    );
    _pendingSignupPhone = phone;
    _pendingSignupForm = normalizedForm;

    if (trimmedEmail != null) {
      emit(
        state.copyWith(
          loginName: trimmedEmail,
          isSigningUp: true,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendSignupOtp(trimmedEmail);
      return;
    }

    emit(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      await _completeSignup(
        phone: phone,
        form: normalizedForm,
        isSigningUp: false,
      );
    } on AuthException catch (error) {
      emit(state.copyWith(isSigningUp: false, authError: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSigningUp: false,
          authError: AppStrings.current(AppKeys.signupFailed),
        ),
      );
    }
  }

  Future<void> _completeSignup({
    required String phone,
    required SignupFormData form,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    final user = await _authService.signupWithPhone(
      phone: phone,
      name: form.name,
      role: form.role.apiValue,
      email: form.email,
    );
    _clearPendingSignup();
    _emitAuthenticationSucceeded(
      user,
      isVerifyingOtp: isVerifyingOtp,
      isSigningUp: isSigningUp,
      isNewlyRegistered: true,
    );
  }

  void _returnToSignupAfterOtp(String message) {
    final signupPhone = _pendingSignupPhone;
    emit(
      state.copyWith(
        screen: AuthScreen.signup,
        loginName: signupPhone,
        isVerifyingOtp: false,
        isSigningUp: false,
        authError: message,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );
  }

  void _clearPendingSignup() {
    _pendingSignupPhone = null;
    _pendingSignupForm = null;
  }

  Future<void> resumeRememberedLogin({
    required String loginName,
    required LoginUser fallbackUser,
  }) async {
    emit(
      state.copyWith(
        screen: AuthScreen.login,
        loginName: loginName,
        checkedLoginName: loginName,
        isCheckingLoginName: true,
        clearAuthError: true,
        clearOtpError: true,
        clearAuthenticationResult: true,
      ),
    );
    try {
      final result = await _authService.lookupLoginName(loginName);
      if (isClosed) {
        return;
      }
      final user = result.user ?? fallbackUser;
      if (_canSkipLoginOtp(result)) {
        _emitAuthenticationSucceeded(user, isCheckingLoginName: false);
        return;
      }
      emit(
        state.copyWith(
          screen: AuthScreen.login,
          isCheckingLoginName: false,
          authError: AppStrings.current(AppKeys.pinLoginFailed),
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            screen: AuthScreen.login,
            isCheckingLoginName: false,
            authError: error.message,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            screen: AuthScreen.login,
            isCheckingLoginName: false,
            authError: AppStrings.current(AppKeys.loginOtpFailed),
          ),
        );
      }
    }
  }

  void consumeAuthenticationResult() {
    if (state.authenticationResult != null) {
      emit(state.copyWith(clearAuthenticationResult: true));
    }
  }

  void _emitAuthenticationSucceeded(
    LoginUser user, {
    bool isNewlyRegistered = false,
    bool? isCheckingLoginName,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        isCheckingLoginName: isCheckingLoginName,
        isSendingOtp: isSendingOtp,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
        clearAuthError: true,
        clearOtpError: true,
        authenticationResult: AuthenticationResult(
          user: user,
          loginName: state.loginName,
          isNewlyRegistered: isNewlyRegistered,
        ),
        authenticationResultId: state.authenticationResultId + 1,
      ),
    );
  }

  void _emitAuthError(
    String message, {
    bool? isCheckingLoginName,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) {
    if (state.screen == AuthScreen.otp) {
      emit(
        state.copyWith(
          isCheckingLoginName: isCheckingLoginName,
          isSendingOtp: isSendingOtp,
          isVerifyingOtp: isVerifyingOtp,
          isSigningUp: isSigningUp,
          otpError: message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isCheckingLoginName: isCheckingLoginName,
        isSendingOtp: isSendingOtp,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
        authError: message,
      ),
    );
  }
}
