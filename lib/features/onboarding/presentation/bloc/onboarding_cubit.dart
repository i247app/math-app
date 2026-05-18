import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/avatar_picker.dart';
import '../../data/otp_auth_api.dart';
import '../../domain/phone_region.dart';

enum AppScreen {
  welcome,
  login,
  otp,
  profile,
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
    this.phoneNumber,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.otpExpiresIn,
    this.devOtpCode,
    this.devOtpPurpose,
    this.otpPreviewId = 0,
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
  final String? phoneNumber;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final int? otpExpiresIn;
  final String? devOtpCode;
  final String? devOtpPurpose;
  final int otpPreviewId;
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
    String? phoneNumber,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    int? otpExpiresIn,
    String? devOtpCode,
    String? devOtpPurpose,
    int? otpPreviewId,
    String? authError,
    LoginUser? loginUser,
    bool clearAvatarError = false,
    bool clearAuthError = false,
    bool clearDevOtp = false,
  }) {
    return OnboardingState(
      screen: screen ?? this.screen,
      phoneRegion: phoneRegion ?? this.phoneRegion,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedCurriculum: selectedCurriculum ?? this.selectedCurriculum,
      avatarPath: avatarPath ?? this.avatarPath,
      isPickingAvatar: isPickingAvatar ?? this.isPickingAvatar,
      avatarError: clearAvatarError ? null : avatarError ?? this.avatarError,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
      devOtpCode: clearDevOtp ? null : devOtpCode ?? this.devOtpCode,
      devOtpPurpose: clearDevOtp ? null : devOtpPurpose ?? this.devOtpPurpose,
      otpPreviewId: otpPreviewId ?? this.otpPreviewId,
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

  void openLogin() => emit(state.copyWith(screen: AppScreen.login));

  void openOtp() => emit(state.copyWith(screen: AppScreen.otp));

  void openProfile() => emit(state.copyWith(screen: AppScreen.profile));

  void selectPhoneRegion(PhoneRegion region) {
    emit(state.copyWith(phoneRegion: region));
  }

  void selectGrade(String grade) {
    emit(state.copyWith(selectedGrade: grade));
  }

  void selectCurriculum(String curriculum) {
    emit(state.copyWith(selectedCurriculum: curriculum));
  }

  Future<void> requestLoginOtp(String phone) async {
    if (state.isSendingOtp) {
      return;
    }

    emit(state.copyWith(isSendingOtp: true, clearAuthError: true));

    try {
      final otp = await _authService.sendLoginOtp(phone);
      emit(
        state.copyWith(
          screen: AppScreen.otp,
          phoneNumber: phone,
          otpExpiresIn: otp.expiresIn,
          devOtpCode: otp.otpCode,
          devOtpPurpose: otp.purpose,
          otpPreviewId: state.otpPreviewId + 1,
          isSendingOtp: false,
          clearAuthError: true,
          clearDevOtp: otp.otpCode == null,
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
          authError: 'Không thể gửi OTP. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> verifyLoginOtp(String otpCode) async {
    final phone = state.phoneNumber;
    if (state.isVerifyingOtp || phone == null) {
      return;
    }

    emit(state.copyWith(isVerifyingOtp: true, clearAuthError: true));

    try {
      final result = await _authService.verifyLoginOtp(
        phone: phone,
        otpCode: otpCode,
      );

      if (!result.isValid || result.user == null) {
        emit(
          state.copyWith(
            isVerifyingOtp: false,
            authError: result.message ?? 'OTP không hợp lệ.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          screen: AppScreen.profile,
          isVerifyingOtp: false,
          loginUser: result.user,
          clearAuthError: true,
        ),
      );
    } on OtpAuthException catch (error) {
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
          authError: 'Không thể xác thực OTP. Vui lòng thử lại.',
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
            avatarError: 'Không thể chọn ảnh lúc này.',
          ),
        );
      }
    }
  }
}
