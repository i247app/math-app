import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

enum AuthScreen {
  welcome,
  welcomeDetails,
  login,
  deviceVerification,
  otp,
  signup,
}

enum OtpFlow { login, signup }

enum AuthEntryMode { login, signup }

class AuthenticationResult {
  const AuthenticationResult({
    required this.user,
    required this.loginName,
    this.isNewlyRegistered = false,
  });

  final LoginUser user;
  final String? loginName;
  final bool isNewlyRegistered;
}

/// Transient state for login, signup, OTP and device verification only.
class AuthFlowState {
  const AuthFlowState({
    this.screen = AuthScreen.welcome,
    this.loginBackScreen = AuthScreen.welcomeDetails,
    this.loginEntryMode = AuthEntryMode.login,
    this.phoneRegion = PhoneRegion.vn,
    this.loginName,
    this.checkedLoginName,
    this.isCheckingLoginName = false,
    this.loginNameExists,
    this.loginLookupUser,
    this.loginLookupError,
    this.loginLookupErrorStatus,
    this.trustedDevices = const <AuthTrustedDevice>[],
    this.selectedTrustedDeviceId,
    this.isLoadingTrustedDevices = false,
    this.trustedDeviceError,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isSigningUp = false,
    this.otpExpiresAt,
    this.otpExpiresIn,
    this.devOtpCode,
    this.devOtpPurpose,
    this.showDevOtpPreview = false,
    this.otpPreviewId = 0,
    this.otpError,
    this.otpErrorId = 0,
    this.otpFlow = OtpFlow.login,
    this.authEntryMode = AuthEntryMode.login,
    this.authError,
    this.authenticationResult,
    this.authenticationResultId = 0,
  });

  final AuthScreen screen;
  final AuthScreen loginBackScreen;
  final AuthEntryMode loginEntryMode;
  final PhoneRegion phoneRegion;
  final String? loginName;
  final String? checkedLoginName;
  final bool isCheckingLoginName;
  final bool? loginNameExists;
  final LoginUser? loginLookupUser;
  final String? loginLookupError;
  final int? loginLookupErrorStatus;
  final List<AuthTrustedDevice> trustedDevices;
  final int? selectedTrustedDeviceId;
  final bool isLoadingTrustedDevices;
  final String? trustedDeviceError;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isSigningUp;
  final String? otpExpiresAt;
  final int? otpExpiresIn;
  final String? devOtpCode;
  final String? devOtpPurpose;
  final bool showDevOtpPreview;
  final int otpPreviewId;
  final String? otpError;
  final int otpErrorId;
  final OtpFlow otpFlow;
  final AuthEntryMode authEntryMode;
  final String? authError;
  final AuthenticationResult? authenticationResult;
  final int authenticationResultId;

  AuthFlowState copyWith({
    AuthScreen? screen,
    AuthScreen? loginBackScreen,
    AuthEntryMode? loginEntryMode,
    PhoneRegion? phoneRegion,
    String? loginName,
    String? checkedLoginName,
    bool? isCheckingLoginName,
    bool? loginNameExists,
    LoginUser? loginLookupUser,
    String? loginLookupError,
    int? loginLookupErrorStatus,
    List<AuthTrustedDevice>? trustedDevices,
    int? selectedTrustedDeviceId,
    bool? isLoadingTrustedDevices,
    String? trustedDeviceError,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
    String? otpExpiresAt,
    int? otpExpiresIn,
    String? devOtpCode,
    String? devOtpPurpose,
    bool? showDevOtpPreview,
    int? otpPreviewId,
    String? otpError,
    int? otpErrorId,
    OtpFlow? otpFlow,
    AuthEntryMode? authEntryMode,
    String? authError,
    AuthenticationResult? authenticationResult,
    int? authenticationResultId,
    bool clearAuthError = false,
    bool clearDevOtp = false,
    bool clearOtpError = false,
    bool clearOtpExpiry = false,
    bool clearLoginName = false,
    bool clearLoginLookup = false,
    bool clearLoginNameExists = false,
    bool clearLoginLookupUser = false,
    bool clearLoginLookupError = false,
    bool clearLoginLookupErrorStatus = false,
    bool clearTrustedDeviceState = false,
    bool clearSelectedTrustedDevice = false,
    bool clearTrustedDeviceError = false,
    bool clearAuthenticationResult = false,
  }) {
    return AuthFlowState(
      screen: screen ?? this.screen,
      loginBackScreen: loginBackScreen ?? this.loginBackScreen,
      loginEntryMode: loginEntryMode ?? this.loginEntryMode,
      phoneRegion: phoneRegion ?? this.phoneRegion,
      loginName: clearLoginName ? null : loginName ?? this.loginName,
      checkedLoginName: clearLoginLookup
          ? null
          : checkedLoginName ?? this.checkedLoginName,
      isCheckingLoginName: isCheckingLoginName ?? this.isCheckingLoginName,
      loginNameExists: clearLoginLookup || clearLoginNameExists
          ? null
          : loginNameExists ?? this.loginNameExists,
      loginLookupUser: clearLoginLookup || clearLoginLookupUser
          ? null
          : loginLookupUser ?? this.loginLookupUser,
      loginLookupError: clearLoginLookup || clearLoginLookupError
          ? null
          : loginLookupError ?? this.loginLookupError,
      loginLookupErrorStatus: clearLoginLookup || clearLoginLookupErrorStatus
          ? null
          : loginLookupErrorStatus ?? this.loginLookupErrorStatus,
      trustedDevices: clearTrustedDeviceState
          ? const <AuthTrustedDevice>[]
          : trustedDevices ?? this.trustedDevices,
      selectedTrustedDeviceId:
          clearTrustedDeviceState || clearSelectedTrustedDevice
          ? null
          : selectedTrustedDeviceId ?? this.selectedTrustedDeviceId,
      isLoadingTrustedDevices: clearTrustedDeviceState
          ? false
          : isLoadingTrustedDevices ?? this.isLoadingTrustedDevices,
      trustedDeviceError: clearTrustedDeviceState || clearTrustedDeviceError
          ? null
          : trustedDeviceError ?? this.trustedDeviceError,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isSigningUp: isSigningUp ?? this.isSigningUp,
      otpExpiresAt: clearOtpExpiry ? null : otpExpiresAt ?? this.otpExpiresAt,
      otpExpiresIn: clearOtpExpiry ? null : otpExpiresIn ?? this.otpExpiresIn,
      devOtpCode: clearDevOtp ? null : devOtpCode ?? this.devOtpCode,
      devOtpPurpose: clearDevOtp ? null : devOtpPurpose ?? this.devOtpPurpose,
      showDevOtpPreview: clearDevOtp
          ? false
          : showDevOtpPreview ?? this.showDevOtpPreview,
      otpPreviewId: otpPreviewId ?? this.otpPreviewId,
      otpError: clearOtpError ? null : otpError ?? this.otpError,
      otpErrorId: otpErrorId ?? this.otpErrorId,
      otpFlow: otpFlow ?? this.otpFlow,
      authEntryMode: authEntryMode ?? this.authEntryMode,
      authError: clearAuthError ? null : authError ?? this.authError,
      authenticationResult: clearAuthenticationResult
          ? null
          : authenticationResult ?? this.authenticationResult,
      authenticationResultId:
          authenticationResultId ?? this.authenticationResultId,
    );
  }
}
