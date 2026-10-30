import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_image_file_service.dart';

void main() {
  test('exiting a set cancels its pending image request', () async {
    final dio = Dio()
      ..interceptors.add(InterceptorsWrapper(onRequest: (_, handler) {}));
    final service = ExamImageFileService(
      cacheKeyFor: (_) => 'asset-key',
      client: dio,
    );
    final request = service.get('https://example.test/image.png');
    final result = expectLater(
      request,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    service.cancel('asset-key');
    await result;
    dio.close(force: true);
  });

  for (final status in [200, 304, 403]) {
    test('releases request bookkeeping after HTTP $status', () async {
      late CancelToken token;
      var closed = false;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              token = options.cancelToken!;
              final body = StreamController<Uint8List>(
                onCancel: () => closed = true,
              );
              body.add(Uint8List.fromList([1, 2, 3]));
              unawaited(body.close());
              handler.resolve(
                Response<ResponseBody>(
                  requestOptions: options,
                  statusCode: status,
                  headers: Headers.fromMap({
                    'content-type': ['image/png'],
                    'content-length': ['3'],
                    'etag': ['v1'],
                  }),
                  data: ResponseBody(body.stream, status),
                ),
              );
            },
          ),
        );
      final service = ExamImageFileService(
        cacheKeyFor: (_) => 'asset-key',
        client: dio,
      );
      final response = await service.get('https://example.test/image.png');
      expect(response.statusCode, status);
      expect(response.fileExtension, '.png');
      if (status == 200) {
        expect(await response.content.expand((bytes) => bytes).toList(), [
          1,
          2,
          3,
        ]);
      }
      expect(closed, isTrue);
      service.cancel('asset-key');
      expect(token.isCancelled, isFalse);
      dio.close(force: true);
    });
  }
}
