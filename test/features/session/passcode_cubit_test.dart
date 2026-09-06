import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/session/controllers/passcode_cubit.dart';
import 'package:numi/features/session/controllers/passcode_state.dart';
import 'package:numi/features/session/data/passcode_service.dart';

class _FakePasscodeService implements PasscodeService {
  bool hasStoredPasscode = false;
  bool verifies = true;
  PasscodeLoginAccount? rememberedAccount;

  @override
  Future<void> clearPasscode(int userId) async {
    hasStoredPasscode = false;
  }

  @override
  Future<bool> hasPasscode(int userId) async => hasStoredPasscode;

  @override
  Future<PasscodeLoginAccount?> lastPasscodeAccount() async =>
      rememberedAccount;

  @override
  Future<int?> lastPasscodeUserId() async => rememberedAccount?.userId;

  @override
  Future<void> rememberLoginAccount({
    required int userId,
    required String loginName,
  }) async {
    rememberedAccount = PasscodeLoginAccount(
      userId: userId,
      loginName: loginName,
    );
  }

  @override
  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {
    hasStoredPasscode = true;
  }

  @override
  Future<bool> verifyPasscode({
    required int userId,
    required String passcode,
  }) async => verifies;
}

void main() {
  test('owns PIN setup and emits a session-ready outcome', () async {
    final service = _FakePasscodeService();
    final cubit = PasscodeCubit(passcodeService: service);

    final needsSetup = await cubit.prepareAfterAuthentication(
      user: const LoginUser(id: 7, phone: '0901234567'),
      loginName: '0901234567',
      isNewlyRegistered: true,
    );

    expect(needsSetup, isTrue);
    expect(cubit.state.mode, PasscodeMode.setup);
    expect(cubit.state.canSkip, isTrue);

    await cubit.submit('1234');

    expect(service.hasStoredPasscode, isTrue);
    expect(cubit.state.outcome?.type, PasscodeOutcomeType.sessionReady);
    expect(cubit.state.outcome?.isNewlyRegistered, isTrue);
    await cubit.close();
  });

  test(
    'owns PIN unlock and delegates authentication resume by outcome',
    () async {
      final service = _FakePasscodeService()
        ..hasStoredPasscode = true
        ..rememberedAccount = const PasscodeLoginAccount(
          userId: 8,
          loginName: 'learner@example.com',
        );
      final cubit = PasscodeCubit(passcodeService: service);

      expect(await cubit.openRememberedUnlock(), isTrue);
      expect(cubit.state.mode, PasscodeMode.unlock);

      await cubit.submit('1234');

      expect(
        cubit.state.outcome?.type,
        PasscodeOutcomeType.resumeAuthentication,
      );
      expect(cubit.state.outcome?.loginName, 'learner@example.com');
      await cubit.close();
    },
  );
}
