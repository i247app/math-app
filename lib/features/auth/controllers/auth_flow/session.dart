part of '../auth_cubit.dart';

extension AuthFlowSession on AuthFlowCubit {
  Future<void> resumeRememberedLogin({
    required String loginName,
    required LoginUser fallbackUser,
  }) async {
    _emitState(
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
      _emitState(
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
        _emitState(
          state.copyWith(
            screen: AuthScreen.login,
            isCheckingLoginName: false,
            authError: error.message,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        _emitState(
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
      _emitState(state.copyWith(clearAuthenticationResult: true));
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
    _emitState(
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
      _emitState(
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

    _emitState(
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
