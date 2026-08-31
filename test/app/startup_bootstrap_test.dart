import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/app/startup_bootstrap.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/session/services/passcode_service.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService(this.user);

  final LoginUser? user;
  int restoreCalls = 0;

  @override
  Future<LoginUser?> restoreSession() async {
    restoreCalls++;
    return user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileService implements ProfileService {
  _FakeProfileService(this.profiles);

  final List<StudentProfile> profiles;
  int? requestedUserId;

  @override
  Future<List<StudentProfile>> listProfiles({required int userId}) async {
    requestedUserId = userId;
    return profiles;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePasscodeService implements PasscodeService {
  int? rememberedUserId;
  String? rememberedLoginName;

  @override
  Future<void> rememberLoginAccount({
    required int userId,
    required String loginName,
  }) async {
    rememberedUserId = userId;
    rememberedLoginName = loginName;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('restores the complete initial session before returning', () async {
    final authService = _FakeAuthService(
      const LoginUser(id: 7, phone: '0901234567'),
    );
    final profileService = _FakeProfileService(const <StudentProfile>[
      StudentProfile(
        profileId: 71,
        userId: 7,
        name: 'Learner',
        isDefault: true,
      ),
    ]);
    final passcodeService = _FakePasscodeService();
    final services = AppServices(
      authService: authService,
      profileService: profileService,
      passcodeService: passcodeService,
    );

    final result = await StartupBootstrap(
      services: services,
      passcodeService: passcodeService,
    ).run();

    expect(authService.restoreCalls, 1);
    expect(profileService.requestedUserId, 7);
    expect(result.initialSession?.user.id, 7);
    expect(result.initialSession?.activeProfile?.profileId, 71);
    expect(passcodeService.rememberedUserId, 7);
    expect(passcodeService.rememberedLoginName, '0901234567');
  });

  test('returns no initial session when no login can be restored', () async {
    final authService = _FakeAuthService(null);
    final profileService = _FakeProfileService(const <StudentProfile>[]);
    final passcodeService = _FakePasscodeService();
    final services = AppServices(
      authService: authService,
      profileService: profileService,
      passcodeService: passcodeService,
    );

    final result = await StartupBootstrap(
      services: services,
      passcodeService: passcodeService,
    ).run();

    expect(authService.restoreCalls, 1);
    expect(profileService.requestedUserId, isNull);
    expect(result.initialSession, isNull);
  });
}
