import 'package:numi/features/auth/data/dto/auth_models.dart';
import 'package:numi/features/auth/data/dto/device_models.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';

extension AuthUserDtoMapper on AuthUser {
  LoginUser toDomain({String? fallbackLoginName}) {
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

extension AuthResponseDtoMapper on AuthResponse {
  LoginUser toSignupDomain({
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

extension SendOtpResponseDtoMapper on SendOtpResponse {
  SendOtpResult toDomain({required AuthOtpKind kind}) {
    return SendOtpResult(
      otpCode: otpCode,
      purpose: kind.previewPurpose,
      expiresAt: expiresAt,
      expiresIn: _expiresInFrom(expiresAt) ?? 0,
    );
  }
}

extension DeviceModelDtoMapper on DeviceModel {
  AuthTrustedDevice? toDomain() {
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
