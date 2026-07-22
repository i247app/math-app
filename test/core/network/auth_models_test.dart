import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/auth_models.dart';

void main() {
  test('serializes the login identifier as login_name', () {
    const request = LoginRequest(loginName: '0901234567');

    expect(request.toJson(), <String, dynamic>{'login_name': '0901234567'});
  });
}
