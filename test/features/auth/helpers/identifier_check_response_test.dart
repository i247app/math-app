import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/helpers/identifier_check_response.dart';

void main() {
  test('selects the OTP flag that matches the identifier type', () {
    const response = <String, dynamic>{
      'mstatus': 200,
      'email_otp_enable': true,
      'phone_otp_enable': false,
    };

    expect(
      IdentifierAvailability.fromResponse(
        response,
        'learner@example.com',
      )?.otpEnabled,
      isTrue,
    );
    expect(
      IdentifierAvailability.fromResponse(response, '+84702465814')?.otpEnabled,
      isFalse,
    );
    expect(
      IdentifierAvailability.fromResponse(const <String, dynamic>{
        'mstatus': 200,
        'email_otp_enable': true,
      }, 'learner@example.com')?.otpEnabled,
      isTrue,
    );
    expect(
      IdentifierAvailability.fromResponse(const <String, dynamic>{
        'mstatus': 200,
      }, 'learner@example.com'),
      isNull,
    );
  });
}
