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
    _emitState(
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
    final exposesOtpPreview = flow == OtpFlow.signup || state.showDevOtpPreview;
    _emitState(
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

    _emitState(
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
        final signupPhone = _pendingSignupPhone;
        final signupForm = _pendingSignupForm;
        if (signupPhone == null || signupForm == null) {
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
      _emitState(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: error.message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    } catch (_) {
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
