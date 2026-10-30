import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Lets the set owner cancel image downloads without affecting other assets.
class ExamImageFileService extends FileService {
  ExamImageFileService({required this.cacheKeyFor, Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final String Function(String url) cacheKeyFor;
  final Dio _client;
  final _requests = <String, Set<CancelToken>>{};

  void cancel(String key) {
    for (final token in _requests[key]?.toList() ?? <CancelToken>[]) {
      token.cancel('Question set released');
    }
  }

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final key = cacheKeyFor(url);
    final token = CancelToken();
    (_requests[key] ??= {}).add(token);
    void finish() {
      _requests[key]?.remove(token);
      if (_requests[key]?.isEmpty == true) _requests.remove(key);
    }

    try {
      final response = await _client.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          validateStatus: (_) => true,
        ),
        cancelToken: token,
      );
      // CacheManager does not consume bodies for 304 or HTTP errors.
      if (response.statusCode != 200 && response.statusCode != 202) {
        await response.data?.stream.listen((_) {}).cancel();
        finish();
      }
      return _ImageFileResponse(response, finish);
    } catch (_) {
      finish();
      rethrow;
    }
  }
}

class _ImageFileResponse implements FileServiceResponse {
  _ImageFileResponse(this.response, this.finish);
  final Response<ResponseBody> response;
  final void Function() finish;
  @override
  Stream<List<int>> get content async* {
    try {
      yield* response.data!.stream;
    } finally {
      finish();
    }
  }

  @override
  int? get contentLength =>
      int.tryParse(response.headers.value(Headers.contentLengthHeader) ?? '');
  @override
  int get statusCode => response.statusCode ?? 500;
  @override
  String? get eTag => response.headers.value('etag');
  @override
  DateTime get validTill {
    final control = response.headers.value('cache-control') ?? '';
    if (control.contains('no-cache')) return DateTime.now();
    final age = RegExp(r'max-age=(\d+)').firstMatch(control)?.group(1);
    return DateTime.now().add(
      Duration(seconds: int.tryParse(age ?? '') ?? 604800),
    );
  }

  @override
  String get fileExtension => switch (response.headers
      .value(Headers.contentTypeHeader)
      ?.split(';')
      .first) {
    'image/png' => '.png',
    'image/jpeg' => '.jpg',
    'image/webp' => '.webp',
    'image/gif' => '.gif',
    _ => '.img',
  };
}
