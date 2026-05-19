import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'auth_models.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

class NetworkClient {
  NetworkClient({
    String? baseUrl,
    Dio? dio,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl ?? ApiConfig.baseUrl),
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json
      ..validateStatus = (_) => true;
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
  }

  final String _baseUrl;
  final Dio _dio;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (_baseUrl.trim().isEmpty) {
      throw const NetworkException('Chưa cấu hình API_BASE_URL.');
    }

    final Response<Object?> response;
    try {
      response = await _dio.post<Object?>(path, data: body);
    } on DioException catch (error) {
      throw NetworkException(_dioErrorMessage(error));
    }

    final data = response.data;
    return switch (data) {
      final Map<String, dynamic> json => json,
      final Map<Object?, Object?> json => Map<String, dynamic>.from(json),
      _ => throw const NetworkException('Response từ server không hợp lệ.'),
    };
  }

  static String _normalizeBaseUrl(String baseUrl) {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static String _dioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối API quá thời gian chờ.';
      case DioExceptionType.receiveTimeout:
        return 'API phản hồi quá thời gian chờ.';
      case DioExceptionType.connectionError:
        return 'Không kết nối được API: ${error.message}';
      case DioExceptionType.badCertificate:
        return 'Chứng chỉ API không hợp lệ.';
      case DioExceptionType.cancel:
        return 'Request đã bị hủy.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return error.message ?? 'Không kết nối được API.';
    }
  }
}

class NetworkApi {
  NetworkApi({
    String? baseUrl,
    NetworkClient? networkClient,
  }) : _networkClient = networkClient ??
            NetworkClient(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkClient _networkClient;

  Future<AuthResponse> signup(SignupRequest request) {
    return _post('/users/create', request.toJson());
  }

  Future<AuthResponse> login(LoginRequest request) {
    return _post('/auth', request.toJson());
  }

  Future<AuthResponse> authOtp(LoginRequest request) {
    return _post('/auth/otp', request.toJson());
  }

  Future<AuthResponse> _post(String path, Map<String, dynamic> body) async {
    final responseJson = await _networkClient.postJson(path, body);
    final authResponse = AuthResponse.fromJson(responseJson);
    if (authResponse.mstatus != 200) {
      throw NetworkException(
        authResponse.mmessage ??
            authResponse.debug ??
            authResponse.status ??
            'Request failed.',
        status: authResponse.mstatus,
      );
    }

    return authResponse;
  }
}
