import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/app/startup_bootstrap.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/guest_account_store.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/session/data/passcode_service.dart';

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
  Future<List<StudentProfile>> listProfiles({
    required int userId,
    bool useGuestToken = false,
  }) async {
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

class _MemoryTokenStore implements AuthTokenStore {
  _MemoryTokenStore(this.value);

  String? value;

  @override
  Future<String?> readToken() async => value;

  @override
  Future<void> writeToken(String token) async {
    value = token;
  }

  @override
  Future<void> clearToken() async {
    value = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('restores the complete initial session before returning', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      GuestAccountStore.guestUidKey: '42',
      GuestAccountStore.guestUserKey: '{"uid":42}',
    });
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
    const storage = FlutterSecureStorage();
    expect(await storage.read(key: GuestAccountStore.guestUidKey), isNull);
    expect(await storage.read(key: GuestAccountStore.guestUserKey), isNull);
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

  test('does not restore a legacy guest as a signed-in user', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      GuestAccountStore.guestUidKey: '42',
      GuestAccountStore.guestUserKey: '{"uid":42}',
    });
    final authToken = _MemoryTokenStore('legacy-guest-jwt');
    final guestToken = _MemoryTokenStore(null);
    final profileService = _FakeProfileService(const <StudentProfile>[]);
    final services = AppServices(
      networkClient: NetworkClient(
        authTokenStore: authToken,
        guestTokenStore: guestToken,
      ),
      authService: _FakeAuthService(const LoginUser(id: 42, role: 'STUDENT')),
      profileService: profileService,
    );

    final result = await StartupBootstrap(services: services).run();

    expect(result.initialSession, isNull);
    expect(profileService.requestedUserId, isNull);
    expect(authToken.value, isNull);
    expect(guestToken.value, 'legacy-guest-jwt');
  });
}
