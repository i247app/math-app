import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

enum AuthScreen {
  welcome,
  welcomeDetails,
  login,
  signup,
  deviceVerification,
  otp,
  registrationProfile,
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
    this.entryBackScreen = AuthScreen.welcomeDetails,
    this.initialEntryMode = AuthEntryMode.login,
    this.phoneRegion = PhoneRegion.vn,
    this.loginName,
    this.checkedIdentifier,
    this.isCheckingIdentifier = false,
    this.identifierExists,
    this.identifierLookupUser,
    this.identifierLookupError,
    this.identifierLookupErrorStatus,
    this.trustedDevices = const <AuthTrustedDevice>[],
    this.selectedTrustedDeviceId,
    this.isLoadingTrustedDevices = false,
    this.trustedDeviceError,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isSigningUp = false,
    this.otpExpiresAt,
    this.otpExpiresIn,
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
  final AuthScreen entryBackScreen;
  final AuthEntryMode initialEntryMode;
  final PhoneRegion phoneRegion;
  final String? loginName;
  final String? checkedIdentifier;
  final bool isCheckingIdentifier;
  final bool? identifierExists;
  final LoginUser? identifierLookupUser;
  final String? identifierLookupError;
  final int? identifierLookupErrorStatus;
  final List<AuthTrustedDevice> trustedDevices;
  final int? selectedTrustedDeviceId;
  final bool isLoadingTrustedDevices;
  final String? trustedDeviceError;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isSigningUp;
  final String? otpExpiresAt;
  final int? otpExpiresIn;
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
    AuthScreen? entryBackScreen,
    AuthEntryMode? initialEntryMode,
    PhoneRegion? phoneRegion,
    String? loginName,
    String? checkedIdentifier,
    bool? isCheckingIdentifier,
    bool? identifierExists,
    LoginUser? identifierLookupUser,
    String? identifierLookupError,
    int? identifierLookupErrorStatus,
    List<AuthTrustedDevice>? trustedDevices,
    int? selectedTrustedDeviceId,
    bool? isLoadingTrustedDevices,
    String? trustedDeviceError,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningUp,
    String? otpExpiresAt,
    int? otpExpiresIn,
    int? otpPreviewId,
    String? otpError,
    int? otpErrorId,
    OtpFlow? otpFlow,
    AuthEntryMode? authEntryMode,
    String? authError,
    AuthenticationResult? authenticationResult,
    int? authenticationResultId,
    bool clearAuthError = false,
    bool clearOtpError = false,
    bool clearOtpExpiry = false,
    bool clearLoginName = false,
    bool clearIdentifierLookup = false,
    bool clearIdentifierExists = false,
    bool clearIdentifierLookupUser = false,
    bool clearIdentifierLookupError = false,
    bool clearIdentifierLookupErrorStatus = false,
    bool clearTrustedDeviceState = false,
    bool clearSelectedTrustedDevice = false,
    bool clearTrustedDeviceError = false,
    bool clearAuthenticationResult = false,
  }) {
    return AuthFlowState(
      screen: screen ?? this.screen,
      entryBackScreen: entryBackScreen ?? this.entryBackScreen,
      initialEntryMode: initialEntryMode ?? this.initialEntryMode,
      phoneRegion: phoneRegion ?? this.phoneRegion,
      loginName: clearLoginName ? null : loginName ?? this.loginName,
      checkedIdentifier: clearIdentifierLookup
          ? null
          : checkedIdentifier ?? this.checkedIdentifier,
      isCheckingIdentifier: isCheckingIdentifier ?? this.isCheckingIdentifier,
      identifierExists: clearIdentifierLookup || clearIdentifierExists
          ? null
          : identifierExists ?? this.identifierExists,
      identifierLookupUser: clearIdentifierLookup || clearIdentifierLookupUser
          ? null
          : identifierLookupUser ?? this.identifierLookupUser,
      identifierLookupError: clearIdentifierLookup || clearIdentifierLookupError
          ? null
          : identifierLookupError ?? this.identifierLookupError,
      identifierLookupErrorStatus:
          clearIdentifierLookup || clearIdentifierLookupErrorStatus
          ? null
          : identifierLookupErrorStatus ?? this.identifierLookupErrorStatus,
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
