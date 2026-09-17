import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../localization/app_keys.dart';
import '../localization/app_strings.dart';
import 'api_metadata.dart';
import 'auth_token_store.dart';
import 'network_interceptors.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

class NetworkClient {
  static final NetworkClient shared = NetworkClient();

  NetworkClient({
    String? baseUrl,
    Dio? dio,
    AuthTokenStore? authTokenStore,
    ApiMetadataProvider? metadataProvider,
  }) : _baseUrl = _normalizeBaseUrl(baseUrl ?? ApiConfig.baseUrl),
       _dio = dio ?? Dio(),
       _authTokenStore = authTokenStore ?? CachedAuthTokenStore.instance,
       _metadataProvider = metadataProvider ?? AppApiMetadataProvider.instance {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 60)
      ..sendTimeout = const Duration(seconds: 15)
      ..responseType = ResponseType.json
      ..validateStatus = (_) => true;
    _dio.interceptors.add(
      MetadataInterceptor(
        metadataProvider: _metadataProvider,
        authTokenStore: _authTokenStore,
      ),
    );
    _dio.interceptors.add(
      AuthTokenResponseInterceptor(authTokenStore: _authTokenStore),
    );
    if (kDebugMode) {
      _dio.interceptors.add(DebugRequestMetricsInterceptor());
    }
    _dio.interceptors.add(const NetworkLogInterceptor());
  }

  final String _baseUrl;
  final Dio _dio;
  final AuthTokenStore _authTokenStore;
  final ApiMetadataProvider _metadataProvider;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Duration? receiveTimeout,
  }) async {
    if (_baseUrl.trim().isEmpty) {
      throw NetworkException(AppStrings.current(AppKeys.apiBaseUrlMissing));
    }

    final Response<Object?> response;
    try {
      response = await _dio.post<Object?>(
        path,
        data: Map<String, dynamic>.from(body),
        options: receiveTimeout == null
            ? null
            : Options(receiveTimeout: receiveTimeout),
      );
    } on DioException catch (error) {
      throw NetworkException(
        _dioErrorMessage(error),
        status: error.response?.statusCode,
      );
    }

    _throwForHttpStatus(response);
    return _jsonObjectFromResponse(response);
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    if (_baseUrl.trim().isEmpty) {
      throw NetworkException(AppStrings.current(AppKeys.apiBaseUrlMissing));
    }

    final Response<Object?> response;
    try {
      response = await _dio.get<Object?>(path, data: <String, dynamic>{});
    } on DioException catch (error) {
      throw NetworkException(
        _dioErrorMessage(error),
        status: error.response?.statusCode,
      );
    }

    _throwForHttpStatus(response);
    return _jsonObjectFromResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    FormData formData,
  ) async {
    if (_baseUrl.trim().isEmpty) {
      throw NetworkException(AppStrings.current(AppKeys.apiBaseUrlMissing));
    }

    final Response<Object?> response;
    try {
      response = await _dio.post<Object?>(
        path,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (error) {
      throw NetworkException(
        _dioErrorMessage(error),
        status: error.response?.statusCode,
      );
    }

    _throwForHttpStatus(response);
    return _jsonObjectFromResponse(response);
  }

  Future<void> clearAuthToken() => _authTokenStore.clearToken();

  Future<void> writeAuthToken(String token) {
    return _authTokenStore.writeToken(token);
  }

  Future<bool> hasAuthToken() async {
    final token = (await _authTokenStore.readToken())?.trim();
    return token != null && token.isNotEmpty;
  }

  static Map<String, dynamic> _jsonObjectFromResponse(
    Response<Object?> response,
  ) {
    final data = response.data;
    return switch (data) {
      final Map<String, dynamic> json => json,
      final Map<Object?, Object?> json => Map<String, dynamic>.from(json),
      _ => throw NetworkException(
        AppStrings.current(AppKeys.invalidServerResponse),
      ),
    };
  }

  static void _throwForHttpStatus(Response<Object?> response) {
    final statusCode = response.statusCode;
    if (statusCode == null || statusCode < 400) {
      return;
    }

    throw NetworkException(apiErrorMessage(response.data), status: statusCode);
  }

  static String _normalizeBaseUrl(String baseUrl) {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static void throwForApiStatus(Map<String, dynamic> json) {
    final status = json['mstatus'];
    if (status is int && status != 200) {
      throw NetworkException(apiErrorMessage(json), status: status);
    }
  }

  static String apiErrorMessage(Object? data) {
    if (data case final Map<String, dynamic> json) {
      for (final key in const ['mmessage', 'debug', 'status']) {
        final message = json[key];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    }

    if (data case final Map<Object?, Object?> json) {
      for (final key in const ['mmessage', 'debug', 'status']) {
        final message = json[key];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    }

    return AppStrings.current(AppKeys.invalidServerResponse);
  }

  static String _dioErrorMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError => AppStrings.current(
        AppKeys.checkInternetConnection,
      ),
      DioExceptionType.badCertificate => AppStrings.current(
        AppKeys.apiBadCertificate,
      ),
      DioExceptionType.cancel => AppStrings.current(AppKeys.apiRequestCanceled),
      DioExceptionType.badResponse || DioExceptionType.unknown =>
        error.response == null
            ? AppStrings.current(AppKeys.checkInternetConnection)
            : error.message ?? AppStrings.current(AppKeys.apiConnectionFailed),
    };
  }
}
