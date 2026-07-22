import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/session/services/passcode_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('stores the login name under its dedicated key', () async {
    const service = SecurePasscodeService(storage: storage);

    await service.rememberLoginAccount(userId: 7, phone: ' 0901234567 ');

    expect(
      await storage.read(key: 'local_passcode_v1_login_name_user_7'),
      '0901234567',
    );
  });
}
