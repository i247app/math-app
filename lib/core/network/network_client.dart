import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import 'auth_models.dart';
import 'grade_models.dart';
import 'profile_models.dart';
import 'program_models.dart';
import 'quiz_models.dart';
import 'semester_models.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class AuthTokenStore {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<void> clearToken();
}

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}

class NetworkClient {
  NetworkClient({
    String? baseUrl,
    Dio? dio,
    AuthTokenStore? authTokenStore,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl ?? ApiConfig.baseUrl),
        _dio = dio ?? Dio(),
        _authTokenStore = authTokenStore ?? const SecureAuthTokenStore() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json
      ..validateStatus = (_) => true;
    _dio.interceptors.add(
      _AuthTokenInterceptor(authTokenStore: _authTokenStore),
    );
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
  final AuthTokenStore _authTokenStore;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Duration? receiveTimeout,
  }) async {
    if (_baseUrl.trim().isEmpty) {
      throw const NetworkException('Chưa cấu hình API_BASE_URL.');
    }

    final Response<Object?> response;
    try {
      response = await _dio.post<Object?>(
        path,
        data: body,
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
      throw const NetworkException('Chưa cấu hình API_BASE_URL.');
    }

    final Response<Object?> response;
    try {
      response = await _dio.get<Object?>(path);
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
      throw const NetworkException('Chưa cấu hình API_BASE_URL.');
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
      _ => throw const NetworkException('Response từ server không hợp lệ.'),
    };
  }

  static void _throwForHttpStatus(Response<Object?> response) {
    final statusCode = response.statusCode;
    if (statusCode == null || statusCode < 400) {
      return;
    }

    throw NetworkException(
      _responseErrorMessage(response.data),
      status: statusCode,
    );
  }

  static String _normalizeBaseUrl(String baseUrl) {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static String _responseErrorMessage(Object? data) {
    if (data case final Map<String, dynamic> json) {
      final message = json['mmessage'] ?? json['debug'] ?? json['status'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data case final Map<Object?, Object?> json) {
      final message = json['mmessage'] ?? json['debug'] ?? json['status'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return 'Request failed.';
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

class _AuthTokenInterceptor extends QueuedInterceptor {
  _AuthTokenInterceptor({required AuthTokenStore authTokenStore})
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

class NetworkApi {
  NetworkApi({
    String? baseUrl,
    NetworkClient? networkClient,
  }) : _networkClient = networkClient ??
            NetworkClient(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkClient _networkClient;

  Future<AuthResponse> signup(
    SignupRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'metadata': jsonEncode(_signupMetadata),
      'phone': request.phone,
      if (request.email?.isNotEmpty == true) 'email': request.email,
      if (request.name?.isNotEmpty == true) 'name': request.name,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final responseJson = await _networkClient.postMultipart(
      '/users/create',
      formData,
    );
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

  Future<AuthResponse> updateUser(
    UpdateUserRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': request.userId,
      if (request.name?.isNotEmpty == true) 'name': request.name,
      if (request.phone?.isNotEmpty == true) 'phone': request.phone,
      if (request.email?.isNotEmpty == true) 'email': request.email,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final responseJson = await _networkClient.postMultipart(
      '/users/update',
      formData,
    );
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

  Future<AuthResponse> authOtp(LoginRequest request) {
    return _post('/auth/otp', request.toJson());
  }

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final responseJson = await _networkClient.postJson(
      '/otps/send',
      request.toJson(),
    );
    final sendResponse = SendOtpResponse.fromJson(responseJson);
    if (sendResponse.mstatus != 200) {
      throw NetworkException(
        sendResponse.mmessage ??
            sendResponse.debug ??
            sendResponse.status ??
            'Request failed.',
        status: sendResponse.mstatus,
      );
    }

    return sendResponse;
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final responseJson = await _networkClient.postJson(
      '/otps/verify',
      request.toJson(),
    );
    final verifyResponse = VerifyOtpResponse.fromJson(responseJson);
    if (verifyResponse.mstatus != 200) {
      throw NetworkException(
        verifyResponse.mmessage ??
            verifyResponse.debug ??
            verifyResponse.status ??
            'Request failed.',
        status: verifyResponse.mstatus,
      );
    }

    return verifyResponse;
  }

  Future<GenerateQuizResponse> generateQuiz(
    GenerateQuizRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/quizzes/generate',
      request.toJson(),
      receiveTimeout: const Duration(seconds: 90),
    );
    final quizResponse = GenerateQuizResponse.fromJson(responseJson);
    if (quizResponse.mstatus != 200) {
      throw NetworkException(
        quizResponse.mmessage ??
            quizResponse.debug ??
            quizResponse.status ??
            'Request failed.',
        status: quizResponse.mstatus,
      );
    }

    return quizResponse;
  }

  Future<SubmitQuizResponse> submitQuiz(
    SubmitQuizRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/quizzes/submit',
      request.toJson(),
      receiveTimeout: const Duration(seconds: 90),
    );
    final quizResponse = SubmitQuizResponse.fromJson(responseJson);
    if (quizResponse.mstatus != 200) {
      throw NetworkException(
        quizResponse.mmessage ??
            quizResponse.debug ??
            quizResponse.status ??
            'Request failed.',
        status: quizResponse.mstatus,
      );
    }

    return quizResponse;
  }

  Future<QuizListResponse> listQuizzes(
    QuizListRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/quizzes/list',
      request.toJson(),
    );
    final quizResponse = QuizListResponse.fromJson(responseJson);
    if (quizResponse.mstatus != 200) {
      throw NetworkException(
        quizResponse.mmessage ??
            quizResponse.debug ??
            quizResponse.status ??
            'Request failed.',
        status: quizResponse.mstatus,
      );
    }

    return quizResponse;
  }

  Future<QuizDetailResponse> getQuizDetail(String quizId) async {
    final responseJson = await _networkClient.postJson(
      '/quizzes/$quizId',
      <String, dynamic>{},
    );
    final quizResponse = QuizDetailResponse.fromJson(responseJson);
    if (quizResponse.mstatus != 200) {
      throw NetworkException(
        quizResponse.mmessage ??
            quizResponse.debug ??
            quizResponse.status ??
            'Request failed.',
        status: quizResponse.mstatus,
      );
    }

    return quizResponse;
  }

  Future<GradeListResponse> listGrades(
    GradeListRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/grades/list',
      request.toJson(),
    );
    final gradeResponse = GradeListResponse.fromJson(responseJson);
    if (gradeResponse.mstatus != 200) {
      throw NetworkException(
        gradeResponse.mmessage ??
            gradeResponse.debug ??
            gradeResponse.status ??
            'Request failed.',
        status: gradeResponse.mstatus,
      );
    }

    return gradeResponse;
  }

  Future<ProfileListResponse> listProfiles(
    ProfileListRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/profiles/list',
      request.toJson(),
    );
    final profileResponse = ProfileListResponse.fromJson(responseJson);
    if (profileResponse.mstatus != 200) {
      throw NetworkException(
        profileResponse.mmessage ??
            profileResponse.debug ??
            profileResponse.status ??
            'Request failed.',
        status: profileResponse.mstatus,
      );
    }

    return profileResponse;
  }

  Future<ProgramListResponse> listPrograms(
    ProgramListRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/programs/list',
      request.toJson(),
    );
    final programResponse = ProgramListResponse.fromJson(responseJson);
    if (programResponse.mstatus != 200) {
      throw NetworkException(
        programResponse.mmessage ??
            programResponse.debug ??
            programResponse.status ??
            'Request failed.',
        status: programResponse.mstatus,
      );
    }

    return programResponse;
  }

  Future<SemesterListResponse> listSemesters(
    SemesterListRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/semesters/list',
      request.toJson(),
    );
    final semesterResponse = SemesterListResponse.fromJson(responseJson);
    if (semesterResponse.mstatus != 200) {
      throw NetworkException(
        semesterResponse.mmessage ??
            semesterResponse.debug ??
            semesterResponse.status ??
            'Request failed.',
        status: semesterResponse.mstatus,
      );
    }

    return semesterResponse;
  }

  Future<CreateProfileResponse> createProfile(
    CreateProfileRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': request.userId,
      'name': request.name,
      if (request.dob?.isNotEmpty == true) 'dob': request.dob,
      'grade_id': request.gradeId,
      'program_id': request.programId,
      'semester_id': request.semesterId,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final responseJson = await _networkClient.postMultipart(
      '/profiles/create',
      formData,
    );
    final createResponse = CreateProfileResponse.fromJson(responseJson);
    if (createResponse.mstatus != 200) {
      throw NetworkException(
        createResponse.mmessage ??
            createResponse.debug ??
            createResponse.status ??
            'Request failed.',
        status: createResponse.mstatus,
      );
    }

    return createResponse;
  }

  Future<UpdateProfileResponse> updateProfile(
    UpdateProfileRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'profile_id': request.profileId,
      'name': request.name,
      if (request.dob?.isNotEmpty == true) 'dob': request.dob,
      'grade_id': request.gradeId,
      'program_id': request.programId,
      'semester_id': request.semesterId,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final responseJson = await _networkClient.postMultipart(
      '/profiles/update',
      formData,
    );
    final updateResponse = UpdateProfileResponse.fromJson(responseJson);
    if (updateResponse.mstatus != 200) {
      throw NetworkException(
        updateResponse.mmessage ??
            updateResponse.debug ??
            updateResponse.status ??
            'Request failed.',
        status: updateResponse.mstatus,
      );
    }

    return updateResponse;
  }

  Future<DeleteProfileResponse> forceDeleteProfile(
    DeleteProfileRequest request,
  ) async {
    final responseJson = await _networkClient.postJson(
      '/profiles/force-delete',
      request.toJson(),
    );
    final deleteResponse = DeleteProfileResponse.fromJson(responseJson);
    if (deleteResponse.mstatus != 200) {
      throw NetworkException(
        deleteResponse.mmessage ??
            deleteResponse.debug ??
            deleteResponse.status ??
            'Request failed.',
        status: deleteResponse.mstatus,
      );
    }

    return deleteResponse;
  }

  Future<AuthUser> getCurrentUser() async {
    final responseJson = await _networkClient.postJson('/users/me', {});
    final userJson = _currentUserJson(responseJson);
    return AuthUser.fromJson(userJson);
  }

  Future<void> clearAuthToken() => _networkClient.clearAuthToken();

  Future<bool> hasAuthToken() => _networkClient.hasAuthToken();

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

  static Map<String, dynamic> _currentUserJson(Map<String, dynamic> json) {
    final mstatus = json['mstatus'];
    if (mstatus is int && mstatus != 200) {
      throw NetworkException(
        _apiErrorMessage(json),
        status: mstatus,
      );
    }

    final data = json['data'];
    final user = json['user'] ?? _nestedUser(data) ?? data;
    if (user case final Map<String, dynamic> userJson) {
      return userJson;
    }
    if (user case final Map<Object?, Object?> userJson) {
      return Map<String, dynamic>.from(userJson);
    }

    return json;
  }

  static Object? _nestedUser(Object? data) {
    if (data case final Map<String, dynamic> dataJson) {
      return dataJson['user'];
    }
    if (data case final Map<Object?, Object?> dataJson) {
      return dataJson['user'];
    }

    return null;
  }

  static String _apiErrorMessage(Map<String, dynamic> json) {
    final message = json['mmessage'] ?? json['debug'] ?? json['status'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return 'Request failed.';
  }
}

const _signupMetadata = <String, Object>{
  'client_info': <String, String>{
    'platform': 'ios',
    'app_version': '2.1.0',
    'device_id': '18092003-18092003-18092003-18092003',
    'device_name': 'MACBOOK-PRO-M4',
    'device_push_token': 'ABCDE',
    'ip_address': '42.118.191.193',
  },
};
