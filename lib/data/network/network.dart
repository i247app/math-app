import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart' as http_interceptor;
import 'package:math_ai_app/data/models/user/user_model.dart';

import '../responses/base/base_response.dart';
import '../responses/contact/list_contact_response.dart';
import '../responses/sign_up/sign_up_response.dart';
import '../responses/login/login_response.dart';
import '../responses/grades/grades_list_response.dart';
import '../responses/levels/levels_list_response.dart';
import '../responses/profile/profile_create_response.dart';
import '../responses/profile/profile_fetch_response.dart';
import '../models/profile/update_profile_request.dart';
import '../responses/update_profile/update_profile_response.dart';
import '../responses/quiz/generate_quiz_response.dart';
import '../responses/quiz/submit_quiz_response.dart';
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
  }
  bo.httpStatusCode = response.statusCode;
  bo.httpReasonPhrase = response.reasonPhrase ?? '';
  bo.httpHeaders = response.headers;
  return bo;
}

Future<SignUpResponse> signup({required User user}) async {
  final response = await _post(Uri.parse('$API_ROOT/users/create'), {
    "name": user.name,
    "email": user.email,
    "phone": user.phone,
    "password": user.password,
  });

  return _parseResponse(response, SignUpResponse.fromJson);
}

Future<SignUpResponse> signupWithFormData({
  required String name,
  required String phone,
  required String password,
  required String birthDate,
  required String gradeId,
  required String semesterId,
  required String? avatarPath,
}) async {
  final xReqId = _reqCounter++;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$API_ROOT/users/create'),
  );

  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'X-Request-ID': xReqId.toString(),
  });

  request.fields['name'] = name;
  request.fields['phone'] = phone;
  request.fields['password'] = password;
  request.fields['dob'] = birthDate;
  request.fields['grade_id'] = gradeId;
  request.fields['semester_id'] = semesterId;

  if (avatarPath != null && avatarPath.isNotEmpty) {
    try {
      final file = await http.MultipartFile.fromPath('avatar', avatarPath);
      request.files.add(file);
    } catch (e) {
      rethrow;
    }
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

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
  final response = await _get(Uri.parse('$API_ROOT/semesters/list'));

  return _parseResponse<LevelsListResponse>(
    response,
    LevelsListResponse.fromJson,
  );
}

Future<ProfileCreateResponse> createProfile({
  required String uid,
  required String gradeId,
  required String semesterId,
}) async {
  final response = await _post(Uri.parse('$API_ROOT/profiles/create'), {
    "uid": uid,
    "grade_id": gradeId,
    "semester_id": semesterId,
  });

  return _parseResponse(response, ProfileCreateResponse.fromJson);
}

Future<ProfileFetchResponse> fetchProfile(String uid) async {
  final response = await _post(Uri.parse('$API_ROOT/profiles/fetch'), {
    "uid": uid,
  });
  return _parseResponse(response, ProfileFetchResponse.fromJson);
}

Future<UpdateProfileResponse> updateProfile(
  UpdateProfileRequest request,
) async {
  final response = await _post(
    Uri.parse('$API_ROOT/profiles/update'),
    request.toJson(),
  );
  return _parseResponse(response, UpdateProfileResponse.fromJson);
}

Future<GenerateQuizResponse> generateQuiz(String uid) async {
  final response = await _post(Uri.parse('$API_ROOT/quiz-practices/generate'), {
    "uid": uid,
  });
  return _parseResponse(response, GenerateQuizResponse.fromJson);
}

Future<GenerateQuizResponse> generatePractice(String uid) async {
  final response = await _post(
    Uri.parse('$API_ROOT/quiz-practices/reinforce'),
    {"uid": uid},
  );
  return _parseResponse(response, GenerateQuizResponse.fromJson);
}

Future<SubmitQuizResponse> submitQuiz(
  String uid,
  List<Map<String, dynamic>> answers,
) async {
  final response = await _post(Uri.parse('$API_ROOT/quiz-practices/submit'), {
    "uid": uid,
    "answers": answers,
  });
  return _parseResponse(response, SubmitQuizResponse.fromJson);
}

Future<UpdateProfileResponse> updateProfileWithFormData({
  required String uid,
  String? gradeId,
  String? semesterId,
  String? avatarPath,
}) async {
  final xReqId = _reqCounter++;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$API_ROOT/users/update'),
  );

  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'X-Request-ID': xReqId.toString(),
  });

  request.fields['uid'] = uid;
  if (gradeId != null) {
    request.fields['grade_id'] = gradeId;
  }
  if (semesterId != null) {
    request.fields['semester_id'] = semesterId;
  }

  if (avatarPath != null && avatarPath.isNotEmpty) {
    try {
      final file = await http.MultipartFile.fromPath('avatar', avatarPath);
      request.files.add(file);
    } catch (e) {
      rethrow;
    }
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return _parseResponse(response, UpdateProfileResponse.fromJson);
}

Future<BaseResponse> submitContactForm({
  required String contactEmail,
  required String contactName,
  required String contactPhone,
  required String contactMessage,
}) async {
  final response = await _post(Uri.parse('$API_ROOT/contact/submit'), {
    "contact_email": contactEmail,
    "contact_name": contactName,
    "contact_phone": contactPhone,
    "contact_message": contactMessage,
  });

  return _parseResponse(response, BaseResponse.fromJson);
}

Future<ListContactResponse> getContactsList({
  int page = 1,
  int size = 10,
}) async {
  final response = await _get(
    Uri.parse('$API_ROOT/contact?page=$page&size=$size'),
  );

  return _parseResponse(response, ListContactResponse.fromJson);
}
