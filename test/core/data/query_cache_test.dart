import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/query_cache.dart';

void main() {
  group('SwrQueryCache', () {
    test(
      'dedupes a loading query and returns fresh cached data immediately',
      () async {
        var now = DateTime.utc(2026, 7, 11, 8);
        final cache = SwrQueryCache<String>(clock: () => now);
        final key = _key();
        final completer = Completer<String>();
        var requests = 0;

        Future<String> load() {
          requests++;
          return completer.future;
        }

        expect(cache.ensureFresh(key, load).isInitialLoading, isTrue);
        expect(cache.ensureFresh(key, load).isInitialLoading, isTrue);
        expect(requests, 1);

        completer.complete('cached dashboard');
        expect((await cache.waitFor(key)).data, 'cached dashboard');

        now = now.add(const Duration(seconds: 30));
        expect(cache.ensureFresh(key, load).data, 'cached dashboard');
        expect(requests, 1);

        cache.ensureFresh(key, () async {
          requests++;
          return 'forced dashboard';
        }, reason: CacheRefreshReason.pullToRefresh);
        expect((await cache.waitFor(key)).data, 'forced dashboard');
        expect(requests, 2);
        cache.dispose();
      },
    );

    test(
      'uses stale data while refreshing and preserves it after refresh failure',
      () async {
        var now = DateTime.utc(2026, 7, 11, 8);
        final cache = SwrQueryCache<String>(clock: () => now);
        final key = _key();

        cache.ensureFresh(key, () async => 'previous data');
        await cache.waitFor(key);
        now = now.add(const Duration(seconds: 61));

        final resource = cache.ensureFresh(
          key,
          () async => throw StateError('refresh failed'),
        );
        expect(resource.data, 'previous data');
        expect(resource.isRefreshing, isTrue);

        final failed = await cache.waitFor(key);
        expect(failed.phase, AsyncPhase.failure);
        expect(failed.data, 'previous data');
        expect(failed.hasData, isTrue);
        cache.dispose();
      },
    );

    test(
      'does not let an invalidated request overwrite the next generation',
      () async {
        final cache = SwrQueryCache<String>();
        final key = _key();
        final oldRequest = Completer<String>();
        final newRequest = Completer<String>();

        cache.ensureFresh(key, () => oldRequest.future);
        cache.invalidate(key);
        cache.ensureFresh(key, () => newRequest.future);

        oldRequest.complete('old response');
        newRequest.complete('new response');
        expect((await cache.waitFor(key)).data, 'new response');
        cache.dispose();
      },
    );
  });
}

QueryKey _key() {
  return QueryKey(
    feature: 'home',
    scope: const QueryScope(sessionEpoch: 1, userId: 7, profileId: 12),
    parameters: const <String, Object?>{'tab': 'overview'},
  );
}
