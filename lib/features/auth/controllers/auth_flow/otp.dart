part of '../auth_cubit.dart';

extension AuthFlowOtp on AuthFlowCubit {
  void selectTrustedDevice(int deviceId) {
    if (state.screen != AuthScreen.deviceVerification ||
        state.isLoadingTrustedDevices ||
        state.isSendingOtp ||
        !state.trustedDevices.any((device) => device.deviceId == deviceId)) {
      return;
    }

    _emitState(
      state.copyWith(
        selectedTrustedDeviceId: deviceId,
        clearTrustedDeviceError: true,
      ),
    );
  }

  Future<void> sendOtpToTrustedDevice() async {
    final loginName = state.loginName;
    final user = state.identifierLookupUser;
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
    if (state.screen != AuthScreen.otp ||
        state.isSendingOtp ||
        state.isVerifyingOtp ||
        loginName == null ||
        loginName.trim().isEmpty) {
      return;
    }

    if (state.otpFlow == OtpFlow.signup) {
      await _sendSignupOtp(loginName);
      return;
    }

    await _sendLoginOtp(loginName);
  }

  Future<void> _sendSignupOtp(String identifier) async {
    final attemptId = _signupAttemptId;
    _signupIdentifierReadyForCreation = null;
    _emitState(
      state.copyWith(
        isSendingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final otp = await _authService.sendOtp(
        loginName: identifier,
        kind: AuthOtpKind.signup,
      );
      if (isClosed ||
          attemptId != _signupAttemptId ||
          _pendingSignupIdentifier != identifier ||
          state.loginName != identifier ||
          state.otpFlow != OtpFlow.signup) {
        return;
      }

      _emitOtpSent(loginName: identifier, otp: otp, flow: OtpFlow.signup);
    } on AuthException catch (error) {
      if (isClosed ||
          attemptId != _signupAttemptId ||
          _pendingSignupIdentifier != identifier ||
          state.loginName != identifier ||
          state.otpFlow != OtpFlow.signup) {
        return;
      }
      _emitAuthError(error.message, isSendingOtp: false, isSigningUp: false);
    } catch (_) {
      if (isClosed ||
          attemptId != _signupAttemptId ||
          _pendingSignupIdentifier != identifier ||
          state.loginName != identifier ||
          state.otpFlow != OtpFlow.signup) {
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
        (resolvedTargetDeviceId == null
            ? null
            : state.identifierLookupUser?.id);
    _emitState(
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
      if (state.loginName != loginName ||
          state.checkedIdentifier != loginName) {
        return;
      }

      _emitOtpSent(loginName: loginName, otp: otp, flow: OtpFlow.login);
    } on AuthException catch (error) {
      if (state.loginName != loginName ||
          state.checkedIdentifier != loginName) {
        return;
      }

      _emitLoginOtpSendError(error.message);
    } catch (_) {
      if (state.loginName != loginName ||
          state.checkedIdentifier != loginName) {
        return;
      }

      _emitLoginOtpSendError(AppStrings.current(AppKeys.loginOtpFailed));
    }
  }

  void _emitLoginOtpSendError(String message) {
    if (state.screen == AuthScreen.deviceVerification) {
      _emitState(
        state.copyWith(
          isSendingOtp: false,
          trustedDeviceError: message,
          clearAuthError: true,
        ),
      );
      return;
    }

    _emitState(
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
    // Clear stale expiry without discarding a response containing only seconds.
    final stateWithoutExpiry = state.copyWith(clearOtpExpiry: true);
    _emitState(
      stateWithoutExpiry.copyWith(
        screen: AuthScreen.otp,
        loginName: loginName,
        otpExpiresAt: otp.expiresAt,
        otpExpiresIn: otp.expiresIn,
        otpPreviewId: state.otpPreviewId + 1,
        otpFlow: flow,
        isSendingOtp: false,
        isSigningUp: false,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );
  }

  Future<void> verifyOtp(String otpCode) async {
    final loginName = state.loginName;
    if (state.screen != AuthScreen.otp ||
        state.isSendingOtp ||
        state.isVerifyingOtp ||
        loginName == null) {
      return;
    }
    final otpFlow = state.otpFlow;
    final attemptId = _signupAttemptId;

    _emitState(
      state.copyWith(
        isVerifyingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final result = await _authService.verifyOtp(
        loginName: loginName,
        otpCode: otpCode,
        kind: otpFlow == OtpFlow.signup
            ? AuthOtpKind.signup
            : AuthOtpKind.login,
      );

      if (isClosed ||
          state.screen != AuthScreen.otp ||
          state.loginName != loginName ||
          (otpFlow == OtpFlow.signup && attemptId != _signupAttemptId)) {
        return;
      }

      if (!result.isValid) {
        _emitState(
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
        final signupIdentifier = _pendingSignupIdentifier;
        if (signupIdentifier == null || signupIdentifier != loginName) {
          _emitState(
            state.copyWith(
              isVerifyingOtp: false,
              otpError: AppStrings.current(AppKeys.signupFailed),
              otpErrorId: state.otpErrorId + 1,
              clearAuthError: true,
            ),
          );
          return;
        }

        _signupIdentifierReadyForCreation = signupIdentifier;
        _emitState(
          state.copyWith(
            screen: AuthScreen.registrationProfile,
            isVerifyingOtp: false,
            clearAuthError: true,
            clearOtpExpiry: true,
            clearOtpError: true,
          ),
        );
        return;
      }

      if (result.user == null) {
        _emitState(
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
      if (isClosed ||
          state.screen != AuthScreen.otp ||
          state.loginName != loginName ||
          (otpFlow == OtpFlow.signup && attemptId != _signupAttemptId)) {
        return;
      }
      _emitState(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: error.message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    } catch (_) {
      if (isClosed ||
          state.screen != AuthScreen.otp ||
          state.loginName != loginName ||
          (otpFlow == OtpFlow.signup && attemptId != _signupAttemptId)) {
        return;
      }
      _emitState(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: AppStrings.current(AppKeys.verifyOtpFailed),
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    }
  }
}
