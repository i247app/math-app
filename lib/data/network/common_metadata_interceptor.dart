import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../config/constant.dart';
import '/data/providers/device_info_provider.dart';

class CommonMetadataInterceptor extends InterceptorContract {
  // Define the common metadata to include in all requests
  Future<Map<String, dynamic>> _getMetadata(BuildContext context) async {
    final deviceInfoState = context.read<DeviceInfoProvider>();
    final info = await PackageInfo.fromPlatform();
    return {
      '__metadata': {
        'device_id': deviceInfoState.deviceID ?? 'unknown',
        'device_name': deviceInfoState.modelName ?? 'unknown',
        'push_token': deviceInfoState.devicePushToken ?? 'unknown',
        'model_name': deviceInfoState.systemName ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': 'Version: ${info.version} + ${info.buildNumber}',
      },
    };
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (navigatorKey.currentContext == null) {
      if (kDebugMode) {
        debugPrint('CommonMetadataInterceptor: Navigator context is null');
      }
      return request;
    }

    final context = navigatorKey.currentContext!;

    const enabledResponseCompression = true;
    if (enabledResponseCompression && request is Request) {
      request.headers["Accept-Encoding"] = "gzip";
    }

    // Only modify requests with a JSON body (skip GET and non-JSON requests)
    try {
      if (request is Request && request.method != 'GET') {
        final contentType = request.headers['Content-Type']?.toLowerCase();
        if (contentType?.contains('application/json') ?? false) {
          // Decode existing body (if any)
          Map<String, dynamic> bodyJson = {};
          if (request.body.isNotEmpty) {
            try {
              bodyJson = jsonDecode(request.body) as Map<String, dynamic>;
            } catch (e) {
              if (kDebugMode) {
                debugPrint('CommonMetadataInterceptor: Failed to decode body: $e');
              }
              return request; // Skip if body is not valid JSON
            }
          }
          // Merge metadata
          final metadata = await _getMetadata(context);
          bodyJson.addAll(metadata);

          // Encode and update body
          request.body = jsonEncode(bodyJson);
          request.headers['Content-Type'] = 'application/json; charset=utf-8';
          if (kDebugMode) {
            debugPrint('CommonMetadataInterceptor: Added metadata: ${jsonEncode(metadata)}');
          }
        } else {
          if (kDebugMode) {
            debugPrint('CommonMetadataInterceptor: Skipping, Content-Type is not JSON');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('CommonMetadataInterceptor: Skipping, request is GET or not a Request');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CommonMetadataInterceptor: Error adding metadata: $e');
      }
    }

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // No response modifications needed
    return response;
  }
}
