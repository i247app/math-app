part of '../auth_cubit.dart';

extension AuthFlowSignup on AuthFlowCubit {
  Future<void> submitSignup(SignupFormData form) async {
    final identifier = _pendingSignupIdentifier;
    final trimmedName = form.name.trim();
    if (state.screen != AuthScreen.registrationProfile ||
        state.isSigningUp ||
        identifier == null ||
        _signupIdentifierReadyForCreation != identifier) {
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

    final kind = detectLoginNameKind(identifier);
    if (kind == null ||
        (kind == LoginNameKind.email && !isValidEmailInput(identifier))) {
      _emitState(
        state.copyWith(
          authError: AppStrings.current(
            kind == LoginNameKind.email
                ? AppKeys.invalidEmail
                : AppKeys.signupFailed,
          ),
        ),
      );
      return;
    }

    final normalizedForm = SignupFormData(
      name: trimmedName,
      email: kind == LoginNameKind.email ? identifier : null,
      role: form.role,
      gender: form.gender,
    );
    _pendingSignupIdentifier = identifier;
    _pendingSignupForm = normalizedForm;

    _emitState(
      state.copyWith(
        loginName: identifier,
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
        identifier: identifier,
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
    required String identifier,
    required SignupFormData form,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    final attemptId = _signupAttemptId;
    final user = detectLoginNameKind(identifier) == LoginNameKind.phone
        ? await _authService.signupWithPhone(
            phone: identifier,
            name: form.name,
            role: form.role.apiValue,
          )
        : await _authService.signupWithEmail(
            email: identifier,
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
    final signupIdentifier = _pendingSignupIdentifier;
    _emitState(
      state.copyWith(
        screen: AuthScreen.registrationProfile,
        loginName: signupIdentifier,
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
    _pendingSignupIdentifier = null;
    _pendingSignupForm = null;
    _signupIdentifierReadyForCreation = null;
    _signupOtpRequired = true;
  }
}
