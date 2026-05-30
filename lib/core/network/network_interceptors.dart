import 'dart:convert';

import 'package:dio/dio.dart';

import '../localization/app_language.dart';
import 'api_metadata.dart';
import 'auth_token_store.dart';

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
