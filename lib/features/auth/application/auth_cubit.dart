import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/errors/auth_status.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
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
  SignupFormData? _pendingSignupForm;
  String? _pendingSignupPhone;

  SignupFormData? get pendingSignupForm => _pendingSignupForm;

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
      case AppScreen.deviceVerification:
        backFromDeviceVerification();
        return true;
      case AppScreen.otp:
        backFromOtp();
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
      AppScreen.deviceVerification ||
      AppScreen.otp ||
      AppScreen.signup ||
      AppScreen.passcode => state.loginBackScreen,
      final screen => screen,
    };
  }

  AuthEntryMode _loginEntryModeForCurrentFlow(AuthEntryMode nextMode) {
    return switch (state.screen) {
      AppScreen.login ||
      AppScreen.deviceVerification ||
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
      AppScreen.deviceVerification ||
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
        clearTrustedDeviceState: true,
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

  void backFromOtp() {
    if (state.screen != AppScreen.otp) {
      return;
    }

    final signupPhone = _pendingSignupPhone;
    if (state.otpFlow == OtpFlow.signup &&
        signupPhone != null &&
        _pendingSignupForm != null) {
      final otpIdentifier = state.loginName?.trim();
      if (otpIdentifier != null && otpIdentifier.isNotEmpty) {
        unawaited(_authService.clearPendingLogin(otpIdentifier));
      }
      emit(
        state.copyWith(
          screen: AppScreen.signup,
          loginName: signupPhone,
          isSendingOtp: false,
          isVerifyingOtp: false,
          isSigningUp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      return;
    }

    if (state.otpFlow == OtpFlow.login &&
        state.selectedTrustedDeviceId != null &&
        state.trustedDevices.isNotEmpty) {
      emit(
        state.copyWith(
          screen: AppScreen.deviceVerification,
          isSendingOtp: false,
          isVerifyingOtp: false,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
          clearTrustedDeviceError: true,
        ),
      );
      return;
    }

    openLogin();
  }

  void backFromDeviceVerification() {
    if (state.screen != AppScreen.deviceVerification) {
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.login,
        isLoadingTrustedDevices: false,
        isSendingOtp: false,
        clearAuthError: true,
        clearOtpError: true,
        clearTrustedDeviceState: true,
      ),
    );
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
        clearTrustedDeviceState: true,
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
        clearTrustedDeviceState: true,
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
        clearTrustedDeviceState: true,
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
    _clearPendingSignup();

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
        clearTrustedDeviceState: true,
        clearPendingSession: true,
      ),
    );
    unawaited(checkPinLoginAvailability());
  }

  Future<void> logout() async {
    _clearPendingSignup();
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
          clearTrustedDeviceState: true,
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
        clearTrustedDeviceState: true,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
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

      _pendingSignupPhone = loginName;
      _pendingSignupForm = null;
      emit(
        state.copyWith(
          screen: AppScreen.signup,
          loginName: loginName,
          isCheckingLoginName: false,
          isSendingOtp: false,
          otpFlow: OtpFlow.signup,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
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

      if (result.isTrusted == false) {
        await _openDeviceVerification(user);
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

  Future<void> _openDeviceVerification(LoginUser user) async {
    emit(
      state.copyWith(
        isCheckingLoginName: false,
        isSendingOtp: true,
        isLoadingTrustedDevices: true,
        trustedDevices: const <AuthTrustedDevice>[],
        clearSelectedTrustedDevice: true,
        clearTrustedDeviceError: true,
        clearAuthError: true,
        clearDevOtp: true,
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
        emit(
          state.copyWith(
            screen: AppScreen.otp,
            trustedDevices: devices,
            isLoadingTrustedDevices: false,
            otpFlow: OtpFlow.login,
            showDevOtpPreview: true,
            clearSelectedTrustedDevice: true,
            clearTrustedDeviceError: true,
            clearAuthError: true,
            clearOtpError: true,
          ),
        );
        await _sendLoginOtp(loginName);
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.deviceVerification,
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
        state.screen != AppScreen.deviceVerification ||
        user == null ||
        user.id <= 0) {
      return;
    }

    emit(
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
          state.screen != AppScreen.deviceVerification ||
          state.loginLookupUser?.id != user.id) {
        return;
      }

      emit(
        state.copyWith(
          trustedDevices: devices,
          isLoadingTrustedDevices: false,
          clearSelectedTrustedDevice: true,
          clearTrustedDeviceError: true,
        ),
      );
    } on AuthException catch (error) {
      if (isClosed || state.screen != AppScreen.deviceVerification) {
        return;
      }
      emit(
        state.copyWith(
          isLoadingTrustedDevices: false,
          trustedDeviceError: error.message,
          clearSelectedTrustedDevice: true,
        ),
      );
    } catch (_) {
      if (isClosed || state.screen != AppScreen.deviceVerification) {
        return;
      }
      emit(
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

  void selectTrustedDevice(int deviceId) {
    if (state.screen != AppScreen.deviceVerification ||
        state.isLoadingTrustedDevices ||
        state.isSendingOtp ||
        !state.trustedDevices.any((device) => device.deviceId == deviceId)) {
      return;
    }

    emit(
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
    if (state.screen != AppScreen.deviceVerification ||
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
    emit(
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
    emit(
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
    if (state.screen == AppScreen.deviceVerification) {
      emit(
        state.copyWith(
          isSendingOtp: false,
          trustedDeviceError: message,
          clearAuthError: true,
        ),
      );
      return;
    }

    emit(
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
    emit(
      state.copyWith(
        screen: AppScreen.otp,
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
        final signupPhone = _pendingSignupPhone;
        final signupForm = _pendingSignupForm;
        if (signupPhone == null || signupForm == null) {
          emit(
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
      await _emitAuthenticatedHome(
        result.user!,
        profileResolution,
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
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.childNameRequired),
        ),
      );
      return;
    }

    if (trimmedEmail != null && !isValidEmailInput(trimmedEmail)) {
      emit(state.copyWith(authError: AppStrings.current(AppKeys.invalidEmail)));
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
      emit(
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

    emit(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      await _completeSignup(
        phone: phone,
        form: normalizedForm,
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
    final profileResolution = await _profileResolver.resolveForUserId(user.id);
    _clearPendingSignup();
    await _emitAuthenticatedHome(
      user,
      profileResolution,
      isVerifyingOtp: isVerifyingOtp,
      isSigningUp: isSigningUp,
      isNewlyRegistered: true,
    );
  }

  void _returnToSignupAfterOtp(String message) {
    final signupPhone = _pendingSignupPhone;
    emit(
      state.copyWith(
        screen: AppScreen.signup,
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
    ProfileSessionResolution profileResolution, {
    bool? isVerifyingOtp,
    bool? isSigningUp,
    bool isNewlyRegistered = false,
  }) async {
    if (!await _completeAuthenticatedSession(
      user,
      profileResolution,
      isNewlyRegistered: isNewlyRegistered,
    )) {
      return;
    }
    emit(
      state.copyWith(
        screen: AppScreen.home,
        isRestoringSession: false,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
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
    bool isNewlyRegistered = false,
  }) async {
    if (rememberAccount) {
      await _rememberAuthenticatedAccount(user);
    }
    if (isClosed) {
      return false;
    }
    _pingNotificationsAfterAuth(user);
    _handoffAuthenticatedSession(
      user,
      profileResolution,
      isNewlyRegistered: isNewlyRegistered,
    );
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
    ProfileSessionResolution profileResolution, {
    bool isNewlyRegistered = false,
  }) {
    if (isClosed) {
      return;
    }
    _onAuthenticated(
      AuthenticatedSession(
        user: user,
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
        isNewlyRegistered: isNewlyRegistered,
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
