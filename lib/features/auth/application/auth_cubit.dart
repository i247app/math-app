import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/notifications/notification_ping_service.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/errors/auth_status.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/session/application/app_session_state.dart';
import 'package:numi/features/session/models/profile_session_resolution.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

import 'package:numi/features/auth/application/auth_state.dart';

class AuthFlowCubit extends Cubit<AuthFlowState> {
  AuthFlowCubit({
    AuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    ProfileSessionResolver? profileResolver,
    PasscodeService passcodeService = const SecurePasscodeService(),
    NotificationPingService? notificationPingService,
    AuthFlowState? initialState,
    required void Function(AuthenticatedSession session) onAuthenticated,
    required VoidCallback onSessionCleared,
    required VoidCallback onSessionRestoreStarted,
  }) : _authService = authService ?? AuthApi(),
       _profileResolver =
           profileResolver ??
           ProfileSessionResolver(
             profileService: profileService ?? ProfileApi(),
             activeProfileSession: activeProfileSession,
           ),
       _passcodeService = passcodeService,
       _notificationPingService =
           notificationPingService ??
           _defaultNotificationPingService(authService ?? AuthApi()),
       _onAuthenticated = onAuthenticated,
       _onSessionCleared = onSessionCleared,
       _onSessionRestoreStarted = onSessionRestoreStarted,
       super(initialState ?? const AuthFlowState());

  final AuthService _authService;
  final ProfileSessionResolver _profileResolver;
  final PasscodeService _passcodeService;
  final NotificationPingService _notificationPingService;
  final void Function(AuthenticatedSession session) _onAuthenticated;
  final VoidCallback _onSessionCleared;
  final VoidCallback _onSessionRestoreStarted;

  void openWelcome() => emit(state.copyWith(screen: AppScreen.welcome));

  void openWelcomeDetails() =>
      emit(state.copyWith(screen: AppScreen.welcomeDetails));

  /// Handles a platform Back gesture for the auth flow, whose screens are
  /// state-driven rather than separate Navigator routes.
  ///
  /// Returns false at root screens so Android can perform its normal task
  /// backgrounding behavior.
  bool handleSystemBack() {
    if (state.isRestoringSession) {
      return false;
    }

    switch (state.screen) {
      case AppScreen.welcomeDetails:
        openWelcome();
        return true;
      case AppScreen.login:
        backFromLogin();
        return true;
      case AppScreen.otp:
        openLogin();
        return true;
      case AppScreen.signup:
        cancelSignupToLogin();
        return true;
      case AppScreen.welcome:
      case AppScreen.passcode:
      case AppScreen.home:
        return false;
    }
  }

  AppScreen _loginBackScreenForCurrentFlow() {
    return switch (state.screen) {
      AppScreen.login ||
      AppScreen.otp ||
      AppScreen.signup ||
      AppScreen.passcode => state.loginBackScreen,
      final screen => screen,
    };
  }

  AuthEntryMode _loginEntryModeForCurrentFlow(AuthEntryMode nextMode) {
    return switch (state.screen) {
      AppScreen.login ||
      AppScreen.otp ||
      AppScreen.signup ||
      AppScreen.passcode => state.loginEntryMode,
      AppScreen.welcome ||
      AppScreen.welcomeDetails ||
      AppScreen.home => nextMode,
    };
  }

  bool get backFromLoginSwitchesEntryMode =>
      state.screen == AppScreen.login &&
      state.authEntryMode != state.loginEntryMode;

  void backFromLogin() {
    if (state.screen != AppScreen.login) {
      return;
    }

    if (backFromLoginSwitchesEntryMode) {
      switchAuthEntryMode(state.loginEntryMode);
      return;
    }

    final target = switch (state.loginBackScreen) {
      AppScreen.login ||
      AppScreen.otp ||
      AppScreen.signup ||
      AppScreen.passcode => AppScreen.welcomeDetails,
      final screen => screen,
    };
    emit(
      state.copyWith(
        screen: target,
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearLoginName: true,
        clearLoginLookup: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );
  }

  void openLogin({AuthEntryMode? mode}) {
    final nextMode = mode ?? state.authEntryMode;
    emit(
      state.copyWith(
        screen: AppScreen.login,
        loginBackScreen: _loginBackScreenForCurrentFlow(),
        loginEntryMode: _loginEntryModeForCurrentFlow(nextMode),
        authEntryMode: nextMode,
        clearOtpError: true,
      ),
    );
    unawaited(checkPinLoginAvailability());
  }

  void openLoginFromWelcome() {
    unawaited(_openLoginFromWelcome());
  }

  void openSignupEntry() {
    emit(
      state.copyWith(
        screen: AppScreen.login,
        loginBackScreen: _loginBackScreenForCurrentFlow(),
        loginEntryMode: AuthEntryMode.signup,
        authEntryMode: AuthEntryMode.signup,
        clearAuthError: true,
        clearOtpError: true,
        clearLoginName: true,
        clearLoginLookup: true,
        clearPinLogin: true,
      ),
    );
  }

  void switchAuthEntryMode(AuthEntryMode mode) {
    if (state.authEntryMode == mode) {
      return;
    }

    emit(
      state.copyWith(
        authEntryMode: mode,
        clearAuthError: true,
        clearOtpError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearLoginName: true,
        clearLoginLookup: true,
        clearPinLogin: mode == AuthEntryMode.signup,
      ),
    );

    if (mode == AuthEntryMode.login) {
      unawaited(checkPinLoginAvailability());
    }
  }

  Future<void> _openLoginFromWelcome() async {
    if (state.isCheckingPinLogin) {
      return;
    }

    emit(
      state.copyWith(
        authEntryMode: AuthEntryMode.login,
        loginBackScreen: _loginBackScreenForCurrentFlow(),
        loginEntryMode: AuthEntryMode.login,
        isCheckingPinLogin: true,
        clearAuthError: true,
        clearOtpError: true,
        clearLoginName: true,
        clearLoginLookup: true,
        clearPinLogin: true,
      ),
    );

    try {
      final rememberedAccount = await _passcodeService.lastPasscodeAccount();
      if (isClosed) {
        return;
      }

      if (rememberedAccount != null) {
        final loginName = rememberedAccount.loginName;
        final isEmail = loginName.contains('@');
        final pinUser = LoginUser(
          id: rememberedAccount.userId,
          email: isEmail ? loginName : null,
          phone: isEmail ? null : loginName,
        );
        emit(
          state.copyWith(
            screen: AppScreen.passcode,
            isCheckingPinLogin: false,
            pendingLoginUser: pinUser,
            pendingProfiles: const <StudentProfile>[],
            clearPendingActiveProfile: true,
            clearPendingProfileLoadError: true,
            passcodeFlow: PasscodeFlow.unlock,
            passcodeCanSkip: false,
            passcodeLoginRequiresOtp: true,
            canLoginWithPin: true,
            pinLoginUser: pinUser,
            clearPasscodeError: true,
          ),
        );
        return;
      }
    } catch (_) {
      if (isClosed) {
        return;
      }
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          isCheckingPinLogin: false,
          authEntryMode: AuthEntryMode.login,
          clearPinLogin: true,
          clearPasscodeError: true,
        ),
      );
    }
  }

  void cancelSignupToLogin() {
    final loginName = state.loginName?.trim();
    if (loginName != null && loginName.isNotEmpty) {
      unawaited(_authService.clearPendingLogin(loginName));
    }

    emit(
      state.copyWith(
        screen: AppScreen.login,
        clearLoginName: true,
        isVerifyingOtp: false,
        isSigningUp: false,
        otpFlow: OtpFlow.login,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
        clearLoginLookup: true,
        clearPendingSession: true,
      ),
    );
    unawaited(checkPinLoginAvailability());
  }

  Future<void> logout() async {
    _onSessionCleared();
    await _authService.logout();
    if (!isClosed) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          loginBackScreen: AppScreen.welcome,
          loginEntryMode: AuthEntryMode.login,
          authEntryMode: AuthEntryMode.login,
          clearLoginName: true,
          clearLoginLookup: true,
          clearAuthError: true,
          clearPendingSession: true,
          clearPasscodeError: true,
          clearPinLogin: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      unawaited(checkPinLoginAvailability());
    }
  }

  Future<void> checkPinLoginAvailability() async {
    if (state.isCheckingPinLogin) {
      return;
    }

    emit(
      state.copyWith(
        isCheckingPinLogin: true,
        clearPinLogin: true,
        clearPasscodeError: true,
      ),
    );

    try {
      final rememberedAccount = await _passcodeService.lastPasscodeAccount();
      final canUsePin = rememberedAccount != null;
      if (isClosed) {
        return;
      }
      if (state.screen != AppScreen.login) {
        emit(state.copyWith(isCheckingPinLogin: false));
        return;
      }

      emit(
        state.copyWith(
          isCheckingPinLogin: false,
          canLoginWithPin: canUsePin,
          pinLoginUser: canUsePin
              ? LoginUser(
                  id: rememberedAccount.userId,
                  email: rememberedAccount.loginName.contains('@')
                      ? rememberedAccount.loginName
                      : null,
                  phone: rememberedAccount.loginName.contains('@')
                      ? null
                      : rememberedAccount.loginName,
                )
              : null,
          clearPinLoginUser: !canUsePin,
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isCheckingPinLogin: false,
          clearPinLogin: state.screen == AppScreen.login,
        ),
      );
    }
  }

  void openPinLogin() {
    final user = state.pinLoginUser;
    if (!state.canLoginWithPin || user == null || user.id <= 0) {
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.passcode,
        pendingLoginUser: user,
        pendingProfiles: const <StudentProfile>[],
        clearPendingActiveProfile: true,
        clearPendingProfileLoadError: true,
        passcodeFlow: PasscodeFlow.unlock,
        passcodeCanSkip: false,
        passcodeLoginRequiresOtp: true,
        clearAuthError: true,
        clearPasscodeError: true,
      ),
    );
  }

  Future<void> restoreSession() async {
    if (state.isRestoringSession) {
      return;
    }

    _onSessionRestoreStarted();
    emit(state.copyWith(isRestoringSession: true, clearAuthError: true));

    try {
      final user = await _authService.restoreSession();
      if (isClosed) {
        return;
      }

      if (user == null) {
        _onSessionCleared();
        emit(
          state.copyWith(
            isRestoringSession: false,
            clearAuthError: true,
            clearPendingSession: true,
            clearPasscodeError: true,
          ),
        );
        return;
      }

      final profileResolution = await _profileResolver.resolveForUserId(
        user.id,
      );
      await _emitAuthenticatedHome(user, profileResolution);
    } catch (_) {
      if (!isClosed) {
        _onSessionCleared();
        emit(state.copyWith(isRestoringSession: false));
      }
    }
  }

  void selectPhoneRegion(PhoneRegion region) {
    emit(state.copyWith(phoneRegion: region));
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

    emit(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: false,
        clearAuthError: true,
        clearLoginLookup: true,
      ),
    );
  }

  Future<void> lookupSignupPhone(String phone) async {
    if (state.authEntryMode != AuthEntryMode.signup ||
        (state.isCheckingLoginName && state.checkedLoginName == phone)) {
      return;
    }

    emit(
      state.copyWith(
        loginName: phone,
        checkedLoginName: phone,
        isCheckingLoginName: true,
        clearLoginNameExists: true,
        clearLoginLookupUser: true,
        clearLoginLookupError: true,
        clearLoginLookupErrorStatus: true,
        clearAuthError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginName(phone);
      if (isClosed ||
          state.authEntryMode != AuthEntryMode.signup ||
          state.checkedLoginName != phone) {
        return;
      }

      emit(
        state.copyWith(
          loginName: phone,
          checkedLoginName: phone,
          isCheckingLoginName: false,
          loginNameExists: result.exists,
          loginLookupUser: result.user,
          loginLookupError: result.exists ? null : result.message,
          loginLookupErrorStatus: result.exists ? null : result.status,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearLoginLookupError: result.exists,
          clearLoginLookupErrorStatus: result.exists,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (isClosed || state.checkedLoginName != phone) {
        return;
      }

      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            loginName: phone,
            checkedLoginName: phone,
            isCheckingLoginName: false,
            loginNameExists: false,
            loginLookupError: error.message,
            loginLookupErrorStatus: error.status,
            clearAuthError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isCheckingLoginName: false,
          authError: error.message,
          clearLoginLookup: true,
        ),
      );
    } catch (_) {
      if (isClosed || state.checkedLoginName != phone) {
        return;
      }

      emit(
        state.copyWith(
          isCheckingLoginName: false,
          authError: AppStrings.current(AppKeys.authLoginNameCheckFailed),
          clearLoginLookup: true,
        ),
      );
    }
  }

  Future<void> submitLoginName(String loginName) async {
    if (state.isSendingOtp) {
      return;
    }

    final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
    if (isSignupEntry && loginName.contains('@')) {
      emit(state.copyWith(authError: AppStrings.current(AppKeys.invalidPhone)));
      return;
    }

    if (isSignupEntry) {
      if (state.loginNameExists == true &&
          state.checkedLoginName == loginName) {
        emit(
          state.copyWith(
            authError: AppStrings.current(AppKeys.signupPhoneAlreadyRegistered),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          loginName: loginName,
          isCheckingLoginName: false,
          isSendingOtp: true,
          clearAuthError: true,
        ),
      );

      try {
        final otp = await _authService.sendOtp(
          loginName: loginName,
          kind: AuthOtpKind.signup,
        );
        _emitOtpSent(loginName: loginName, otp: otp, flow: OtpFlow.signup);
      } on AuthException catch (error) {
        _emitAuthError(error.message, isSendingOtp: false);
      } catch (_) {
        _emitAuthError(
          AppStrings.current(AppKeys.signupOtpFailed),
          isSendingOtp: false,
        );
      }
      return;
    }

    emit(
      state.copyWith(
        loginName: loginName,
        checkedLoginName: loginName,
        isCheckingLoginName: true,
        isSendingOtp: true,
        clearLoginNameExists: true,
        clearLoginLookupUser: true,
        clearLoginLookupError: true,
        clearLoginLookupErrorStatus: true,
        clearAuthError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginName(loginName);
      final user = result.user;
      if (isClosed || state.checkedLoginName != loginName) {
        return;
      }

      emit(
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
        emit(
          state.copyWith(
            screen: AppScreen.login,
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
        emit(
          state.copyWith(
            isCheckingLoginName: false,
            isSendingOtp: false,
            authError: AppStrings.current(AppKeys.missingOtpUser),
          ),
        );
        return;
      }

      if (_canSkipLoginOtp(result)) {
        final profileResolution = await _profileResolver.resolveForUserId(
          user.id,
        );
        await _emitHomeOrPasscodeSetup(
          user: user,
          profileResolution: profileResolution,
          isSendingOtp: false,
        );
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.otp,
          loginName: loginName,
          otpFlow: OtpFlow.login,
          isCheckingLoginName: false,
          isSendingOtp: true,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendLoginOtp(loginName);
    } on AuthException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            screen: AppScreen.login,
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

  Future<void> resendLoginOtp() async {
    final loginName = state.loginName;
    if (state.isSendingOtp || loginName == null || loginName.trim().isEmpty) {
      return;
    }

    await _sendLoginOtp(loginName);
  }

  Future<void> _sendLoginOtp(String loginName) async {
    emit(
      state.copyWith(
        isSendingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final otp = await _authService.sendOtp(
        loginName: loginName,
        kind: AuthOtpKind.login,
      );
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      _emitOtpSent(loginName: loginName, otp: otp, flow: OtpFlow.login);
    } on AuthException catch (error) {
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      emit(
        state.copyWith(
          isSendingOtp: false,
          otpError: error.message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    } catch (_) {
      if (state.loginName != loginName || state.checkedLoginName != loginName) {
        return;
      }

      emit(
        state.copyWith(
          isSendingOtp: false,
          otpError: AppStrings.current(AppKeys.loginOtpFailed),
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    }
  }

  void _emitOtpSent({
    required String loginName,
    required SendOtpResult otp,
    required OtpFlow flow,
  }) {
    emit(
      state.copyWith(
        screen: AppScreen.otp,
        loginName: loginName,
        otpExpiresAt: otp.expiresAt,
        otpExpiresIn: otp.expiresIn,
        devOtpCode: otp.otpCode,
        devOtpPurpose: otp.purpose,
        otpPreviewId: state.otpPreviewId + 1,
        otpFlow: flow,
        isSendingOtp: false,
        clearAuthError: true,
        clearDevOtp: otp.otpCode == null,
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

    emit(
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
        emit(
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
        emit(
          state.copyWith(
            screen: AppScreen.signup,
            isVerifyingOtp: false,
            clearAuthError: true,
            clearOtpError: true,
          ),
        );
        return;
      }

      if (result.user == null) {
        emit(
          state.copyWith(
            isVerifyingOtp: false,
            otpError: AppStrings.current(AppKeys.missingOtpUser),
            otpErrorId: state.otpErrorId + 1,
            clearAuthError: true,
          ),
        );
        return;
      }

      final profileResolution = await _profileResolver.resolveForUserId(
        result.user!.id,
      );
      await _emitHomeOrPasscodeSetup(
        user: result.user!,
        profileResolution: profileResolution,
        isVerifyingOtp: false,
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: error.message,
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          otpError: AppStrings.current(AppKeys.verifyOtpFailed),
          otpErrorId: state.otpErrorId + 1,
          clearAuthError: true,
        ),
      );
    }
  }

  static bool _canSkipLoginOtp(AuthLoginLookupResult result) {
    return result.isTrusted == true && !result.requiredOtp;
  }

  Future<void> submitSignup(SignupFormData form) async {
    final phone = state.loginName;
    final trimmedName = form.name.trim();
    final trimmedEmail = form.email?.trim();
    final role = form.role.apiValue;
    if (state.isSigningUp || phone == null) {
      return;
    }

    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.childNameRequired),
        ),
      );
      return;
    }
    emit(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      final user = await _authService.signupWithPhone(
        phone: phone,
        name: trimmedName,
        role: role,
        email: trimmedEmail?.isEmpty == true ? null : trimmedEmail,
      );
      final profileResolution = await _profileResolver.resolveForUserId(
        user.id,
      );
      await _emitHomeOrPasscodeSetup(
        user: user,
        profileResolution: profileResolution,
        isSigningUp: false,
      );
    } on AuthException catch (error) {
      emit(state.copyWith(isSigningUp: false, authError: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSigningUp: false,
          authError: AppStrings.current(AppKeys.signupFailed),
        ),
      );
    }
  }

  Future<void> submitPasscode(String passcode) async {
    final user = state.pendingLoginUser;
    if (state.isPasscodeBusy || user == null) {
      return;
    }

    emit(state.copyWith(isPasscodeBusy: true, clearPasscodeError: true));

    try {
      switch (state.passcodeFlow) {
        case PasscodeFlow.setup:
          await _passcodeService.setPasscode(
            userId: user.id,
            passcode: passcode,
          );
          await _completePendingHome(isPasscodeBusy: false);
        case PasscodeFlow.unlock:
          if (!await _passcodeService.hasPasscode(user.id)) {
            emit(
              state.copyWith(
                screen: AppScreen.login,
                isPasscodeBusy: false,
                clearPendingSession: true,
                clearPasscodeError: true,
                clearPinLogin: true,
                passcodeLoginRequiresOtp: false,
              ),
            );
            unawaited(checkPinLoginAvailability());
            return;
          }

          final isValid = await _passcodeService.verifyPasscode(
            userId: user.id,
            passcode: passcode,
          );
          if (!isValid) {
            emit(
              state.copyWith(
                isPasscodeBusy: false,
                passcodeError: AppStrings.current(AppKeys.passcodeIncorrect),
                passcodeErrorId: state.passcodeErrorId + 1,
              ),
            );
            return;
          }

          if (state.passcodeLoginRequiresOtp) {
            await _sendPinLoginOtp(user);
            return;
          }
          await _completePendingHome(isPasscodeBusy: false);
      }
    } catch (_) {
      emit(
        state.copyWith(
          isPasscodeBusy: false,
          passcodeError: AppStrings.current(AppKeys.passcodeSaveFailed),
          passcodeErrorId: state.passcodeErrorId + 1,
        ),
      );
    }
  }

  void skipPasscodeSetup() {
    if (state.passcodeFlow != PasscodeFlow.setup || !state.passcodeCanSkip) {
      return;
    }
    unawaited(_completePendingHome());
  }

  Future<void> cancelPasscodeUnlock() async {
    if (state.passcodeFlow == PasscodeFlow.setup && state.passcodeCanSkip) {
      skipPasscodeSetup();
      return;
    }

    if (state.passcodeLoginRequiresOtp) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          isPasscodeBusy: false,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      unawaited(checkPinLoginAvailability());
      return;
    }

    await logout();
  }

  Future<void> _sendPinLoginOtp(LoginUser pinUser) async {
    final rememberedAccount = await _passcodeService.lastPasscodeAccount();
    final loginName = rememberedAccount?.userId == pinUser.id
        ? rememberedAccount?.loginName.trim()
        : null;
    if (loginName == null || loginName.isEmpty) {
      _returnToLoginAfterPinAttempt(clearPinLogin: true);
      return;
    }

    try {
      final result = await _authService.lookupLoginName(loginName);
      final user = result.user ?? pinUser;
      if (_canSkipLoginOtp(result)) {
        final profileResolution = await _profileResolver.resolveForUserId(
          user.id,
        );
        if (!await _completeAuthenticatedSession(user, profileResolution)) {
          return;
        }
        emit(
          state.copyWith(
            screen: AppScreen.home,
            isPasscodeBusy: false,
            clearAuthError: true,
            clearOtpError: true,
            clearPendingSession: true,
            clearPasscodeError: true,
            passcodeLoginRequiresOtp: false,
          ),
        );
        return;
      }

      _returnToLoginAfterPinAttempt(
        loginName: loginName,
        error: AppStrings.current(AppKeys.pinLoginFailed),
        clearOtpPreview: true,
      );
    } on AuthException catch (error) {
      _returnToLoginAfterPinAttempt(error: error.message);
    } catch (_) {
      _returnToLoginAfterPinAttempt(
        error: AppStrings.current(AppKeys.loginOtpFailed),
      );
    }
  }

  Future<void> _emitHomeOrPasscodeSetup({
    required LoginUser user,
    required ProfileSessionResolution profileResolution,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    await _rememberAuthenticatedAccount(user);
    final hasPasscode = await _passcodeService.hasPasscode(user.id);
    if (hasPasscode) {
      if (!await _completeAuthenticatedSession(
        user,
        profileResolution,
        rememberAccount: false,
      )) {
        return;
      }
      emit(
        state.copyWith(
          screen: AppScreen.home,
          isSendingOtp: isSendingOtp,
          isVerifyingOtp: isVerifyingOtp,
          isSigningUp: isSigningUp,
          clearAuthError: true,
          clearOtpError: true,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.passcode,
        isSendingOtp: isSendingOtp,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
        pendingLoginUser: user,
        pendingProfiles: profileResolution.profiles,
        pendingActiveProfile: profileResolution.activeProfile,
        pendingProfileLoadError: profileResolution.errorMessage,
        passcodeFlow: PasscodeFlow.setup,
        passcodeCanSkip: true,
        passcodeLoginRequiresOtp: false,
        clearAuthError: true,
        clearOtpError: true,
        clearPasscodeError: true,
        clearPendingActiveProfile: profileResolution.activeProfile == null,
        clearPendingProfileLoadError: profileResolution.errorMessage == null,
      ),
    );
  }

  Future<void> _emitAuthenticatedHome(
    LoginUser user,
    ProfileSessionResolution profileResolution,
  ) async {
    if (!await _completeAuthenticatedSession(user, profileResolution)) {
      return;
    }
    emit(
      state.copyWith(
        screen: AppScreen.home,
        isRestoringSession: false,
        clearAuthError: true,
        clearPendingSession: true,
        clearPasscodeError: true,
        passcodeLoginRequiresOtp: false,
      ),
    );
  }

  Future<void> _completePendingHome({bool? isPasscodeBusy}) async {
    final user = state.pendingLoginUser;
    if (user == null) {
      emit(
        state.copyWith(
          screen: AppScreen.welcome,
          isPasscodeBusy: isPasscodeBusy ?? false,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      return;
    }

    if (!await _completeAuthenticatedSession(
      user,
      ProfileSessionResolution(
        profiles: state.pendingProfiles,
        activeProfile: state.pendingActiveProfile,
        errorMessage: state.pendingProfileLoadError,
      ),
    )) {
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.home,
        isPasscodeBusy: isPasscodeBusy ?? false,
        clearPendingSession: true,
        clearPasscodeError: true,
        passcodeLoginRequiresOtp: false,
      ),
    );
  }

  Future<bool> _completeAuthenticatedSession(
    LoginUser user,
    ProfileSessionResolution profileResolution, {
    bool rememberAccount = true,
  }) async {
    if (rememberAccount) {
      await _rememberAuthenticatedAccount(user);
    }
    if (isClosed) {
      return false;
    }
    _pingNotificationsAfterAuth(user);
    _handoffAuthenticatedSession(user, profileResolution);
    return !isClosed;
  }

  void _returnToLoginAfterPinAttempt({
    String? loginName,
    String? error,
    bool clearPinLogin = false,
    bool clearOtpPreview = false,
  }) {
    emit(
      state.copyWith(
        screen: AppScreen.login,
        isPasscodeBusy: false,
        loginName: loginName,
        authError: error,
        clearDevOtp: clearOtpPreview,
        clearOtpExpiry: clearOtpPreview,
        clearOtpError: clearOtpPreview,
        clearPendingSession: true,
        clearPasscodeError: true,
        clearPinLogin: clearPinLogin,
        passcodeLoginRequiresOtp: false,
      ),
    );
    unawaited(checkPinLoginAvailability());
  }

  void _handoffAuthenticatedSession(
    LoginUser user,
    ProfileSessionResolution profileResolution,
  ) {
    if (isClosed) {
      return;
    }
    _onAuthenticated(
      AuthenticatedSession(
        user: user,
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
      ),
    );
  }

  Future<void> _rememberAuthenticatedAccount(LoginUser user) async {
    final activeLoginName = state.loginName?.trim();
    final userPhone = user.phone?.trim();
    final userEmail = user.email?.trim();
    final loginName = activeLoginName != null && activeLoginName.isNotEmpty
        ? activeLoginName
        : userPhone != null && userPhone.isNotEmpty
        ? userPhone
        : userEmail;
    if (user.id <= 0 || loginName == null || loginName.isEmpty) {
      return;
    }

    try {
      await _passcodeService.rememberLoginAccount(
        userId: user.id,
        loginName: loginName,
      );
    } catch (_) {
      // Remembered PIN login is optional and must not block authentication.
    }
  }

  void _pingNotificationsAfterAuth(LoginUser user) {
    if (user.id <= 0) {
      return;
    }

    unawaited(_notificationPingService.ping());
  }

  static NotificationPingService _defaultNotificationPingService(
    AuthService authService,
  ) {
    return authService is AuthApi
        ? ApiNotificationPingService()
        : const NoopNotificationPingService();
  }

  void _emitAuthError(
    String message, {
    bool? isCheckingLoginName,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) {
    if (state.screen == AppScreen.otp) {
      emit(
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

    emit(
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
