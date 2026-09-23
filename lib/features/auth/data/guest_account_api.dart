import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/debug/app_logger.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/auth/data/guest_account_store.dart';
import 'package:numi/features/auth/models/guest_account.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/models/profile.dart';

class GuestAccountApi implements GuestAccountService {
  GuestAccountApi({
    NetworkClient? networkClient,
    ProfileService? profileService,
    GuestAccountStore store = const GuestAccountStore(),
  }) : _networkClient = networkClient ?? NetworkClient.shared,
       _profileService =
           profileService ??
           ProfileApi(networkClient: networkClient ?? NetworkClient.shared),
       _store = store;

  final NetworkClient _networkClient;
  final ProfileService _profileService;
  final GuestAccountStore _store;
  GuestAccount? _current;
  Future<GuestAccount>? _pending;
  int _revision = 0;

  @override
  GuestAccount? get current => _current;

  @override
  Future<int?> readStoredUid() => _store.readUid();

  @override
  Future<GuestAccount> ensureGuest() {
    final current = _current;
    if (current != null) return Future<GuestAccount>.value(current);
    return _pending ??= _resolveAndReset();
  }

  Future<GuestAccount> _resolveAndReset() async {
    try {
      return await _loadOrCreate(_revision);
    } finally {
      _pending = null;
    }
  }

  Future<GuestAccount> _loadOrCreate(int revision) async {
    final storedUid = await _store.readUid();
    if (storedUid != null) {
      final response = await _networkClient.postJson(
        '/users/me',
        <String, dynamic>{'uid': storedUid},
        useGuestToken: true,
      );
      NetworkClient.throwForApiStatus(response);
      await _storeGuestTokenFromResponse(response);
      final guest = await _withProfiles(
        _accountFromResponse(response, fallbackUid: storedUid),
      );
      await _remember(guest, revision);
      return guest;
    }

    await _networkClient.clearGuestToken();
    final response = await _networkClient.postJson(
      '/users/create/guest',
      const <String, dynamic>{},
      useGuestToken: true,
    );
    NetworkClient.throwForApiStatus(response);
    await _storeGuestTokenFromResponse(response);
    final guest = await _withProfiles(_accountFromResponse(response));
    await _remember(guest, revision);
    return guest;
  }

  Future<GuestAccount> _withProfiles(GuestAccount user) async {
    final profiles = await _loadProfiles(user.uid);
    return GuestAccount(uid: user.uid, user: user.user, profiles: profiles);
  }

  Future<List<StudentProfile>> _loadProfiles(int uid) async {
    try {
      return await _profileService.listProfiles(
        userId: uid,
        useGuestToken: true,
      );
    } catch (error) {
      // Match login: a profile-list error must not prevent user resolution.
      AppLogger.warning('GUEST', 'Could not load guest profiles: $error');
      return const <StudentProfile>[];
    }
  }

  Future<void> _storeGuestTokenFromResponse(
    Map<String, dynamic> response,
  ) async {
    final data = _map(response['data']);
    final token =
        _nonEmptyString(response['access_token']) ??
        _nonEmptyString(data?['access_token']) ??
        _nonEmptyString(_map(response['user'])?['access_token']) ??
        _nonEmptyString(_map(data?['user'])?['access_token']);
    if (token != null) await _networkClient.writeGuestToken(token);
  }

  Future<void> _remember(GuestAccount guest, int revision) async {
    if (revision != _revision) {
      await _networkClient.clearGuestToken();
      throw StateError('Guest account was cleared during a pending request.');
    }
    await _store.writeUid(guest.uid);
    if (revision != _revision) {
      await _store.clear();
      await _networkClient.clearGuestToken();
      throw StateError('Guest account was cleared during a pending request.');
    }
    _current = guest;
  }

  @override
  Future<void> clear() async {
    _revision++;
    _current = null;
    await Future.wait([_store.clear(), _networkClient.clearGuestToken()]);
  }

  static GuestAccount _accountFromResponse(
    Map<String, dynamic> response, {
    int? fallbackUid,
  }) {
    final data = _map(response['data']);
    final user =
        _map(response['user']) ??
        _map(data?['user']) ??
        (data != null && _uidOf(data) != null ? data : null) ??
        (_uidOf(response) != null ? response : null);
    final uid = _uidOf(user) ?? _uidOf(data) ?? _uidOf(response) ?? fallbackUid;
    if (uid == null || user == null) {
      throw const FormatException('Guest API response has no user or uid.');
    }
    final userUid = _uidOf(user);
    if (fallbackUid != null && userUid != null && userUid != fallbackUid) {
      throw const FormatException('Guest API returned a different user.');
    }
    return GuestAccount(uid: uid, user: <String, dynamic>{...user, 'uid': uid});
  }

  static int? _uidOf(Map<String, dynamic>? value) {
    return GuestAccount.positiveInt(value?['uid']) ??
        GuestAccount.positiveInt(value?['user_id']) ??
        GuestAccount.positiveInt(value?['id']);
  }

  static Map<String, dynamic>? _map(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static String? _nonEmptyString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
