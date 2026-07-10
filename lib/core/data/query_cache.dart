import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:numi/core/data/app_failure.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/session_scoped_repository_registry.dart';

class QueryScope {
  const QueryScope({
    required this.sessionEpoch,
    required this.userId,
    this.profileId,
  });

  final int sessionEpoch;
  final int userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return other is QueryScope &&
        other.sessionEpoch == sessionEpoch &&
        other.userId == userId &&
        other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(sessionEpoch, userId, profileId);
}

class QueryKey {
  QueryKey({
    required this.feature,
    required this.scope,
    Map<String, Object?> parameters = const <String, Object?>{},
  }) : parameters = Map<String, Object?>.unmodifiable(parameters),
       _parameterSignature = _signatureFor(parameters);

  final String feature;
  final QueryScope scope;
  final Map<String, Object?> parameters;
  final String _parameterSignature;

  @override
  bool operator ==(Object other) {
    return other is QueryKey &&
        other.feature == feature &&
        other.scope == scope &&
        other._parameterSignature == _parameterSignature;
  }

  @override
  int get hashCode => Object.hash(feature, scope, _parameterSignature);

  static String _signatureFor(Map<String, Object?> parameters) {
    final keys = parameters.keys.toList()..sort();
    return keys.map((key) => '$key=${_valueFor(parameters[key])}').join('&');
  }

  static String _valueFor(Object? value) {
    if (value is Map<String, Object?>) {
      return '{${_signatureFor(value)}}';
    }
    if (value is Iterable<Object?>) {
      return '[${value.map(_valueFor).join(',')}]';
    }
    return '${value.runtimeType}:$value';
  }
}

enum CacheRefreshReason {
  initialLoad,
  tabReentry,
  appResume,
  pullToRefresh,
  mutation,
}

class CachePolicy {
  const CachePolicy({
    required this.staleAfter,
    this.evictAfter = const Duration(minutes: 30),
    this.maxEntries = 50,
  });

  final Duration staleAfter;
  final Duration evictAfter;
  final int maxEntries;

  static const dynamicList = CachePolicy(staleAfter: Duration(seconds: 60));
  static const detail = CachePolicy(staleAfter: Duration(minutes: 2));
  static const lookup = CachePolicy(staleAfter: Duration(minutes: 10));
  static const search = CachePolicy(
    staleAfter: Duration(seconds: 60),
    maxEntries: 20,
  );
}

/// In-memory stale-while-revalidate cache for a single feature/query type.
class SwrQueryCache<T> extends ChangeNotifier implements SessionScopedResource {
  SwrQueryCache({
    this.policy = CachePolicy.dynamicList,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CachePolicy policy;
  final DateTime Function() _clock;
  final Map<QueryKey, _CacheEntry<T>> _entries = <QueryKey, _CacheEntry<T>>{};

  AsyncResource<T>? read(QueryKey key) {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }
    entry.lastAccessedAt = _clock();
    return entry.resource;
  }

  /// Returns cached data immediately whenever possible and starts at most one
  /// matching request in the background.
  AsyncResource<T> ensureFresh(
    QueryKey key,
    Future<T> Function() loader, {
    CacheRefreshReason reason = CacheRefreshReason.initialLoad,
  }) {
    _evictUnusedEntries();
    final now = _clock();
    final entry = _entries.putIfAbsent(
      key,
      () => _CacheEntry<T>(
        resource: AsyncResource<T>.loading(),
        lastAccessedAt: now,
      ),
    );
    entry.lastAccessedAt = now;

    final isFresh =
        !entry.isInvalidated &&
        entry.resource.hasData &&
        entry.resource.updatedAt != null &&
        now.difference(entry.resource.updatedAt!) < policy.staleAfter;
    final forceRefresh = reason == CacheRefreshReason.pullToRefresh;
    if ((!forceRefresh && isFresh) || entry.pending != null) {
      return entry.resource;
    }

    entry.resource = entry.resource.hasData
        ? entry.resource.refreshing()
        : AsyncResource<T>.loading();
    entry.isInvalidated = false;
    _startRequest(key, entry, loader);
    notifyListeners();
    return entry.resource;
  }

  Future<AsyncResource<T>> waitFor(QueryKey key) async {
    final entry = _entries[key];
    if (entry == null) {
      throw StateError('No resource exists for the requested query key.');
    }
    await entry.pending;
    return entry.resource;
  }

  void invalidate(QueryKey key) {
    final entry = _entries[key];
    if (entry == null) {
      return;
    }
    entry.isInvalidated = true;
    entry.generation++;
    entry.pending = null;
    notifyListeners();
  }

  void evict(QueryKey key) {
    if (_entries.remove(key) != null) {
      notifyListeners();
    }
  }

  void _startRequest(
    QueryKey key,
    _CacheEntry<T> entry,
    Future<T> Function() loader,
  ) {
    final generation = entry.generation;
    entry.pending = _load(key, entry, generation, loader);
    unawaited(entry.pending!);
  }

  Future<void> _load(
    QueryKey key,
    _CacheEntry<T> entry,
    int generation,
    Future<T> Function() loader,
  ) async {
    try {
      final data = await Future<T>.sync(loader);
      if (!_canApply(key, entry, generation)) {
        return;
      }
      entry.resource = AsyncResource<T>.ready(data, updatedAt: _clock());
    } catch (error) {
      if (!_canApply(key, entry, generation)) {
        return;
      }
      entry.resource = AsyncResource<T>.failed(
        AppFailure.fromException(error),
        data: entry.resource.data,
        hasData: entry.resource.hasData,
      );
    } finally {
      if (_canApply(key, entry, generation)) {
        entry.pending = null;
        notifyListeners();
      }
    }
  }

  bool _canApply(QueryKey key, _CacheEntry<T> entry, int generation) {
    return identical(_entries[key], entry) && entry.generation == generation;
  }

  void _evictUnusedEntries() {
    final now = _clock();
    _entries.removeWhere(
      (_, entry) => now.difference(entry.lastAccessedAt) >= policy.evictAfter,
    );
    if (_entries.length <= policy.maxEntries) {
      return;
    }
    final oldest = _entries.entries.toList()
      ..sort(
        (a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt),
      );
    for (final entry in oldest.take(_entries.length - policy.maxEntries)) {
      _entries.remove(entry.key);
    }
  }

  @override
  void dispose() {
    _entries.clear();
    super.dispose();
  }
}

class _CacheEntry<T> {
  _CacheEntry({required this.resource, required this.lastAccessedAt});

  AsyncResource<T> resource;
  DateTime lastAccessedAt;
  Future<void>? pending;
  int generation = 0;
  bool isInvalidated = false;
}
