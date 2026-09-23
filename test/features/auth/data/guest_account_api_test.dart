import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/guest_account_api.dart';
import 'package:numi/features/auth/data/guest_account_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues(<String, String>{}));

  test('creates a guest and keeps its user object only in memory', () async {
    final requests = <RequestOptions>[];
    final api = _apiReturning((options) {
      requests.add(options);
      if (options.path == '/profiles/list') {
        return <String, dynamic>{
          'mstatus': 200,
          'profiles': <Map<String, dynamic>>[
            <String, dynamic>{'profile_id': 422, 'uid': 42, 'is_default': true},
          ],
        };
      }
      return <String, dynamic>{
        'mstatus': 200,
        'access_token': 'guest-body-jwt',
        'user': <String, dynamic>{
          'uid': 42,
          'profile_id': 421,
          'future_field': <String, dynamic>{'name': 'kept'},
        },
      };
    });

    final guest = await api.ensureGuest();
    final storage = const FlutterSecureStorage();

    expect(requests.map((request) => request.path), <String>[
      '/users/create/guest',
      '/profiles/list',
    ]);
    expect(requests.first.data, isEmpty);
    expect(requests.last.data, <String, dynamic>{'uid': 42});
    expect(
      requests.every((request) => request.extra['useGuestToken'] == true),
      isTrue,
    );
    expect(guest.uid, 42);
    expect(guest.profileId, 422);
    expect(await storage.read(key: GuestAccountStore.guestUidKey), '42');
    expect(await storage.read(key: 'guest_token'), 'guest-body-jwt');
    expect(await storage.read(key: 'auth_token'), isNull);
    expect(await storage.read(key: GuestAccountStore.guestUserKey), isNull);
    expect(guest.user['future_field'], <String, dynamic>{'name': 'kept'});
    expect(identical((await api.ensureGuest()).user, guest.user), isTrue);
    expect(requests, hasLength(2));
    await api.clear();
    expect(await storage.read(key: 'guest_token'), isNull);
  });

  test('restores a stored guest through users/me with uid', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      GuestAccountStore.guestUidKey: '42',
      GuestAccountStore.guestUserKey: jsonEncode(<String, dynamic>{'uid': 42}),
    });
    final requests = <RequestOptions>[];
    final api = _apiReturning((options) {
      requests.add(options);
      if (options.path == '/profiles/list') {
        return <String, dynamic>{
          'mstatus': 200,
          'profiles': <Map<String, dynamic>>[
            <String, dynamic>{'profile_id': 422, 'uid': 42, 'is_default': true},
          ],
        };
      }
      return <String, dynamic>{
        'mstatus': 200,
        'data': <String, dynamic>{
          'user': <String, dynamic>{'uid': 42, 'profile_id': 421},
        },
      };
    });

    final guest = await api.ensureGuest();

    expect(requests.map((request) => request.path), <String>[
      '/users/me',
      '/profiles/list',
    ]);
    expect(requests.first.data, <String, dynamic>{'uid': 42});
    expect(requests.last.data, <String, dynamic>{'uid': 42});
    expect(
      requests.every((request) => request.extra['useGuestToken'] == true),
      isTrue,
    );
    expect(guest.profileId, 422);
    final storage = const FlutterSecureStorage();
    expect(await storage.read(key: GuestAccountStore.guestUserKey), isNull);
    await api.clear();
    expect(await storage.read(key: GuestAccountStore.guestUidKey), isNull);
    expect(await storage.read(key: GuestAccountStore.guestUserKey), isNull);
    expect(api.current, isNull);
  });

  test('migrates a legacy guest_user into guest_uid and removes it', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      GuestAccountStore.guestUserKey: jsonEncode(<String, dynamic>{'uid': 42}),
    });
    final store = const GuestAccountStore();

    expect(await store.readUid(), 42);

    const storage = FlutterSecureStorage();
    expect(await storage.read(key: GuestAccountStore.guestUidKey), '42');
    expect(await storage.read(key: GuestAccountStore.guestUserKey), isNull);
  });
}

GuestAccountApi _apiReturning(
  Map<String, dynamic> Function(RequestOptions options) response,
) {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: response(options),
            ),
          );
        },
      ),
    );
  return GuestAccountApi(
    networkClient: NetworkClient(
      baseUrl: 'https://example.test',
      dio: dio,
      guestTokenStore: CachedAuthTokenStore(
        persistentStore: const SecureAuthTokenStore(tokenKey: 'guest_token'),
      ),
    ),
  );
}
