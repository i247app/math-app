import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart' as http_interceptor;
import 'package:math_ai_app/data/models/user/user_model.dart';

import '../responses/base/base_response.dart';
import '../responses/sign_up/sign_up_response.dart';
import '../responses/login/login_response.dart';
import '../responses/grades/grades_list_response.dart';
import '../responses/levels/levels_list_response.dart';
import '/config/config.dart';

import 'auth_interceptor.dart';
import 'common_metadata_interceptor.dart';
import 'http_code_interceptor.dart';
import 'network_log_interceptor.dart';

int _reqCounter = 0;
final client = http_interceptor.InterceptedHttp.build(
  interceptors: [
    HttpCodeInterceptor(),
    AuthInterceptor(),
    CommonMetadataInterceptor(),
    NetworkLogInterceptor(isLogRequestHeaders: false),
  ],
);

// POST helper function
Future<http.Response> _post(
  Uri uri,
  Object? body, {
  Map<String, String>? headers,
}) async {
  final xReqId = _reqCounter++;
  return client.post(
    uri,
    body: json.encode(body),
    headers: {
      'Content-Type': 'application/json',
      'X-Request-ID': xReqId.toString(),
      ...(headers ?? {}),
    },
  );
}

// PUT helper function
// Future<http.Response> _put(Uri uri, Object? body) async {
//   return client.put(
//     uri,
//     body: json.encode(body),
//     headers: {'Content-Type': 'application/json'},
//   );
// }

// GET helper function
Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) async {
  final xReqId = _reqCounter++;
  return client.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'X-Request-ID': xReqId.toString(),
      ...(headers ?? {}),
    },
  );
}

T _parseResponse<T extends BaseResponse>(
  http.Response response,
  T Function(Map<String, dynamic> json) fromJson,
) {
  T bo;
  try {
    bo = fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } catch (e) {
    bo = fromJson(jsonDecode('{}') as Map<String, dynamic>);
    debugPrint("Error parsing response json: $e");
  }
  bo.httpStatusCode = response.statusCode;
  bo.httpReasonPhrase = response.reasonPhrase ?? '';
  bo.httpHeaders = response.headers;
  return bo;
}

//
// API STARTS HERE
//
Future<SignUpResponse> signup({required User user}) async {
  final response = await _post(Uri.parse('$API_ROOT/users/create'), {
    "name": user.name,
    "email": user.email,
    "phone": user.phone,
    "password": user.password,
  });

  return _parseResponse(response, SignUpResponse.fromJson);
}

Future<LoginResponse> login({
  required String loginName,
  required String password,
}) async {
  final response = await _post(Uri.parse('$API_ROOT/login'), {
    "login_name": loginName,
    "password": password,
  });

  return _parseResponse(response, LoginResponse.fromJson);
}

Future<GradesListResponse> getGradesList() async {
  final response = await _get(Uri.parse('$API_ROOT/grades/list'));

  return _parseResponse(response, GradesListResponse.fromJson);
}

Future<LevelsListResponse> getLevelsList() async {
  final response = await _get(Uri.parse('$API_ROOT/levels/list'));

  return _parseResponse<LevelsListResponse>(
    response,
    LevelsListResponse.fromJson,
  );
}
