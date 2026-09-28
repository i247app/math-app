part of '../auth_cubit.dart';

extension AuthFlowEntry on AuthFlowCubit {
  Future<bool?> lookupSignupIdentifier(String identifier) async {
    if (state.screen != AuthScreen.signup ||
        state.authEntryMode != AuthEntryMode.signup ||
        state.isCheckingIdentifier) {
      return null;
    }

    _emitState(
      state.copyWith(
        loginName: identifier,
        checkedIdentifier: identifier,
        isCheckingIdentifier: true,
        clearIdentifierExists: true,
        clearIdentifierLookupUser: true,
        clearIdentifierLookupError: true,
        clearIdentifierLookupErrorStatus: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );

    try {
      final response = await _authService.checkIdentifier(identifier);
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedIdentifier != identifier) {
        return null;
      }

      final availability = IdentifierAvailability.fromResponse(
        response,
        identifier,
      );
      if (availability == null) {
        throw AuthException(
          AppStrings.current(AppKeys.authLoginNameCheckFailed),
        );
      }

      final exists = availability.mstatus != 200;
      final otpEnabled = availability.otpEnabled == true;

      _emitState(
        state.copyWith(
          loginName: identifier,
          checkedIdentifier: identifier,
          isCheckingIdentifier: false,
          identifierExists: exists,
          identifierLookupErrorStatus: availability.mstatus == 200
              ? null
              : availability.mstatus,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearIdentifierLookupError: true,
          clearIdentifierLookupErrorStatus: availability.mstatus == 200,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      return exists ? null : otpEnabled;
    } on AuthException catch (error) {
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedIdentifier != identifier) {
        return null;
      }

      _emitState(
        state.copyWith(
          loginName: identifier,
          checkedIdentifier: identifier,
          isCheckingIdentifier: false,
          identifierLookupError: error.message,
          identifierLookupErrorStatus: error.status,
          clearAuthError: true,
        ),
      );
      return null;
    } catch (_) {
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.screen != AuthScreen.signup ||
          state.checkedIdentifier != identifier) {
        return null;
      }

      _emitState(
        state.copyWith(
          loginName: identifier,
          checkedIdentifier: identifier,
          isCheckingIdentifier: false,
          identifierLookupError: AppStrings.current(
            AppKeys.authLoginNameCheckFailed,
          ),
          clearAuthError: true,
        ),
      );
      return null;
    }
  }

  Future<void> submitAuthIdentifier(String loginName) async {
    if (state.isSendingOtp) {
      return;
    }

    final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
    if (isSignupEntry) {
      final otpEnabled = await lookupSignupIdentifier(loginName);
      if (isClosed ||
          state.screen != AuthScreen.signup ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.checkedIdentifier != loginName ||
          state.identifierExists != false ||
          otpEnabled == null ||
          state.isCheckingIdentifier) {
        return;
      }
      _clearPendingSignup();
      _pendingSignupIdentifier = loginName;
      _signupOtpRequired = otpEnabled;
      if (!otpEnabled &&
          detectLoginNameKind(loginName) == LoginNameKind.phone) {
        _emitState(
          state.copyWith(
            identifierLookupError: AppStrings.current(
              AppKeys.signupOtpUnavailable,
            ),
          ),
        );
        return;
      }
      if (!otpEnabled) {
        _signupIdentifierReadyForCreation = loginName;
        _emitState(
          state.copyWith(
            screen: AuthScreen.registrationProfile,
            loginName: loginName,
            isCheckingIdentifier: false,
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
          isCheckingIdentifier: false,
          isSendingOtp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendSignupOtp(loginName);
      return;
    }

    _emitState(
      state.copyWith(
        loginName: loginName,
        checkedIdentifier: loginName,
        isCheckingIdentifier: true,
        isSendingOtp: true,
        clearIdentifierExists: true,
        clearIdentifierLookupUser: true,
        clearIdentifierLookupError: true,
        clearIdentifierLookupErrorStatus: true,
        clearTrustedDeviceState: true,
        clearAuthError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginName(loginName);
      final user = result.user;
      if (isClosed || state.checkedIdentifier != loginName) {
        return;
      }

      _emitState(
        state.copyWith(
          isCheckingIdentifier: false,
          identifierExists: result.exists,
          identifierLookupUser: user,
          identifierLookupError: result.exists ? null : result.message,
          identifierLookupErrorStatus: result.exists ? null : result.status,
          clearIdentifierLookupError: result.exists,
          clearIdentifierLookupErrorStatus: result.exists,
        ),
      );

      if (!result.exists) {
        _emitState(
          state.copyWith(
            screen: AuthScreen.login,
            loginName: loginName,
            checkedIdentifier: loginName,
            identifierExists: false,
            identifierLookupError: result.message,
            identifierLookupErrorStatus: result.status,
            isCheckingIdentifier: false,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      if (user == null) {
        _emitState(
          state.copyWith(
            isCheckingIdentifier: false,
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
          isCheckingIdentifier: false,
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
            checkedIdentifier: loginName,
            identifierExists: false,
            identifierLookupError: error.message,
            identifierLookupErrorStatus: error.status,
            isCheckingIdentifier: false,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      _emitAuthError(
        error.message,
        isCheckingIdentifier: false,
        isSendingOtp: false,
      );
    } catch (_) {
      _emitAuthError(
        AppStrings.current(AppKeys.authLoginNameCheckFailed),
        isCheckingIdentifier: false,
        isSendingOtp: false,
      );
    }
  }

  Future<void> _openDeviceVerification(LoginUser user) async {
    _emitState(
      state.copyWith(
        isCheckingIdentifier: false,
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
          state.identifierLookupUser?.id != user.id ||
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
        isCheckingIdentifier: false,
        isSendingOtp: false,
      );
    } catch (_) {
      _emitAuthError(
        AppStrings.current(AppKeys.trustedDeviceLoadFailed),
        isCheckingIdentifier: false,
        isSendingOtp: false,
      );
    }
  }

  Future<void> reloadTrustedDevices() async {
    final user = state.identifierLookupUser;
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
          state.identifierLookupUser?.id != user.id) {
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
