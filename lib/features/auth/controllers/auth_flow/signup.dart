part of '../auth_cubit.dart';

extension AuthFlowSignup on AuthFlowCubit {
  Future<void> submitSignup(SignupFormData form) async {
    final email = _pendingSignupEmail;
    final trimmedName = form.name.trim();
    if (state.screen != AuthScreen.registrationProfile ||
        state.isSigningUp ||
        email == null ||
        _signupEmailReadyForCreation != email) {
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
    final attemptId = _signupAttemptId;
    try {
      await _completeSignup(
        email: email,
        form: normalizedForm,
        isSigningUp: false,
      );
    } on AuthException catch (error) {
      if (!isClosed && attemptId == _signupAttemptId) {
        _showSignupCreationError(error.message);
      }
    } catch (_) {
      if (!isClosed && attemptId == _signupAttemptId) {
        _showSignupCreationError(AppStrings.current(AppKeys.signupFailed));
      }
    }
  }

  Future<void> _completeSignup({
    required String email,
    required SignupFormData form,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    final attemptId = _signupAttemptId;
    final user = await _authService.signupWithEmail(
      email: email,
      name: form.name,
      role: form.role.apiValue,
    );
    if (isClosed || attemptId != _signupAttemptId) {
      return;
    }
    _clearPendingSignup();
    _emitAuthenticationSucceeded(
      user,
      isVerifyingOtp: isVerifyingOtp,
      isSigningUp: isSigningUp,
      isNewlyRegistered: true,
    );
  }

  void _showSignupCreationError(String message) {
    final signupEmail = _pendingSignupEmail;
    _emitState(
      state.copyWith(
        screen: AuthScreen.registrationProfile,
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
    _signupAttemptId++;
    _pendingSignupEmail = null;
    _pendingSignupForm = null;
    _signupEmailReadyForCreation = null;
    _signupOtpRequired = true;
  }
}
