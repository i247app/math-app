import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

enum AppScreen { welcome, welcomeDetails, login, otp, signup, passcode, home }

enum OtpFlow { login, signup }

enum AuthEntryMode { login, signup }

enum PasscodeFlow { setup, unlock }

/// Transient state for authentication forms and passcode setup/unlock only.
/// Authenticated account/profile state belongs to [AppSessionCubit].
class AuthFlowState {
  const AuthFlowState({
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
    this.authEntryMode = AuthEntryMode.login,
    this.authError,
    this.passcodeFlow = PasscodeFlow.setup,
    this.passcodeCanSkip = false,
    this.isPasscodeBusy = false,
    this.passcodeError,
    this.passcodeErrorId = 0,
    this.passcodeLoginRequiresOtp = false,
    this.isCheckingPinLogin = false,
    this.canLoginWithPin = false,
    this.pinLoginUser,
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
  final AuthEntryMode authEntryMode;
  final String? authError;
  final PasscodeFlow passcodeFlow;
  final bool passcodeCanSkip;
  final bool isPasscodeBusy;
  final String? passcodeError;
  final int passcodeErrorId;
  final bool passcodeLoginRequiresOtp;
  final bool isCheckingPinLogin;
  final bool canLoginWithPin;
  final LoginUser? pinLoginUser;
  final LoginUser? pendingLoginUser;
  final List<StudentProfile> pendingProfiles;
  final StudentProfile? pendingActiveProfile;
  final String? pendingProfileLoadError;

  AuthFlowState copyWith({
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
    AuthEntryMode? authEntryMode,
    String? authError,
    PasscodeFlow? passcodeFlow,
    bool? passcodeCanSkip,
    bool? isPasscodeBusy,
    String? passcodeError,
    int? passcodeErrorId,
    bool? passcodeLoginRequiresOtp,
    bool? isCheckingPinLogin,
    bool? canLoginWithPin,
    LoginUser? pinLoginUser,
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
    bool clearPasscodeError = false,
    bool clearPinLogin = false,
    bool clearPinLoginUser = false,
    bool clearPendingSession = false,
    bool clearPendingActiveProfile = false,
    bool clearPendingProfileLoadError = false,
  }) {
    return AuthFlowState(
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
      authEntryMode: authEntryMode ?? this.authEntryMode,
      authError: clearAuthError ? null : authError ?? this.authError,
      passcodeFlow: passcodeFlow ?? this.passcodeFlow,
      passcodeCanSkip: passcodeCanSkip ?? this.passcodeCanSkip,
      isPasscodeBusy: isPasscodeBusy ?? this.isPasscodeBusy,
      passcodeError: clearPasscodeError
          ? null
          : passcodeError ?? this.passcodeError,
      passcodeErrorId: passcodeErrorId ?? this.passcodeErrorId,
      passcodeLoginRequiresOtp:
          passcodeLoginRequiresOtp ?? this.passcodeLoginRequiresOtp,
      isCheckingPinLogin: isCheckingPinLogin ?? this.isCheckingPinLogin,
      canLoginWithPin: clearPinLogin
          ? false
          : canLoginWithPin ?? this.canLoginWithPin,
      pinLoginUser: clearPinLogin || clearPinLoginUser
          ? null
          : pinLoginUser ?? this.pinLoginUser,
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
