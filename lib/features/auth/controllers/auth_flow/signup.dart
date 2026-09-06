part of '../auth_cubit.dart';

extension AuthFlowSignup on AuthFlowCubit {
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
      _emitState(
        state.copyWith(
          authError: AppStrings.current(AppKeys.childNameRequired),
        ),
      );
      return;
    }

    if (trimmedEmail != null && !isValidEmailInput(trimmedEmail)) {
      _emitState(
        state.copyWith(authError: AppStrings.current(AppKeys.invalidEmail)),
      );
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
      _emitState(
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

    _emitState(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      await _completeSignup(
        phone: phone,
        form: normalizedForm,
        isSigningUp: false,
      );
    } on AuthException catch (error) {
      _emitState(state.copyWith(isSigningUp: false, authError: error.message));
    } catch (_) {
      _emitState(
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
    _emitState(
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
}
