import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/notifications/notification_ping_service.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/errors/auth_status.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/profile_api.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';
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
        openWelcomeDetails();
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

  void openLogin({AuthEntryMode? mode}) {
    emit(
      state.copyWith(
        screen: AppScreen.login,
        authEntryMode: mode ?? state.authEntryMode,
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
        authEntryMode: AuthEntryMode.signup,
        clearAuthError: true,
        clearOtpError: true,
        clearPhoneLookup: true,
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
        isCheckingPinLogin: true,
        clearAuthError: true,
        clearOtpError: true,
        clearPhoneLookup: true,
        clearPinLogin: true,
      ),
    );

    try {
      final rememberedAccount = await _passcodeService.lastPasscodeAccount();
      if (isClosed) {
        return;
      }

      if (rememberedAccount != null) {
        final pinUser = LoginUser(
          id: rememberedAccount.userId,
          phone: rememberedAccount.phone,
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

      emit(
        state.copyWith(
          screen: AppScreen.login,
          isCheckingPinLogin: false,
          authEntryMode: AuthEntryMode.login,
          clearPinLogin: true,
          clearPasscodeError: true,
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
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
    final phone = state.phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      unawaited(_authService.clearPendingLogin(phone));
    }

    emit(
      state.copyWith(
        screen: AppScreen.login,
        phoneNumber: null,
        isVerifyingOtp: false,
        isSigningUp: false,
        otpFlow: OtpFlow.login,
        clearAuthError: true,
        clearDevOtp: true,
        clearOtpExpiry: true,
        clearOtpError: true,
        clearPhoneLookup: true,
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
          phoneNumber: null,
          checkedPhone: null,
          phoneExists: null,
          phoneLookupUser: null,
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
                  phone: rememberedAccount.phone,
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

  void clearPhoneLookup() {
    if (!state.isCheckingAuthPhone &&
        state.checkedPhone == null &&
        state.phoneExists == null &&
        state.phoneLookupUser == null &&
        state.phoneLookupError == null &&
        state.phoneLookupErrorStatus == null &&
        state.authError == null) {
      return;
    }

    emit(
      state.copyWith(
        isCheckingAuthPhone: false,
        clearAuthError: true,
        clearPhoneLookup: true,
      ),
    );
  }

  Future<void> lookupLoginPhone(String phone) async {
    if (state.isCheckingAuthPhone && state.checkedPhone == phone) {
      return;
    }

    emit(
      state.copyWith(
        phoneNumber: phone,
        checkedPhone: phone,
        isCheckingAuthPhone: true,
        clearPhoneExists: true,
        clearPhoneLookupUser: true,
        clearPhoneLookupError: true,
        clearPhoneLookupErrorStatus: true,
        clearAuthError: true,
      ),
    );

    try {
      final result = await _authService.lookupLoginPhone(phone);
      if (state.checkedPhone != phone) {
        return;
      }

      emit(
        state.copyWith(
          phoneNumber: phone,
          checkedPhone: phone,
          isCheckingAuthPhone: false,
          phoneExists: result.exists,
          phoneLookupUser: result.user,
          phoneLookupError: result.exists ? null : result.message,
          phoneLookupErrorStatus: result.exists ? null : result.status,
          otpFlow: OtpFlow.login,
          clearAuthError: true,
          clearPhoneLookupError: result.exists,
          clearPhoneLookupErrorStatus: result.exists,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (state.checkedPhone != phone) {
        return;
      }

      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            phoneNumber: phone,
            checkedPhone: phone,
            isCheckingAuthPhone: false,
            phoneExists: false,
            phoneLookupError: error.message,
            phoneLookupErrorStatus: error.status,
            clearAuthError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isCheckingAuthPhone: false,
          authError: error.message,
          clearPhoneLookup: true,
        ),
      );
    } catch (_) {
      if (state.checkedPhone != phone) {
        return;
      }

      emit(
        state.copyWith(
          isCheckingAuthPhone: false,
          authError: AppStrings.current(AppKeys.authPhoneCheckFailed),
          clearPhoneLookup: true,
        ),
      );
    }
  }

  Future<void> submitLoginPhone(String phone) async {
    if (state.isSendingOtp) {
      return;
    }

    final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
    if (!isSignupEntry &&
        state.checkedPhone == phone &&
        blocksAuthLoginActions(state.phoneLookupErrorStatus)) {
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.loginPhoneNotRegistered),
        ),
      );
      return;
    }

    if (isSignupEntry) {
      if (state.phoneExists == true && state.checkedPhone == phone) {
        emit(
          state.copyWith(
            authError: AppStrings.current(AppKeys.signupPhoneAlreadyRegistered),
          ),
        );
        return;
      }

      emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

      try {
        final otp = await _authService.sendOtp(
          phone: phone,
          kind: AuthOtpKind.signup,
        );
        emit(
          state.copyWith(
            screen: AppScreen.otp,
            phoneNumber: phone,
            otpExpiresAt: otp.expiresAt,
            otpExpiresIn: otp.expiresIn,
            devOtpCode: otp.otpCode,
            devOtpPurpose: otp.purpose,
            otpPreviewId: state.otpPreviewId + 1,
            otpFlow: OtpFlow.signup,
            isSendingOtp: false,
            clearAuthError: true,
            clearDevOtp: otp.otpCode == null,
            clearOtpExpiry: otp.expiresAt == null,
            clearOtpError: true,
          ),
        );
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

    if (state.phoneExists == false && state.checkedPhone == phone) {
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.loginPhoneNotRegistered),
        ),
      );
      return;
    }

    emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

    try {
      final result = await _authService.lookupLoginPhone(phone);
      final user = result.user;
      if (!result.exists) {
        emit(
          state.copyWith(
            screen: AppScreen.login,
            phoneNumber: phone,
            checkedPhone: phone,
            phoneExists: false,
            phoneLookupError: result.message,
            phoneLookupErrorStatus: result.status,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      if (user == null) {
        emit(
          state.copyWith(
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
          phoneNumber: phone,
          otpFlow: OtpFlow.login,
          isSendingOtp: true,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
      await _sendLoginOtp(phone);
    } on AuthException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        emit(
          state.copyWith(
            screen: AppScreen.login,
            phoneNumber: phone,
            checkedPhone: phone,
            phoneExists: false,
            phoneLookupError: error.message,
            phoneLookupErrorStatus: error.status,
            isSendingOtp: false,
            clearAuthError: true,
          ),
        );
        return;
      }

      _emitAuthError(error.message, isSendingOtp: false);
    } catch (_) {
      _emitAuthError(
        AppStrings.current(AppKeys.loginOtpFailed),
        isSendingOtp: false,
      );
    }
  }

  Future<void> resendLoginOtp() async {
    final phone = state.phoneNumber;
    if (state.isSendingOtp || phone == null || phone.trim().isEmpty) {
      return;
    }

    await _sendLoginOtp(phone);
  }

  Future<void> _sendLoginOtp(String phone) async {
    emit(
      state.copyWith(
        isSendingOtp: true,
        clearAuthError: true,
        clearOtpError: true,
      ),
    );

    try {
      final otp = await _authService.sendOtp(
        phone: phone,
        kind: AuthOtpKind.login,
      );
      if (state.phoneNumber != phone) {
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.otp,
          phoneNumber: phone,
          otpExpiresAt: otp.expiresAt,
          otpExpiresIn: otp.expiresIn,
          devOtpCode: otp.otpCode,
          devOtpPurpose: otp.purpose,
          otpPreviewId: state.otpPreviewId + 1,
          otpFlow: OtpFlow.login,
          isSendingOtp: false,
          clearAuthError: true,
          clearDevOtp: otp.otpCode == null,
          clearOtpExpiry: otp.expiresAt == null,
          clearOtpError: true,
        ),
      );
    } on AuthException catch (error) {
      if (state.phoneNumber != phone) {
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
      if (state.phoneNumber != phone) {
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

  Future<void> verifyOtp(String otpCode) async {
    final phone = state.phoneNumber;
    if (state.isVerifyingOtp || phone == null) {
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
        phone: phone,
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
      if (isOtpValidationStatus(error.status)) {
        emit(
          state.copyWith(
            isVerifyingOtp: false,
            otpError: error.message,
            otpErrorId: state.otpErrorId + 1,
            clearAuthError: true,
          ),
        );
        return;
      }

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

  static bool _canSkipLoginOtp(AuthPhoneLookupResult result) {
    return result.isTrusted == true && !result.requiredOtp;
  }

  Future<void> submitSignup({
    required String name,
    required String role,
    String? email,
  }) async {
    final phone = state.phoneNumber;
    final trimmedName = name.trim();
    final trimmedEmail = email?.trim();
    final trimmedRole = role.trim().toUpperCase();
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
    if (trimmedRole.isEmpty) {
      emit(
        state.copyWith(
          authError: AppStrings.current(AppKeys.missingProfileSelections),
        ),
      );
      return;
    }

    emit(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      final user = await _authService.signupWithPhone(
        phone: phone,
        name: trimmedName,
        role: trimmedRole,
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
    final phone = rememberedAccount?.userId == pinUser.id
        ? rememberedAccount?.phone.trim()
        : null;
    if (phone == null || phone.isEmpty) {
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

    try {
      final result = await _authService.lookupLoginPhone(phone);
      final user = result.user ?? pinUser;
      if (_canSkipLoginOtp(result)) {
        final profileResolution = await _profileResolver.resolveForUserId(
          user.id,
        );
        _pingNotificationsAfterAuth(user);
        await _rememberAuthenticatedAccount(user);
        _handoffAuthenticatedSession(user, profileResolution);
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

      emit(
        state.copyWith(
          screen: AppScreen.login,
          isPasscodeBusy: false,
          phoneNumber: phone,
          authError: AppStrings.current(AppKeys.pinLoginFailed),
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      unawaited(checkPinLoginAvailability());
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          isPasscodeBusy: false,
          authError: error.message,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      unawaited(checkPinLoginAvailability());
    } catch (_) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          isPasscodeBusy: false,
          authError: AppStrings.current(AppKeys.loginOtpFailed),
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      unawaited(checkPinLoginAvailability());
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
      _pingNotificationsAfterAuth(user);
      _handoffAuthenticatedSession(user, profileResolution);
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
    await _rememberAuthenticatedAccount(user);
    _pingNotificationsAfterAuth(user);
    _handoffAuthenticatedSession(user, profileResolution);
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

    await _rememberAuthenticatedAccount(user);
    _pingNotificationsAfterAuth(user);
    if (isClosed) {
      return;
    }
    _handoffAuthenticatedSession(
      user,
      ProfileSessionResolution(
        profiles: state.pendingProfiles,
        activeProfile: state.pendingActiveProfile,
        errorMessage: state.pendingProfileLoadError,
      ),
    );

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
    final userPhone = user.phone?.trim();
    final phone = userPhone != null && userPhone.isNotEmpty
        ? userPhone
        : state.phoneNumber?.trim();
    if (user.id <= 0 || phone == null || phone.isEmpty) {
      return;
    }

    try {
      await _passcodeService.rememberLoginAccount(
        userId: user.id,
        phone: phone,
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
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) {
    if (state.screen == AppScreen.otp) {
      emit(
        state.copyWith(
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
        isSendingOtp: isSendingOtp,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
        authError: message,
      ),
    );
  }
}
