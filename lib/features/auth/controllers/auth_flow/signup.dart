part of '../auth_cubit.dart';

extension AuthFlowSignup on AuthFlowCubit {
  Future<void> submitSignup(SignupFormData form) async {
    final email = _pendingSignupEmail ?? state.loginName;
    final trimmedName = form.name.trim();
    if (state.isSigningUp || email == null) {
      return;
    }

    if (trimmedName.isEmpty) {
      _emitState(
        state.copyWith(
          authError: AppStrings.current(AppKeys.childNameRequired),
        ),
      );
      return;
    }

    if (!isValidEmailInput(email)) {
      _emitState(
        state.copyWith(authError: AppStrings.current(AppKeys.invalidEmail)),
      );
      return;
    }

    final normalizedForm = SignupFormData(
      name: trimmedName,
      email: email,
      role: form.role,
      gender: form.gender,
    );
    _pendingSignupEmail = email;
    _pendingSignupForm = normalizedForm;

    _emitState(
      state.copyWith(
        loginName: email,
        isSigningUp: true,
        otpFlow: OtpFlow.signup,
        clearAuthError: true,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );
    await _sendSignupOtp(email);
  }

  Future<void> _completeSignup({
    required String email,
    required SignupFormData form,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    final user = await _authService.signupWithEmail(
      email: email,
      name: form.name,
      role: form.role.apiValue,
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
    final signupEmail = _pendingSignupEmail;
    _emitState(
      state.copyWith(
        screen: AuthScreen.signup,
        loginName: signupEmail,
        isVerifyingOtp: false,
        isSigningUp: false,
        authError: message,
        clearOtpExpiry: true,
        clearOtpError: true,
      ),
    );
  }

  void _clearPendingSignup() {
    _pendingSignupEmail = null;
    _pendingSignupForm = null;
  }
}
