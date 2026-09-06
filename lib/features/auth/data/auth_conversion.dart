import 'package:numi/features/auth/data/auth_api_models.dart';
import 'package:numi/features/auth/data/device_api_models.dart';
import 'package:numi/features/auth/models/auth_models.dart';

extension AuthUserDtoConversion on AuthUser {
  LoginUser toModel({String? fallbackLoginName}) {
    final fallbackIsEmail = fallbackLoginName?.contains('@') == true;
    return LoginUser(
      id: userId ?? id ?? 0,
      email: email ?? (fallbackIsEmail ? fallbackLoginName : null),
      name: name,
      phone: phone ?? (fallbackIsEmail ? null : fallbackLoginName),
      avatarUrl: avatarUrl,
      role: role,
      createDt: createDt,
      modifyDt: modifyDt,
    );
  }
}

extension AuthResponseDtoConversion on AuthResponse {
  LoginUser toSignupModel({
    required String fallbackPhone,
    required String fallbackName,
    String? fallbackEmail,
  }) {
    final dtoUser = user;
    final dtoProfile = profile;
    return LoginUser(
      id: dtoUser?.userId ?? dtoUser?.id ?? dtoProfile?.userId ?? 0,
      email: dtoUser?.email ?? fallbackEmail,
      name: dtoProfile?.name ?? dtoUser?.name ?? fallbackName,
      phone: dtoUser?.phone ?? fallbackPhone,
      avatarUrl: dtoProfile?.avatarUrl ?? dtoUser?.avatarUrl,
      role: dtoUser?.role,
      createDt: dtoUser?.createDt ?? dtoProfile?.createDt,
      modifyDt: dtoUser?.modifyDt ?? dtoProfile?.modifyDt,
    );
  }
}

extension SendOtpResponseDtoConversion on SendOtpResponse {
  SendOtpResult toModel({required AuthOtpKind kind}) {
    return SendOtpResult(
      otpCode: otpCode,
      purpose: kind.previewPurpose,
      expiresAt: expiresAt,
      expiresIn: _expiresInFrom(expiresAt) ?? 0,
    );
  }
}

extension DeviceModelDtoConversion on DeviceModel {
  AuthTrustedDevice? toModel() {
    final id = deviceId;
    if (id == null) return null;
    return AuthTrustedDevice(
      deviceId: id,
      deviceName: _displayName(id),
      deviceUuid: deviceUuid,
      platform: platform,
    );
  }

  String _displayName(int id) {
    final name = deviceName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final platformName = platform?.trim();
    if (platformName != null &&
        platformName.isNotEmpty &&
        platformName.toUpperCase() != 'UNKNOWN') {
      return platformName;
    }
    return 'Device $id';
  }
}

int? _expiresInFrom(String? expiresAt) {
  if (expiresAt == null) return null;
  final parsed = DateTime.tryParse(expiresAt);
  if (parsed == null) return null;
  final seconds = parsed.toUtc().difference(DateTime.now().toUtc()).inSeconds;
  return seconds < 0 ? 0 : seconds;
}
