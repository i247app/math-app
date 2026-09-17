import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/session/data/passcode_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('stores the login name under its dedicated key', () async {
    const service = SecurePasscodeService(storage: storage);

    await service.rememberLoginAccount(userId: 7, loginName: ' 0901234567 ');

    expect(
      await storage.read(key: 'local_passcode_v1_login_name_user_7'),
      '0901234567',
    );
  });

  test('restores an email login name independently from the PIN', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'local_passcode_v1_user_7': '1234',
      'local_passcode_v1_login_name_user_7': 'learner@example.com',
      'local_passcode_v1_last_user_id': '7',
    });
    const service = SecurePasscodeService(storage: storage);

    final account = await service.lastPasscodeAccount();

    expect(account?.userId, 7);
    expect(account?.loginName, 'learner@example.com');
    expect(await service.verifyPasscode(userId: 7, passcode: '1234'), isTrue);
  });
}
