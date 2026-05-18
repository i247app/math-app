import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/avatar_picker.dart';
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
    this.selectedCurriculum = 'Kết nối tri thức với cuộc sống',
    this.avatarPath,
    this.isPickingAvatar = false,
    this.avatarError,
  });

  final AppScreen screen;
  final PhoneRegion phoneRegion;
  final String selectedGrade;
  final String selectedCurriculum;
  final String? avatarPath;
  final bool isPickingAvatar;
  final String? avatarError;

  OnboardingState copyWith({
    AppScreen? screen,
    PhoneRegion? phoneRegion,
    String? selectedGrade,
    String? selectedCurriculum,
    String? avatarPath,
    bool? isPickingAvatar,
    String? avatarError,
    bool clearAvatarError = false,
  }) {
    return OnboardingState(
      screen: screen ?? this.screen,
      phoneRegion: phoneRegion ?? this.phoneRegion,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedCurriculum: selectedCurriculum ?? this.selectedCurriculum,
      avatarPath: avatarPath ?? this.avatarPath,
      isPickingAvatar: isPickingAvatar ?? this.isPickingAvatar,
      avatarError: clearAvatarError ? null : avatarError ?? this.avatarError,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    AvatarPickerService avatarPicker = const AvatarPickerService(),
  })  : _avatarPicker = avatarPicker,
        super(const OnboardingState());

  final AvatarPickerService _avatarPicker;

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
