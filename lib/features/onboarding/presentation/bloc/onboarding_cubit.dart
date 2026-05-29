import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_keys.dart';
import '../../../../core/localization/app_strings.dart';
import '../../data/avatar_picker.dart';
import '../../data/otp_auth_api.dart';
import '../../domain/phone_region.dart';

enum AppScreen {
  welcome,
  login,
  otp,
  signup,
  home,
}

enum OtpFlow {
  login,
  signup,
}

class OnboardingState {
  const OnboardingState({
    this.screen = AppScreen.welcome,
    this.phoneRegion = PhoneRegion.vn,
    this.selectedGrade = 'Lớp 1',
    this.selectedCurriculum = 'Kết nối tri thức',
    this.avatarPath,
    this.isPickingAvatar = false,
    this.avatarError,
    this.isRestoringSession = false,
    this.phoneNumber,
    this.checkedPhone,
    this.isCheckingAuthPhone = false,
    this.phoneExists,
    this.phoneLookupUser,
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
    bool clearAvatarPath = false,
    bool clearAvatarError = false,
    bool clearAuthError = false,
    bool clearDevOtp = false,
    bool clearOtpError = false,
    bool clearOtpExpiry = false,
    bool clearPhoneLookup = false,
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
      phoneExists: clearPhoneLookup ? null : phoneExists ?? this.phoneExists,
      phoneLookupUser:
          clearPhoneLookup ? null : phoneLookupUser ?? this.phoneLookupUser,
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
      loginUser: loginUser ?? this.loginUser,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    AvatarPickerService avatarPicker = const AvatarPickerService(),
    OtpAuthService? authService,
  })  : _avatarPicker = avatarPicker,
        _authService = authService ?? OtpAuthApi(),
        super(const OnboardingState());

  final AvatarPickerService _avatarPicker;
  final OtpAuthService _authService;

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
        loginUser: null,
        phoneNumber: null,
        checkedPhone: null,
        phoneExists: null,
        phoneLookupUser: null,
        clearAuthError: true,
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

      emit(
        state.copyWith(
          screen: user == null ? state.screen : AppScreen.home,
          isRestoringSession: false,
          loginUser: user,
          clearAuthError: true,
        ),
      );
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
        phoneExists: null,
        phoneLookupUser: null,
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
          otpFlow: OtpFlow.login,
          clearAuthError: true,
          clearDevOtp: true,
          clearOtpExpiry: true,
          clearOtpError: true,
        ),
      );
    } on OtpAuthException catch (error) {
      if (state.checkedPhone != phone) {
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
      if (error.status == 202) {
        emit(
          state.copyWith(
            screen: AppScreen.login,
            phoneNumber: phone,
            checkedPhone: phone,
            phoneExists: false,
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
        emit(
          state.copyWith(
            screen: AppScreen.signup,
            isVerifyingOtp: false,
            loginUser: result.user,
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
            authError: AppStrings.current(AppKeys.missingOtpUser),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.home,
          isVerifyingOtp: false,
          loginUser: result.user,
          clearAuthError: true,
          clearOtpError: true,
        ),
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

  Future<void> submitSignup({
    required String name,
    String? email,
  }) async {
    final phone = state.phoneNumber;
    final trimmedName = name.trim();
    final trimmedEmail = email?.trim();
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
        email: trimmedEmail?.isEmpty == true ? null : trimmedEmail,
        avatarPath: state.avatarPath,
      );
      emit(
        state.copyWith(
          screen: AppScreen.home,
          isSigningUp: false,
          loginUser: user,
          clearAuthError: true,
        ),
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
