import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/auth/models/auth_profile_resolution.dart';
import 'package:numi_flutter/features/profile/services/active_profile_session.dart';
import 'package:numi_flutter/features/profile/services/avatar_picker_service.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/auth/passcode_service.dart';
import 'package:numi_flutter/features/auth/services/auth_profile_resolver.dart';
import 'package:numi_flutter/features/profile/profile_api.dart';
import 'package:numi_flutter/features/auth/phone_region.dart';

import 'package:numi_flutter/features/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AvatarPickerService avatarPicker = const AvatarPickerService(),
    OtpAuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    AuthProfileResolver? profileResolver,
    PasscodeService passcodeService = const SecurePasscodeService(),
    AuthState? initialState,
  }) : _avatarPicker = avatarPicker,
       _authService = authService ?? OtpAuthApi(),
       _profileResolver =
           profileResolver ??
           AuthProfileResolver(
             profileService: profileService ?? ProfileApi(),
             activeProfileSession: activeProfileSession,
           ),
       _passcodeService = passcodeService,
       super(initialState ?? const AuthState());

  final AvatarPickerService _avatarPicker;
  final OtpAuthService _authService;
  final AuthProfileResolver _profileResolver;
  final PasscodeService _passcodeService;

  void openWelcome() => emit(state.copyWith(screen: AppScreen.welcome));

  void openWelcomeDetails() =>
      emit(state.copyWith(screen: AppScreen.welcomeDetails));

  void openLogin() {
    emit(state.copyWith(screen: AppScreen.login, clearOtpError: true));
    unawaited(checkPinLoginAvailability());
  }

  void openOtp() =>
      emit(state.copyWith(screen: AppScreen.otp, clearOtpError: true));

  void openSignup() => emit(state.copyWith(screen: AppScreen.signup));

  void cancelSignupToLogin() {
    final phone = state.phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      unawaited(_authService.clearOtpSession(phone));
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
        clearLoginUser: true,
        clearProfiles: true,
        clearPendingSession: true,
        clearAvatarPath: true,
        clearAvatarError: true,
      ),
    );
    unawaited(checkPinLoginAvailability());
  }

  void openHome() => emit(state.copyWith(screen: AppScreen.home));

  Future<void> logout() async {
    await _authService.logout();
    if (!isClosed) {
      emit(
        state.copyWith(
          screen: AppScreen.login,
          clearLoginUser: true,
          phoneNumber: null,
          checkedPhone: null,
          phoneExists: null,
          phoneLookupUser: null,
          clearProfiles: true,
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
    if (state.isRestoringSession || state.loginUser != null) {
      return;
    }

    emit(state.copyWith(isRestoringSession: true, clearAuthError: true));

    try {
      final user = await _authService.restoreSession();
      if (isClosed) {
        return;
      }

      final profileResolution = user == null
          ? const AuthProfileResolution.empty()
          : await _profileResolver.resolveForUser(user);

      if (user == null) {
        emit(
          state.copyWith(
            isRestoringSession: false,
            clearAuthError: true,
            clearProfiles: true,
            clearPendingSession: true,
            clearPasscodeError: true,
          ),
        );
        return;
      }

      await _emitAuthenticatedHome(user, profileResolution);
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(isRestoringSession: false));
      }
    }
  }

  void selectPhoneRegion(PhoneRegion region) {
    emit(state.copyWith(phoneRegion: region));
  }

  void selectGrade(String grade) {
    emit(state.copyWith(selectedGrade: grade));
  }

  void selectCurriculum(String curriculum) {
    emit(state.copyWith(selectedCurriculum: curriculum));
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

  Future<void> checkAuthPhone(String phone) async {
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
      final result = await _authService.checkAuthPhone(phone);
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
    } on OtpAuthException catch (error) {
      if (state.checkedPhone != phone) {
        return;
      }

      if (_isUserNotFoundStatus(error.status)) {
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

    if (state.checkedPhone == phone &&
        _blocksLoginActions(state.phoneLookupErrorStatus)) {
      return;
    }

    if (state.phoneExists == false && state.checkedPhone == phone) {
      emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

      try {
        final otp = await _authService.sendRegisterOtp(phone);
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
      } on OtpAuthException catch (error) {
        _emitAuthError(error.message, isSendingOtp: false);
      } catch (_) {
        _emitAuthError(
          AppStrings.current(AppKeys.signupOtpFailed),
          isSendingOtp: false,
        );
      }
      return;
    }

    emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

    try {
      final result = await _authService.loginByPhone(phone);
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
        final profileResolution = await _profileResolver.resolveForUser(user);
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
    } on OtpAuthException catch (error) {
      if (_isUserNotFoundStatus(error.status)) {
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
      final otp = await _authService.sendLoginOtp(phone);
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
    } on OtpAuthException catch (error) {
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

  Future<void> verifyLoginOtp(String otpCode) async {
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
      final result = await _authService.verifyLoginOtp(
        phone: phone,
        otpCode: otpCode,
        otpType: otpFlow == OtpFlow.signup ? registerOtpType : loginOtpType,
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
        final profileResolution = result.user == null
            ? const AuthProfileResolution.empty()
            : await _profileResolver.resolveForUser(result.user!);
        emit(
          state.copyWith(
            screen: AppScreen.signup,
            isVerifyingOtp: false,
            loginUser: result.user,
            profiles: profileResolution.profiles,
            activeProfile: profileResolution.activeProfile,
            profileLoadError: profileResolution.errorMessage,
            clearAuthError: true,
            clearOtpError: true,
            clearActiveProfile: profileResolution.activeProfile == null,
            clearProfileLoadError: profileResolution.errorMessage == null,
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

      final profileResolution = await _profileResolver.resolveForUser(
        result.user!,
      );
      await _emitHomeOrPasscodeSetup(
        user: result.user!,
        profileResolution: profileResolution,
        isVerifyingOtp: false,
      );
    } on OtpAuthException catch (error) {
      if (_isOtpValidationError(error.status)) {
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

  static bool _isOtpValidationError(int? status) {
    return status == 400 || status == 422 || status == 4706;
  }

  static bool _isUserNotFoundStatus(int? status) {
    return status == 202 || status == 4006;
  }

  static bool _blocksLoginActions(int? status) {
    return status == 4006;
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
        avatarPath: state.avatarPath,
      );
      final profileResolution = await _profileResolver.resolveForUser(user);
      await _emitHomeOrPasscodeSetup(
        user: user,
        profileResolution: profileResolution,
        isSigningUp: false,
      );
    } on OtpAuthException catch (error) {
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
      final result = await _authService.loginByPhone(phone);
      final user = result.user ?? pinUser;
      if (_canSkipLoginOtp(result)) {
        final profileResolution = await _profileResolver.resolveForUser(user);
        await _rememberAuthenticatedAccount(user);
        emit(
          state.copyWith(
            screen: AppScreen.home,
            isPasscodeBusy: false,
            loginUser: user,
            profiles: profileResolution.profiles,
            activeProfile: profileResolution.activeProfile,
            profileLoadError: profileResolution.errorMessage,
            clearAuthError: true,
            clearOtpError: true,
            clearActiveProfile: profileResolution.activeProfile == null,
            clearProfileLoadError: profileResolution.errorMessage == null,
            clearPendingSession: true,
            clearPasscodeError: true,
            passcodeLoginRequiresOtp: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.otp,
          isPasscodeBusy: false,
          phoneNumber: phone,
          isSendingOtp: true,
          otpFlow: OtpFlow.login,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
          clearPendingSession: true,
          clearPasscodeError: true,
          passcodeLoginRequiresOtp: false,
        ),
      );
      await _sendLoginOtp(phone);
    } on OtpAuthException catch (error) {
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
    required AuthProfileResolution profileResolution,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    await _rememberAuthenticatedAccount(user);
    final hasPasscode = await _passcodeService.hasPasscode(user.id);
    if (hasPasscode) {
      emit(
        state.copyWith(
          screen: AppScreen.home,
          isSendingOtp: isSendingOtp,
          isVerifyingOtp: isVerifyingOtp,
          isSigningUp: isSigningUp,
          loginUser: user,
          profiles: profileResolution.profiles,
          activeProfile: profileResolution.activeProfile,
          profileLoadError: profileResolution.errorMessage,
          clearAuthError: true,
          clearOtpError: true,
          clearActiveProfile: profileResolution.activeProfile == null,
          clearProfileLoadError: profileResolution.errorMessage == null,
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
    AuthProfileResolution profileResolution,
  ) async {
    await _rememberAuthenticatedAccount(user);
    emit(
      state.copyWith(
        screen: AppScreen.home,
        isRestoringSession: false,
        loginUser: user,
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
        clearAuthError: true,
        clearActiveProfile: profileResolution.activeProfile == null,
        clearProfileLoadError: profileResolution.errorMessage == null,
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
    if (isClosed) {
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.home,
        isPasscodeBusy: isPasscodeBusy ?? false,
        loginUser: user,
        profiles: state.pendingProfiles,
        activeProfile: state.pendingActiveProfile,
        profileLoadError: state.pendingProfileLoadError,
        clearPendingSession: true,
        clearPasscodeError: true,
        passcodeLoginRequiresOtp: false,
        clearActiveProfile: state.pendingActiveProfile == null,
        clearProfileLoadError: state.pendingProfileLoadError == null,
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

  Future<void> refreshProfiles() async {
    final user = state.loginUser;
    if (user == null) {
      return;
    }

    final profileResolution = await _profileResolver.resolveForUser(user);
    if (isClosed) {
      return;
    }

    emit(
      state.copyWith(
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
        clearActiveProfile: profileResolution.activeProfile == null,
        clearProfileLoadError: profileResolution.errorMessage == null,
      ),
    );
  }

  Future<void> activateProfile(StudentProfile profile) async {
    final user = state.loginUser;
    final profileId = ActiveProfileSession.profileStableId(profile);
    if (user == null || user.id <= 0 || profileId == null) {
      return;
    }

    await _profileResolver.rememberActiveProfile(user: user, profile: profile);
    if (isClosed) {
      return;
    }

    final profiles = <StudentProfile>[
      for (final existingProfile in state.profiles)
        if (ActiveProfileSession.profileStableId(existingProfile) != profileId)
          existingProfile,
      profile,
    ];

    emit(
      state.copyWith(
        profiles: profiles,
        activeProfile: profile,
        clearProfileLoadError: true,
      ),
    );
  }

  Future<void> pickAvatar() async {
    if (state.isPickingAvatar) {
      return;
    }

    emit(state.copyWith(isPickingAvatar: true, clearAvatarError: true));

    try {
      final path = await _avatarPicker.pickAvatarPath();
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          avatarPath: path,
          isPickingAvatar: false,
          clearAvatarError: true,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isPickingAvatar: false,
            avatarError: AppStrings.current(AppKeys.imagePickFailed),
          ),
        );
      }
    }
  }

  void clearAvatar() {
    emit(state.copyWith(clearAvatarPath: true, clearAvatarError: true));
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
