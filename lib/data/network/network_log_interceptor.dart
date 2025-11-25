import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class NetworkLogInterceptor extends InterceptorContract {
  late final bool isLogRequestHeaders;
  late final bool isLogResponseHeaders;

  NetworkLogInterceptor({
    this.isLogRequestHeaders = true,
    this.isLogResponseHeaders = true,
  });

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final requestId = DateTime.now().millisecondsSinceEpoch;
    final headersLog = request.headers.entries
        .map((e) => '>> Header: ${e.key}: ${e.value}')
        .join('\n');
    final requestLog = '''
>> OUT [$requestId]: ${request.method} ${request.url}
${isLogRequestHeaders ? headersLog : ''}
>> Body: ${request is http.Request ? request.body : 'N/A'}
''';
    log(requestLog);
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    final requestId = response.request?.headers['X-Request-ID'] ?? 'Unknown';
    final headersLog = response.headers.entries
        .map((e) => '<< Header: ${e.key}: ${e.value}')
        .join('\n');
    final responseLog = '''
<< IN [$requestId]: ${response.request?.method} ${response.request?.url}
${isLogResponseHeaders ? headersLog : ''}
<< Status: ${response.statusCode}
<< Body: ${response is http.Response ? response.body : 'N/A'}
''';
    log(responseLog);
    return response;
  }
}
