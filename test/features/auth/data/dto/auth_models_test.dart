import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/data/dto/auth_models.dart';

void main() {
  test('serializes the login identifier as login_name', () {
    const request = LoginRequest(loginName: '0901234567');

    expect(request.toJson(), <String, dynamic>{'login_name': '0901234567'});
  });

  test('serializes trusted-device fields for login 2FA OTP', () {
    const request = SendOtpRequest(
      otpType: 'LOGIN_2FA',
      identifier: '+84905666666',
      userId: 21,
      targetDeviceId: 4,
    );

    expect(request.toJson(), <String, dynamic>{
      'otp_type': 'LOGIN_2FA',
      'identifier': '+84905666666',
      'user_id': 21,
      'target_device_id': 4,
    });
  });

  test('omits trusted-device fields for registration OTP', () {
    const request = SendOtpRequest(
      otpType: 'REGISTER',
      identifier: 'learner@example.com',
    );

    expect(request.toJson(), <String, dynamic>{
      'otp_type': 'REGISTER',
      'identifier': 'learner@example.com',
    });
  });
}
