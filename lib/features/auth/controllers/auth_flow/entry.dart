part of '../auth_cubit.dart';

extension AuthFlowEntry on AuthFlowCubit {
  Future<void> lookupSignupEmail(String email) async {
    if (state.screen != AuthScreen.signup ||
        state.authEntryMode != AuthEntryMode.signup ||
        state.isCheckingLoginName) {
      return;
    }

    _emitState(
      state.copyWith(
        loginName: email,
        checkedLoginName: email,
        isCheckingLoginName: true,
        clearLoginNameExists: true,
        clearLoginLookupUser: true,
        clearLoginLookupError: true,
        clearLoginLookupErrorStatus: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );

    try {
      final response = await _authService.checkIdentifier(email);
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedLoginName != email) {
        return;
      }

      final exists = identifierExistsFromResponse(response);
      if (exists == null) {
        throw AuthException(
          AppStrings.current(AppKeys.authLoginNameCheckFailed),
        );
      }

      _emitState(
        state.copyWith(
          loginName: email,
          checkedLoginName: email,
          isCheckingLoginName: false,
          loginNameExists: exists,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearLoginLookupError: true,
          clearLoginLookupErrorStatus: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedLoginName != email) {
        return;
      }

      if (isAuthUserNotFoundStatus(error.status)) {
        _emitState(
          state.copyWith(
            loginName: email,
            checkedLoginName: email,
            isCheckingLoginName: false,
            loginNameExists: false,
            loginLookupError: error.message,
            loginLookupErrorStatus: error.status,
            clearAuthError: true,
          ),
        );
        return;
      }

      _emitState(
        state.copyWith(
          loginName: email,
          checkedLoginName: email,
          isCheckingLoginName: false,
          loginLookupError: error.message,
          loginLookupErrorStatus: error.status,
          clearAuthError: true,
        ),
      );
    } catch (_) {
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedLoginName != email) {
        return;
      }

      _emitState(
        state.copyWith(
          loginName: email,
          checkedLoginName: email,
          isCheckingLoginName: false,
          loginLookupError: AppStrings.current(
            AppKeys.authLoginNameCheckFailed,
          ),
          clearAuthError: true,
        ),
      );
    }
  }

  Future<void> submitLoginName(String loginName) async {
    if (state.isSendingOtp) {
      return;
    }

    final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
    if (isSignupEntry) {
      await lookupSignupEmail(loginName);
      if (isClosed ||
          state.screen != AuthScreen.signup ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.checkedLoginName != loginName ||
          state.loginNameExists != false ||
          state.isCheckingLoginName) {
        return;
      }
      _pendingSignupEmail = loginName;
      _pendingSignupForm = null;
      _emitState(
        state.copyWith(
          screen: AuthScreen.registrationProfile,
          loginName: loginName,
          isCheckingLoginName: false,
          isSendingOtp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      return;
    }

    _emitState(
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

      _emitState(
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
        _emitState(
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
        _emitState(
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

      _emitState(
        state.copyWith(
          screen: AuthScreen.otp,
          loginName: loginName,
          otpFlow: OtpFlow.login,
          isCheckingLoginName: false,
          isSendingOtp: true,
          clearAuthError: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendLoginOtp(loginName);
    } on AuthException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        _emitState(
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
    _emitState(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: true,
        isLoadingTrustedDevices: true,
        trustedDevices: const <AuthTrustedDevice>[],
        clearSelectedTrustedDevice: true,
        clearTrustedDeviceError: true,
        clearAuthError: true,
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
        _emitState(
          state.copyWith(
            screen: AuthScreen.otp,
            trustedDevices: devices,
            isLoadingTrustedDevices: false,
            otpFlow: OtpFlow.login,
            clearSelectedTrustedDevice: true,
            clearTrustedDeviceError: true,
            clearAuthError: true,
            clearOtpError: true,
          ),
        );
        await _sendLoginOtp(loginName);
        return;
      }

      _emitState(
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

    _emitState(
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

      _emitState(
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
      _emitState(
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
      _emitState(
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
}
