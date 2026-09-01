part of '../auth_cubit.dart';

extension AuthFlowNavigation on AuthFlowCubit {
  void openWelcome() => _emitState(state.copyWith(screen: AuthScreen.welcome));

  void openWelcomeDetails() =>
      _emitState(state.copyWith(screen: AuthScreen.welcomeDetails));

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
    _emitState(
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
    _emitState(
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
      _emitState(
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
      _emitState(
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

    _emitState(
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
    _emitState(
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

    _emitState(
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

    _emitState(
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
    _emitState(state.copyWith(phoneRegion: region));
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

    _emitState(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearAuthError: true,
        clearLoginLookup: true,
      ),
    );
  }
}
