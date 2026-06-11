import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';
import 'api_metadata.dart';
import 'auth_token_store.dart';

class NetworkLogInterceptor extends Interceptor {
  const NetworkLogInterceptor();

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
      'refreshtoken' =>
        true,
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

    return _jsonOrString(<String, Object?>{
      'fields': fields,
      'files': files,
    });
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

class DefaultHeadersInterceptor extends Interceptor {
  const DefaultHeadersInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(Headers.acceptHeader, () => 'application/json');

    if (options.data is! FormData) {
      options.headers.putIfAbsent(
        Headers.contentTypeHeader,
        () => Headers.jsonContentType,
      );
    }

    handler.next(options);
  }
}

class MetadataInterceptor extends QueuedInterceptor {
  MetadataInterceptor({required ApiMetadataProvider metadataProvider})
      : _metadataProvider = metadataProvider;

  final ApiMetadataProvider _metadataProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_shouldInjectMetadata(options)) {
      handler.next(options);
      return;
    }

    final metadata = await _metadataProvider.buildMetadata();
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

  static bool _shouldInjectMetadata(RequestOptions options) {
    if (options.extra['skipMetadata'] == true) {
      return false;
    }

    return switch (options.method.toUpperCase()) {
      'POST' || 'PUT' || 'PATCH' || 'DELETE' => true,
      _ => false,
    };
  }

  static void _injectJsonMetadata(
    RequestOptions options,
    Map<String, dynamic> data,
    Map<String, Object> metadata,
  ) {
    if (_hasKey(data, 'metadata')) {
      return;
    }

    options.data = <String, dynamic>{
      ...data,
      'metadata': metadata,
    };
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

class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor({required AuthTokenStore authTokenStore})
      : _authTokenStore = authTokenStore;

  static const _authTokenHeader = 'X-Auth-Token';
  static const _authorizationHeader = 'Authorization';

  final AuthTokenStore _authTokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_hasHeader(options.headers, _authorizationHeader)) {
      final token = (await _authTokenStore.readToken())?.trim();
      if (token != null && token.isNotEmpty) {
        options.headers[_authorizationHeader] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    await _storeTokenFromHeaders(response.headers);
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
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

      final firstValue = entry.value.isEmpty ? null : entry.value.first;
      final token = firstValue?.trim();
      if (token != null && token.isNotEmpty) {
        await _authTokenStore.writeToken(token);
      }
      return;
    }
  }

  static bool _hasHeader(Map<String, dynamic> headers, String name) {
    return headers.keys.any((key) => key.toLowerCase() == name.toLowerCase());
  }
}

class ClientInfoHeadersInterceptor extends QueuedInterceptor {
  ClientInfoHeadersInterceptor(
      {required AppApiMetadataProvider metadataProvider})
      : _metadataProvider = metadataProvider;

  final AppApiMetadataProvider _metadataProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final clientInfo = await _metadataProvider.loadClientInfo();
    if (clientInfo.deviceId.isNotEmpty) {
      options.headers['X-Device-Uuid'] = clientInfo.deviceId;
    }
    if (clientInfo.deviceName.isNotEmpty) {
      options.headers['X-Device-Name'] = Uri.encodeComponent(
        clientInfo.deviceName,
      );
    }
    if (clientInfo.devicePushToken.isNotEmpty) {
      options.headers['X-Device-Push-Token'] = clientInfo.devicePushToken;
    }
    options.headers['Accept-Language'] = AppLanguageState.currentApiCode;
    handler.next(options);
  }
}
