import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';

class HttpCodeInterceptor extends InterceptorContract {
  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    if (response is Response && response.body.isNotEmpty) {
      try {
        final bodyData = json.decode(response.body);
        if (bodyData['http_code'] == null) {
          bodyData['http_code'] = response.statusCode;
          return Response(
            json.encode(bodyData),
            response.statusCode,
            request: response.request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase,
          );
        }
      } catch (ex) {
        debugPrint('Failed to parser response body: ${ex.toString()}');
      }
    }
    return response;
  }

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    return request;
  }
}
