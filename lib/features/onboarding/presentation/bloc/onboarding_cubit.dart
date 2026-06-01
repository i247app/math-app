import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_keys.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/network/profile_models.dart';
import '../../data/active_profile_session.dart';
import '../../data/avatar_picker.dart';
import '../../data/otp_auth_api.dart';
import '../../data/passcode_service.dart';
import '../../data/profile_api.dart';
import '../../domain/phone_region.dart';

enum AppScreen {
  welcome,
  login,
  otp,
  signup,
  passcode,
  home,
}

enum OtpFlow {
  login,
  signup,
}

enum PasscodeFlow {
  setup,
  unlock,
}

class OnboardingState {
  const OnboardingState({
    this.screen = AppScreen.welcome,
    this.phoneRegion = PhoneRegion.vn,
    this.selectedGrade = '',
    this.selectedCurriculum = '',
    this.avatarPath,
    this.isPickingAvatar = false,
    this.avatarError,
    this.isRestoringSession = false,
    this.phoneNumber,
    this.checkedPhone,
    this.isCheckingAuthPhone = false,
    this.phoneExists,
    this.phoneLookupUser,
    this.phoneLookupError,
    this.phoneLookupErrorStatus,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isSigningUp = false,
    this.otpExpiresAt,
    this.otpExpiresIn,
    this.devOtpCode,
    this.devOtpPurpose,
    this.otpPreviewId = 0,
    this.otpError,
    this.otpErrorId = 0,
    this.otpFlow = OtpFlow.login,
    this.authError,
    this.loginUser,
    this.profiles = const <StudentProfile>[],
    this.activeProfile,
    this.profileLoadError,
    this.passcodeFlow = PasscodeFlow.setup,
    this.passcodeCanSkip = false,
    this.isPasscodeBusy = false,
    this.passcodeError,
    this.passcodeErrorId = 0,
    this.pendingLoginUser,
    this.pendingProfiles = const <StudentProfile>[],
    this.pendingActiveProfile,
    this.pendingProfileLoadError,
  });

  final AppScreen screen;
  final PhoneRegion phoneRegion;
  final String selectedGrade;
  final String selectedCurriculum;
  final String? avatarPath;
  final bool isPickingAvatar;
  final String? avatarError;
  final bool isRestoringSession;
  final String? phoneNumber;
  final String? checkedPhone;
  final bool isCheckingAuthPhone;
  final bool? phoneExists;
  final LoginUser? phoneLookupUser;
  final String? phoneLookupError;
  final int? phoneLookupErrorStatus;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isSigningUp;
  final String? otpExpiresAt;
  final int? otpExpiresIn;
  final String? devOtpCode;
  final String? devOtpPurpose;
  final int otpPreviewId;
  final String? otpError;
  final int otpErrorId;
  final OtpFlow otpFlow;
  final String? authError;
  final LoginUser? loginUser;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final PasscodeFlow passcodeFlow;
  final bool passcodeCanSkip;
  final bool isPasscodeBusy;
  final String? passcodeError;
  final int passcodeErrorId;
  final LoginUser? pendingLoginUser;
  final List<StudentProfile> pendingProfiles;
  final StudentProfile? pendingActiveProfile;
  final String? pendingProfileLoadError;

  ProfileRole get activeProfileRole => ProfileRole.fromProfile(activeProfile);

  OnboardingState copyWith({
    AppScreen? screen,
    PhoneRegion? phoneRegion,
    String? selectedGrade,
    String? selectedCurriculum,
    String? avatarPath,
    bool? isPickingAvatar,
    String? avatarError,
    bool? isRestoringSession,
    String? phoneNumber,
    String? checkedPhone,
    bool? isCheckingAuthPhone,
    bool? phoneExists,
    LoginUser? phoneLookupUser,
    String? phoneLookupError,
    int? phoneLookupErrorStatus,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
    String? otpExpiresAt,
    int? otpExpiresIn,
    String? devOtpCode,
    String? devOtpPurpose,
    int? otpPreviewId,
    String? otpError,
    int? otpErrorId,
    OtpFlow? otpFlow,
    String? authError,
    LoginUser? loginUser,
    List<StudentProfile>? profiles,
    StudentProfile? activeProfile,
    String? profileLoadError,
    PasscodeFlow? passcodeFlow,
    bool? passcodeCanSkip,
    bool? isPasscodeBusy,
    String? passcodeError,
    int? passcodeErrorId,
    LoginUser? pendingLoginUser,
    List<StudentProfile>? pendingProfiles,
    StudentProfile? pendingActiveProfile,
    String? pendingProfileLoadError,
    bool clearAvatarPath = false,
    bool clearAvatarError = false,
    bool clearAuthError = false,
    bool clearDevOtp = false,
    bool clearOtpError = false,
    bool clearOtpExpiry = false,
    bool clearPhoneLookup = false,
    bool clearPhoneExists = false,
    bool clearPhoneLookupUser = false,
    bool clearPhoneLookupError = false,
    bool clearPhoneLookupErrorStatus = false,
    bool clearLoginUser = false,
    bool clearProfiles = false,
    bool clearActiveProfile = false,
    bool clearProfileLoadError = false,
    bool clearPasscodeError = false,
    bool clearPendingSession = false,
    bool clearPendingActiveProfile = false,
    bool clearPendingProfileLoadError = false,
  }) {
    return OnboardingState(
      screen: screen ?? this.screen,
      phoneRegion: phoneRegion ?? this.phoneRegion,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedCurriculum: selectedCurriculum ?? this.selectedCurriculum,
      avatarPath: clearAvatarPath ? null : avatarPath ?? this.avatarPath,
      isPickingAvatar: isPickingAvatar ?? this.isPickingAvatar,
      avatarError: clearAvatarError ? null : avatarError ?? this.avatarError,
      isRestoringSession: isRestoringSession ?? this.isRestoringSession,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      checkedPhone: clearPhoneLookup ? null : checkedPhone ?? this.checkedPhone,
      isCheckingAuthPhone: isCheckingAuthPhone ?? this.isCheckingAuthPhone,
      phoneExists: clearPhoneLookup || clearPhoneExists
          ? null
          : phoneExists ?? this.phoneExists,
      phoneLookupUser: clearPhoneLookup || clearPhoneLookupUser
          ? null
          : phoneLookupUser ?? this.phoneLookupUser,
      phoneLookupError: clearPhoneLookup || clearPhoneLookupError
          ? null
          : phoneLookupError ?? this.phoneLookupError,
      phoneLookupErrorStatus: clearPhoneLookup || clearPhoneLookupErrorStatus
          ? null
          : phoneLookupErrorStatus ?? this.phoneLookupErrorStatus,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isSigningUp: isSigningUp ?? this.isSigningUp,
      otpExpiresAt: clearOtpExpiry ? null : otpExpiresAt ?? this.otpExpiresAt,
      otpExpiresIn: clearOtpExpiry ? null : otpExpiresIn ?? this.otpExpiresIn,
      devOtpCode: clearDevOtp ? null : devOtpCode ?? this.devOtpCode,
      devOtpPurpose: clearDevOtp ? null : devOtpPurpose ?? this.devOtpPurpose,
      otpPreviewId: otpPreviewId ?? this.otpPreviewId,
      otpError: clearOtpError ? null : otpError ?? this.otpError,
      otpErrorId: otpErrorId ?? this.otpErrorId,
      otpFlow: otpFlow ?? this.otpFlow,
      authError: clearAuthError ? null : authError ?? this.authError,
      loginUser: clearLoginUser ? null : loginUser ?? this.loginUser,
      profiles:
          clearProfiles ? const <StudentProfile>[] : profiles ?? this.profiles,
      activeProfile: clearProfiles || clearActiveProfile
          ? null
          : activeProfile ?? this.activeProfile,
      profileLoadError: clearProfiles || clearProfileLoadError
          ? null
          : profileLoadError ?? this.profileLoadError,
      passcodeFlow: passcodeFlow ?? this.passcodeFlow,
      passcodeCanSkip: passcodeCanSkip ?? this.passcodeCanSkip,
      isPasscodeBusy: isPasscodeBusy ?? this.isPasscodeBusy,
      passcodeError:
          clearPasscodeError ? null : passcodeError ?? this.passcodeError,
      passcodeErrorId: passcodeErrorId ?? this.passcodeErrorId,
      pendingLoginUser: clearPendingSession
          ? null
          : pendingLoginUser ?? this.pendingLoginUser,
      pendingProfiles: clearPendingSession
          ? const <StudentProfile>[]
          : pendingProfiles ?? this.pendingProfiles,
      pendingActiveProfile: clearPendingSession || clearPendingActiveProfile
          ? null
          : pendingActiveProfile ?? this.pendingActiveProfile,
      pendingProfileLoadError:
          clearPendingSession || clearPendingProfileLoadError
              ? null
              : pendingProfileLoadError ?? this.pendingProfileLoadError,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    AvatarPickerService avatarPicker = const AvatarPickerService(),
    OtpAuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  })  : _avatarPicker = avatarPicker,
        _authService = authService ?? OtpAuthApi(),
        _profileService = profileService ?? ProfileApi(),
        _activeProfileSession = activeProfileSession,
        _passcodeService = passcodeService,
        super(const OnboardingState());

  final AvatarPickerService _avatarPicker;
  final OtpAuthService _authService;
  final ProfileService _profileService;
  final ActiveProfileSession _activeProfileSession;
  final PasscodeService _passcodeService;

  void openWelcome() => emit(state.copyWith(screen: AppScreen.welcome));

  void openLogin() =>
      emit(state.copyWith(screen: AppScreen.login, clearOtpError: true));

  void openOtp() =>
      emit(state.copyWith(screen: AppScreen.otp, clearOtpError: true));

  void openSignup() => emit(state.copyWith(screen: AppScreen.signup));

  void openHome() => emit(state.copyWith(screen: AppScreen.home));

  Future<void> logout() async {
    await _authService.logout();
    if (!isClosed) {
      emit(state.copyWith(
        screen: AppScreen.welcome,
        clearLoginUser: true,
        phoneNumber: null,
        checkedPhone: null,
        phoneExists: null,
        phoneLookupUser: null,
        clearProfiles: true,
        clearAuthError: true,
        clearPendingSession: true,
        clearPasscodeError: true,
      ));
    }
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
          ? const _ResolvedProfiles.empty()
          : await _profilesForUser(user);

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

      if (await _passcodeService.hasPasscode(user.id)) {
        emit(
          state.copyWith(
            screen: AppScreen.passcode,
            isRestoringSession: false,
            pendingLoginUser: user,
            pendingProfiles: profileResolution.profiles,
            pendingActiveProfile: profileResolution.activeProfile,
            pendingProfileLoadError: profileResolution.errorMessage,
            passcodeFlow: PasscodeFlow.unlock,
            passcodeCanSkip: false,
            clearAuthError: true,
            clearPasscodeError: true,
            clearPendingActiveProfile: profileResolution.activeProfile == null,
            clearPendingProfileLoadError:
                profileResolution.errorMessage == null,
          ),
        );
        return;
      }

      _emitAuthenticatedHome(user, profileResolution);
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
        emit(
          state.copyWith(
            isSendingOtp: false,
            authError: error.message,
          ),
        );
      } catch (_) {
        emit(
          state.copyWith(
            isSendingOtp: false,
            authError: AppStrings.current(AppKeys.signupOtpFailed),
          ),
        );
      }
      return;
    }

    emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

    try {
      final otp = await _authService.sendLoginOtp(phone);
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

      emit(
        state.copyWith(
          isSendingOtp: false,
          authError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSendingOtp: false,
          authError: AppStrings.current(AppKeys.loginOtpFailed),
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
            ? const _ResolvedProfiles.empty()
            : await _profilesForUser(result.user!);
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
            authError: AppStrings.current(AppKeys.missingOtpUser),
          ),
        );
        return;
      }

      final profileResolution = await _profilesForUser(result.user!);
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
          authError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          authError: AppStrings.current(AppKeys.verifyOtpFailed),
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

    emit(state.copyWith(isSigningUp: true, clearAuthError: true));

    try {
      final user = await _authService.signupWithPhone(
        phone: phone,
        name: trimmedName,
        role: trimmedRole,
        email: trimmedEmail?.isEmpty == true ? null : trimmedEmail,
        avatarPath: state.avatarPath,
      );
      final profileResolution = await _profilesForUser(user);
      await _emitHomeOrPasscodeSetup(
        user: user,
        profileResolution: profileResolution,
        isSigningUp: false,
      );
    } on OtpAuthException catch (error) {
      emit(
        state.copyWith(
          isSigningUp: false,
          authError: error.message,
        ),
      );
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
          _completePendingHome(isPasscodeBusy: false);
        case PasscodeFlow.unlock:
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
          _completePendingHome(isPasscodeBusy: false);
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
    _completePendingHome();
  }

  Future<void> cancelPasscodeUnlock() async {
    if (state.passcodeFlow == PasscodeFlow.setup && state.passcodeCanSkip) {
      skipPasscodeSetup();
      return;
    }

    await logout();
  }

  Future<void> _emitHomeOrPasscodeSetup({
    required LoginUser user,
    required _ResolvedProfiles profileResolution,
    bool? isVerifyingOtp,
    bool? isSigningUp,
  }) async {
    final hasPasscode = await _passcodeService.hasPasscode(user.id);
    if (hasPasscode) {
      emit(
        state.copyWith(
          screen: AppScreen.home,
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
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        screen: AppScreen.passcode,
        isVerifyingOtp: isVerifyingOtp,
        isSigningUp: isSigningUp,
        pendingLoginUser: user,
        pendingProfiles: profileResolution.profiles,
        pendingActiveProfile: profileResolution.activeProfile,
        pendingProfileLoadError: profileResolution.errorMessage,
        passcodeFlow: PasscodeFlow.setup,
        passcodeCanSkip: true,
        clearAuthError: true,
        clearOtpError: true,
        clearPasscodeError: true,
        clearPendingActiveProfile: profileResolution.activeProfile == null,
        clearPendingProfileLoadError: profileResolution.errorMessage == null,
      ),
    );
  }

  void _emitAuthenticatedHome(
    LoginUser user,
    _ResolvedProfiles profileResolution,
  ) {
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
      ),
    );
  }

  void _completePendingHome({bool? isPasscodeBusy}) {
    final user = state.pendingLoginUser;
    if (user == null) {
      emit(
        state.copyWith(
          screen: AppScreen.welcome,
          isPasscodeBusy: isPasscodeBusy ?? false,
          clearPendingSession: true,
          clearPasscodeError: true,
        ),
      );
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
        clearActiveProfile: state.pendingActiveProfile == null,
        clearProfileLoadError: state.pendingProfileLoadError == null,
      ),
    );
  }

  Future<_ResolvedProfiles> _profilesForUser(LoginUser user) async {
    final userId = user.id;
    if (userId <= 0) {
      return const _ResolvedProfiles.empty();
    }

    try {
      final profiles = await _profileService.listProfiles(userId: userId);
      final activeProfile = await _activeProfileSession.resolveActiveProfile(
        userId: userId,
        profiles: profiles,
      );
      final activeProfileId =
          ActiveProfileSession.profileStableId(activeProfile);
      if (activeProfileId != null) {
        await _activeProfileSession.writeActiveProfileId(
          userId: userId,
          profileId: activeProfileId,
        );
      } else {
        await _activeProfileSession.clearActiveProfileId(userId);
      }
      return _ResolvedProfiles(
        profiles: profiles,
        activeProfile: activeProfile,
      );
    } on ProfileException catch (error) {
      return _ResolvedProfiles(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: error.message,
      );
    } catch (_) {
      return _ResolvedProfiles(
        profiles: const <StudentProfile>[],
        activeProfile: null,
        errorMessage: AppStrings.current(AppKeys.profileLoadFailed),
      );
    }
  }

  Future<void> refreshProfiles() async {
    final user = state.loginUser;
    if (user == null) {
      return;
    }

    final profileResolution = await _profilesForUser(user);
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
}

class _ResolvedProfiles {
  const _ResolvedProfiles({
    required this.profiles,
    required this.activeProfile,
    this.errorMessage,
  });

  const _ResolvedProfiles.empty()
      : profiles = const <StudentProfile>[],
        activeProfile = null,
        errorMessage = null;

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? errorMessage;
}
