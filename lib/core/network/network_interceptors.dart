import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../debug/debug_request_metrics.dart';
import 'api_metadata.dart';
import 'auth_token_store.dart';

class DebugRequestMetricsInterceptor extends Interceptor {
  DebugRequestMetricsInterceptor({DebugRequestMetrics? metrics})
    : _metrics = metrics ?? DebugRequestMetrics.instance;

  static const _requestNumberKey = 'debugRequestNumber';
  static const _startedAtKey = 'debugRequestStartedAt';

  final DebugRequestMetrics _metrics;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestNumber = _metrics.recordStarted(
      method: options.method,
      path: options.uri.path,
    );
    options.extra[_requestNumberKey] = requestNumber;
    options.extra[_startedAtKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _recordResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _record(
      options: err.requestOptions,
      statusCode: err.response?.statusCode,
      failed: true,
    );
    handler.next(err);
  }

  void _recordResponse(Response<dynamic> response) {
    final statusCode = response.statusCode;
    _record(
      options: response.requestOptions,
      statusCode: statusCode,
      failed: statusCode == null || statusCode >= 400,
    );
  }

  void _record({
    required RequestOptions options,
    required int? statusCode,
    required bool failed,
  }) {
    final requestNumber = options.extra[_requestNumberKey];
    final startedAt = options.extra[_startedAtKey];
    if (requestNumber is! int || startedAt is! DateTime) {
      return;
    }

    _metrics.recordCompleted(
      requestNumber: requestNumber,
      method: options.method,
      path: options.uri.path,
      elapsed: DateTime.now().difference(startedAt),
      statusCode: statusCode,
      failed: failed,
    );
  }
}

class NetworkLogInterceptor extends Interceptor {
  const NetworkLogInterceptor();

  // Temporary diagnostic switch. Set this back to false after verifying the
  // JWT copied into request metadata.
  static const _showSensitiveValuesInDebugLogs = true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('*** Request ***');
    _log('uri: ${options.uri}');
    _log('method: ${options.method}');
    if (options.headers.isNotEmpty) {
      _log('headers: ${_formatHeaders(options.headers)}');
    }
    _log('data:');
    _log(_formatData(options.data));
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log('*** Response ***');
    _log('uri: ${response.requestOptions.uri}');
    _log('statusCode: ${response.statusCode}');
    _log('Response Text:');
    _log(_formatData(response.data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('*** DioException ***');
    _log('uri: ${err.requestOptions.uri}');
    _log('type: ${err.type}');
    _log('message: ${err.message}');
    final response = err.response;
    if (response != null) {
      _log('statusCode: ${response.statusCode}');
      _log('Response Text:');
      _log(_formatData(response.data));
    }
    handler.next(err);
  }

  static String _formatHeaders(Map<String, dynamic> headers) {
    if (kDebugMode && _showSensitiveValuesInDebugLogs) {
      return _jsonOrString(headers);
    }

    final redacted = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key;
      final lowerKey = key.toLowerCase();
      redacted[key] = lowerKey == 'authorization' || lowerKey == 'x-auth-token'
          ? '<redacted>'
          : entry.value;
    }
    return _jsonOrString(redacted);
  }

  static String _formatData(Object? data) {
    if (data == null) {
      return 'null';
    }

    if (data is FormData) {
      return _formatFormData(data);
    }

    if (kDebugMode && _showSensitiveValuesInDebugLogs) {
      return _jsonOrString(data);
    }

    return _jsonOrString(_redactSensitiveData(data));
  }

  static Object? _redactSensitiveData(Object? value) {
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _isSensitiveKey(entry.key.toString())
              ? '<redacted>'
              : _redactSensitiveData(entry.value),
      };
    }

    if (value is List) {
      return value.map(_redactSensitiveData).toList();
    }

    return value;
  }

  static bool _isSensitiveKey(String key) {
    return switch (key.toLowerCase()) {
      'authorization' ||
      'x-auth-token' ||
      'access_token' ||
      'accesstoken' ||
      'refresh_token' ||
      'refreshtoken' => true,
      _ => false,
    };
  }

  static String _formatFormData(FormData formData) {
    final fields = <String, Object?>{};
    for (final field in formData.fields) {
      final existing = fields[field.key];
      if (existing == null) {
        fields[field.key] = field.value;
      } else if (existing is List<Object?>) {
        existing.add(field.value);
      } else {
        fields[field.key] = <Object?>[existing, field.value];
      }
    }

    final files = formData.files.map((entry) {
      final file = entry.value;
      return <String, Object?>{
        'field': entry.key,
        'filename': file.filename,
        'length': file.length,
        if (file.contentType != null) 'content_type': '${file.contentType}',
      };
    }).toList();

    return _jsonOrString(<String, Object?>{'fields': fields, 'files': files});
  }

  static String _jsonOrString(Object? value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  static void _log(String message) => debugPrint(message);
}

class MetadataInterceptor extends QueuedInterceptor {
  MetadataInterceptor({
    required ApiMetadataProvider metadataProvider,
    required AuthTokenStore authTokenStore,
  }) : _metadataProvider = metadataProvider,
       _authTokenStore = authTokenStore;

  final ApiMetadataProvider _metadataProvider;
  final AuthTokenStore _authTokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipMetadata'] == true) {
      handler.next(options);
      return;
    }

    final metadata = await _metadataProvider.buildMetadata();
    metadata['authorization'] = await _authorizationValue();
    metadata['content_type'] = _contentType(options.data);
    final data = options.data;
    if (data is FormData) {
      _injectMultipartMetadata(data, metadata);
    } else if (data is Map<String, dynamic>) {
      _injectJsonMetadata(options, data, metadata);
    } else if (data is Map<Object?, Object?>) {
      _injectJsonMetadata(options, Map<String, dynamic>.from(data), metadata);
    } else if (data == null) {
      options.data = <String, dynamic>{'metadata': metadata};
    }

    handler.next(options);
  }

  Future<String> _authorizationValue() async {
    final token = (await _authTokenStore.readToken())?.trim();
    return token == null || token.isEmpty ? '' : 'Bearer $token';
  }

  static String _contentType(Object? data) {
    return data is FormData ? 'multipart/form-data' : Headers.jsonContentType;
  }

  static void _injectJsonMetadata(
    RequestOptions options,
    Map<String, dynamic> data,
    Map<String, Object> metadata,
  ) {
    if (_hasKey(data, 'metadata')) {
      return;
    }

    options.data = <String, dynamic>{...data, 'metadata': metadata};
  }

  static void _injectMultipartMetadata(
    FormData formData,
    Map<String, Object> metadata,
  ) {
    if (formData.fields.any((field) => field.key == 'metadata')) {
      return;
    }

    formData.fields.add(MapEntry('metadata', jsonEncode(metadata)));
  }

  static bool _hasKey(Map<String, dynamic> data, String key) {
    return data.keys.any((entry) => entry.toLowerCase() == key.toLowerCase());
  }
}

/// Persists refreshed JWTs returned by the backend without adding any
/// authentication request header. Request authentication lives in body
/// metadata via [MetadataInterceptor].
class AuthTokenResponseInterceptor extends QueuedInterceptor {
  AuthTokenResponseInterceptor({required AuthTokenStore authTokenStore})
    : _authTokenStore = authTokenStore;

  static const _authTokenHeader = 'X-Auth-Token';

  final AuthTokenStore _authTokenStore;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    await _storeTokenFromHeaders(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null) {
      await _storeTokenFromHeaders(response.headers);
    }
    handler.next(err);
  }

  Future<void> _storeTokenFromHeaders(Headers headers) async {
    for (final entry in headers.map.entries) {
      if (entry.key.toLowerCase() != _authTokenHeader.toLowerCase()) {
        continue;
      }

      final token = entry.value.isEmpty ? null : entry.value.first.trim();
      if (token != null && token.isNotEmpty) {
        await _authTokenStore.writeToken(token);
      }
      return;
    }
  }
}
