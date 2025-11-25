import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:provider/provider.dart';

import '../../config/constant.dart';
import '/data/providers/auth_provider.dart';
import '/data/providers/device_info_provider.dart';
import '/data/services/local_storage_service.dart';
import '../responses/base/base_response.dart' as base_response;

void printLongJson(String text) {
  final pattern = RegExp('.{1,1000}');
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}

class AuthInterceptor extends InterceptorContract {
  final localStorageService = LocalStorageService();

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (navigatorKey.currentContext == null) {
      return request;
    }
    debugPrint('🌐 API Call: ${request.method} ${request.url}');
    debugPrint('📍 Headers: ${request.headers}');
    final authState = navigatorKey.currentContext!.read<AuthProvider>();
    final myAuthToken = authState.authToken;
    // final userProvider = navigatorKey.currentContext!.read<UserProvider>();
    // final language = userProvider.settingModel?.language ?? 'en';
    if ((myAuthToken ?? '').isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $myAuthToken';
    }
    final deviceInfoState = navigatorKey.currentContext!
        .read<DeviceInfoProvider>();
    if (deviceInfoState.deviceID?.isNotEmpty ?? false) {
      request.headers['X-Device-Uuid'] = deviceInfoState.deviceID!;
    }
    if (deviceInfoState.modelName?.isNotEmpty ?? false) {
      request.headers['X-Device-Name'] = Uri.encodeComponent(
        deviceInfoState.modelName!,
      );
    }
    if (deviceInfoState.devicePushToken?.isNotEmpty ?? false) {
      request.headers['X-Device-Push-Token'] = deviceInfoState.devicePushToken!;
    }
    //request.headers['Accept-Language'] = language;
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    if (navigatorKey.currentContext != null &&
        (response.headers['x-auth-token'] ?? '').isNotEmpty) {
      final authState = navigatorKey.currentContext!.read<AuthProvider>();
      debugPrint("X-Auth-Token: ${response.headers['x-auth-token']}");
      authState.authToken = response.headers['x-auth-token']!;
      localStorageService.setAuthToken(authState.authToken);
    }
    if (response is Response) {
      printLongJson(
        '🔔 Response from ${response.request?.url}: ${response.body}',
      );
    }

    // final shouldBounceOutLegacy = detectLegacyBounceOut(response);
    // final shouldBounceOutNew = detectNewBounceOut(response);
    // final isBlocked = detectBlocked(response);
    // final isReadOnly = detectReadOnly(response);

    // if (shouldBounceOutLegacy || shouldBounceOutNew || isBlocked) {
    //   if (navigatorKey.currentContext != null) {
    //     DialogHelper.dismissAllDialogs(navigatorKey.currentContext!);
    //   }
    //   await (AuthService.clearData(navigatorKey.currentContext!, isNotReturnOnBoarding: true));
    //   Future.microtask(() {
    //     DialogHelper.errorDialog(
    //       title: isBlocked ? 'You\'ve been blocked' : 'Invalid Session',
    //       subtitle:
    //           isBlocked || shouldBounceOutNew
    //               ? 'For security reasons, you\'ve been blocked. Please contact support for additional info.'
    //               : 'For security reasons, you have been logged out. Please log in again.',
    //       actionLabel: 'OK',
    //       fct: () async {
    //         Navigator.of(
    //           navigatorKey.currentContext!,
    //         ).pushNamedAndRemoveUntil(RoutesName.onBoarding, (route) => false);
    //       },
    //       context: navigatorKey.currentContext!,
    //     );
    //   });
    // }
    // if (navigatorKey.currentContext != null) {
    //   if (isReadOnly) {
    //     if (navigatorKey.currentContext != null) {
    //       DialogHelper.dismissAllDialogs(navigatorKey.currentContext!);
    //     }
    //     Future.microtask(() {
    //       navigatorKey.currentContext!.read<AuthProvider>().isReadOnly = true;
    //       final userProvider = navigatorKey.currentContext!.read<UserProvider>();
    //       userProvider.user?.userStatus = 'READ_ONLY';
    //       if (!GlobalVariable.isShowDialog) {
    //         DialogHelper.errorDialog(
    //           title: 'Account Issue',
    //           subtitle: 'Your account has been restricted. Please contact support for assistance.',
    //           actionLabel: 'OK',
    //           fct: () {
    //             GlobalVariable.isShowDialog = true;
    //             Navigator.of(
    //               navigatorKey.currentContext!,
    //             ).push(MaterialPageRoute(builder: (_) => BottomNavigation(currentIndex: 0)));
    //           },
    //           context: navigatorKey.currentContext!,
    //         );
    //       }
    //     });
    //   }
    // }
    // if (!shouldBounceOutLegacy &&
    //     !shouldBounceOutNew &&
    //     !isBlocked &&
    //     navigatorKey.currentContext != null) {
    //   GlobalVariable.isShowDialog = false;
    // }
    return response;
  }
}

bool detectLegacyBounceOut(BaseResponse response) {
  return (response is Response &&
      (response.statusCode == HttpStatus.methodNotAllowed ||
          response.statusCode == HttpStatus.unauthorized ||
          response.body.contains("gex panic") ||
          response.body.contains("user_id missing") ||
          response.body.contains("session user_id is 0") ||
          response.body.contains("session is not secure")));
}

bool detectReadOnly(BaseResponse response) {
  if (response is! Response) {
    return false;
  }
  final jsonResponse = base_response.BaseResponse.fromJson(
    jsonDecode(response.body),
  );

  if (jsonResponse.status == MStatusEnum.readOnly.value) {
    return true;
  }
  return false;
}

bool detectBlocked(BaseResponse response) {
  if (response is! Response) {
    return false;
  }
  final jsonResponse = base_response.BaseResponse.fromJson(
    jsonDecode(response.body),
  );
  if (jsonResponse.status == MStatusEnum.blocked.value) {
    return true;
  }
  return false;
}

bool detectNewBounceOut(BaseResponse response) {
  if (response is! Response) {
    return false;
  }
  final jsonResponse = base_response.BaseResponse.fromJson(
    jsonDecode(response.body),
  );

  if (jsonResponse.status == MStatusEnum.unauthorized.value) {
    return true;
  }

  return false;
}
