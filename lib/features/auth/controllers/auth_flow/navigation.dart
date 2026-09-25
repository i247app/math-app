part of '../auth_cubit.dart';

AuthScreen _screenForEntryMode(AuthEntryMode mode) => switch (mode) {
  AuthEntryMode.login => AuthScreen.login,
  AuthEntryMode.signup => AuthScreen.signup,
};

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
      case AuthScreen.signup:
        backFromAuthEntry();
        return true;
      case AuthScreen.deviceVerification:
        backFromDeviceVerification();
        return true;
      case AuthScreen.otp:
        backFromOtp();
        return true;
      case AuthScreen.registrationProfile:
        backFromRegistrationProfile();
        return true;
      case AuthScreen.welcome:
        return false;
    }
  }

  AuthScreen _entryBackScreenForCurrentFlow() {
    return switch (state.screen) {
      AuthScreen.login ||
      AuthScreen.signup ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.registrationProfile => state.entryBackScreen,
      final screen => screen,
    };
  }

  AuthEntryMode _initialEntryModeForCurrentFlow(AuthEntryMode nextMode) {
    return switch (state.screen) {
      AuthScreen.login ||
      AuthScreen.signup ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.registrationProfile => state.initialEntryMode,
      AuthScreen.welcome || AuthScreen.welcomeDetails => nextMode,
    };
  }

  bool get backFromAuthEntrySwitchesMode =>
      (state.screen == AuthScreen.login || state.screen == AuthScreen.signup) &&
      state.authEntryMode != state.initialEntryMode;

  void backFromAuthEntry() {
    if (state.screen != AuthScreen.login && state.screen != AuthScreen.signup) {
      return;
    }

    if (backFromAuthEntrySwitchesMode) {
      switchAuthEntryMode(state.initialEntryMode);
      return;
    }

    final target = switch (state.entryBackScreen) {
      AuthScreen.login ||
      AuthScreen.signup ||
      AuthScreen.deviceVerification ||
      AuthScreen.otp ||
      AuthScreen.registrationProfile => AuthScreen.welcomeDetails,
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

  void openAuthEntry({AuthEntryMode? mode}) {
    final nextMode = mode ?? state.authEntryMode;
    _emitState(
      state.copyWith(
        screen: _screenForEntryMode(nextMode),
        entryBackScreen: _entryBackScreenForCurrentFlow(),
        initialEntryMode: _initialEntryModeForCurrentFlow(nextMode),
        authEntryMode: nextMode,
        clearOtpError: true,
      ),
    );
  }

  void backFromOtp() {
    if (state.screen != AuthScreen.otp) {
      return;
    }

    final signupEmail = _pendingSignupEmail;
    if (state.otpFlow == OtpFlow.signup &&
        signupEmail != null &&
        _pendingSignupForm != null) {
      final otpIdentifier = state.loginName?.trim();
      if (otpIdentifier != null && otpIdentifier.isNotEmpty) {
        unawaited(_authService.clearPendingLogin(otpIdentifier));
      }
      _emitState(
        state.copyWith(
          screen: AuthScreen.registrationProfile,
          loginName: signupEmail,
          isSendingOtp: false,
          isVerifyingOtp: false,
          isSigningUp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
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
          clearOtpExpiry: true,
          clearOtpError: true,
          clearTrustedDeviceError: true,
        ),
      );
      return;
    }

    openAuthEntry();
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
    openAuthEntry(mode: AuthEntryMode.login);
  }

  void openSignupEntry() {
    _emitState(
      state.copyWith(
        screen: AuthScreen.signup,
        entryBackScreen: _entryBackScreenForCurrentFlow(),
        initialEntryMode: AuthEntryMode.signup,
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
    if (state.authEntryMode == mode &&
        state.screen == _screenForEntryMode(mode)) {
      return;
    }

    _emitState(
      state.copyWith(
        screen: _screenForEntryMode(mode),
        authEntryMode: mode,
        clearAuthError: true,
        clearOtpError: true,
        clearOtpExpiry: true,
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearLoginName: true,
        clearLoginLookup: true,
        clearTrustedDeviceState: true,
      ),
    );
  }

  void backFromRegistrationProfile() {
    final loginName = state.loginName?.trim();
    if (loginName != null && loginName.isNotEmpty) {
      unawaited(_authService.clearPendingLogin(loginName));
    }
    _clearPendingSignup();

    _emitState(
      state.copyWith(
        screen: AuthScreen.signup,
        clearLoginName: true,
        isVerifyingOtp: false,
        isSigningUp: false,
        otpFlow: OtpFlow.login,
        clearAuthError: true,
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
