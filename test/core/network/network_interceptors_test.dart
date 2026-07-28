import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_interceptors.dart';

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String> logs;

  setUp(() {
    originalDebugPrint = debugPrint;
    logs = <String>[];
    debugPrint = (message, {wrapWidth}) {
      logs.add(message ?? 'null');
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('chunks a large response without losing UTF-8 data', () {
    final longValue = List<String>.filled(5000, 'đ').join();
    final responseData = <String, dynamic>{'value': longValue};
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/large-response'),
      statusCode: 200,
      data: responseData,
    );

    const NetworkLogInterceptor().onResponse(
      response,
      ResponseInterceptorHandler(),
    );

    final marker = RegExp(r'^\[chunk \d+/\d+\] ');
    final chunks = logs.where(marker.hasMatch).toList();

    expect(chunks.length, greaterThan(1));
    expect(
      chunks.map((chunk) => chunk.replaceFirst(marker, '')).join(),
      jsonEncode(responseData),
    );
    for (final chunk in chunks) {
      expect(utf8.encode(chunk).length, lessThan(900));
    }
  });
}
