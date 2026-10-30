import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import 'exam_image_file_service.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Pins decoded images while their set is active and removes released assets.
abstract final class ExamImageCache {
  static CacheManager? _manager;
  static final _fileService = ExamImageFileService(cacheKeyFor: keyFor);
  static final _assets = <String, _SetImageAsset>{};

  @visibleForTesting
  static BaseCacheManager? managerOverride;

  @visibleForTesting
  static ImageProvider Function(String url, int dimension)? providerOverride;

  static BaseCacheManager get _cacheManager =>
      managerOverride ??
      (_manager ??= CacheManager(
        Config(
          'exam-question-images-v1',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
          fileService: _fileService,
        ),
      ));

  static ImageProvider provider(String url) {
    final asset = _assets[keyFor(url)];
    return _provider(url, asset?.dimension ?? 768);
  }

  static bool isReady(String url) => _assets[keyFor(url)]?.ready ?? false;

  static ImageProvider _provider(String url, int dimension) =>
      providerOverride?.call(url, dimension) ??
      ResizeImage(
        CachedNetworkImageProvider(
          url,
          cacheKey: keyFor(url),
          cacheManager: _assets[keyFor(url)]?.manager ?? _cacheManager,
        ),
        width: dimension,
        height: dimension,
        policy: ResizeImagePolicy.fit,
      );

  static void retain(String url, int maxDimension) {
    final key = keyFor(url);
    final asset = _assets.putIfAbsent(
      key,
      () => _SetImageAsset(url, maxDimension, _cacheManager),
    );
    asset.url = url;
    asset.owners++;
  }

  static Future<void> prepare(String url, BuildContext context) async {
    final configuration = createLocalImageConfiguration(context);
    final asset = _assets[keyFor(url)];
    if (asset == null) return;
    await asset.cleaning;
    if (asset.owners == 0 || asset.ready || !context.mounted) return;
    if (asset.settled) {
      await _provider(asset.url, asset.dimension).evict();
      asset.loading = null;
    }
    if (asset.loading != null) return asset.loading!;
    final done = Completer<void>();
    asset.loading = done.future;
    asset.settled = false;
    final stream = _provider(asset.url, asset.dimension).resolve(configuration);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (image, synchronousCall) {
        image.dispose();
        asset.ready = true;
        asset.settled = true;
        if (!done.isCompleted) done.complete();
      },
      onError: (Object error, StackTrace? stackTrace) {
        asset.settled = true;
        stream.removeListener(listener);
        asset.stream = null;
        asset.listener = null;
        if (!done.isCompleted) done.completeError(error, stackTrace);
      },
    );
    asset.stream = stream;
    asset.listener = listener;
    stream.addListener(listener);
    return done.future;
  }

  static Future<void> release(String url) async {
    final key = keyFor(url);
    final asset = _assets[key];
    if (asset == null || asset.owners == 0) return;
    asset.owners--;
    if (asset.owners != 0) return;
    final cleaning = _clear(key, asset);
    asset.cleaning = cleaning;
    try {
      await cleaning;
    } finally {
      if (identical(asset.cleaning, cleaning)) asset.cleaning = null;
    }
  }

  static Future<void> _clear(String key, _SetImageAsset asset) async {
    _fileService.cancel(key);
    // Late requests must settle before deletion, so they cannot refill old files.
    try {
      await asset.loading;
    } catch (_) {}
    if (asset.owners != 0) return;
    if (asset.listener case final listener?) {
      asset.stream?.removeListener(listener);
    }
    asset.stream = null;
    asset.listener = null;
    await _provider(asset.url, asset.dimension).evict();
    if (asset.owners != 0) {
      asset.loading = null;
      asset.ready = false;
      return;
    }
    try {
      await asset.manager.removeFile(key);
    } finally {
      asset.loading = null;
      asset.ready = false;
      asset.settled = false;
      if (asset.owners == 0 && identical(_assets[key], asset)) {
        _assets.remove(key);
      }
    }
  }

  static String keyFor(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !RegExp(r'(^|\.)s3(?:[.-][a-z0-9-]+)?\.amazonaws\.com$')
            .hasMatch(uri.host) ||
        !uri.queryParameters.containsKey('X-Amz-Signature')) {
      return url;
    }
    const signingParameters = {
      'x-amz-algorithm',
      'x-amz-credential',
      'x-amz-date',
      'x-amz-expires',
      'x-amz-signedheaders',
      'x-amz-signature',
      'x-amz-security-token',
    };
    final keys = uri.queryParametersAll.keys.toList()..sort();
    final retained = <String, List<String>>{
      for (final key in keys)
        if (!signingParameters.contains(key.toLowerCase()) &&
            !(key == 'x-id' && uri.queryParameters[key] == 'GetObject'))
          key: uri.queryParametersAll[key]!,
    };
    final query = retained.isEmpty
        ? ''
        : '?${Uri(queryParameters: retained).query}';
    return '${uri.origin}${uri.path}$query';
  }
}

class _SetImageAsset {
  _SetImageAsset(this.url, this.dimension, this.manager);
  String url;
  final int dimension;
  final BaseCacheManager manager;
  int owners = 0;
  bool ready = false;
  bool settled = false;
  Future<void>? loading;
  Future<void>? cleaning;
  ImageStream? stream;
  ImageStreamListener? listener;
}
