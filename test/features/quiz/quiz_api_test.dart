import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

void main() {
  test(
    'sends an empty grade label when assessment grade is not selected',
    () async {
      Object? requestBody;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requestBody = options.data;
              handler.resolve(_generatedQuizResponse(options));
            },
          ),
        );
      final api = QuizApi(
        networkApi: NetworkApi(
          networkClient: NetworkClient(
            baseUrl: 'https://example.test',
            dio: dio,
          ),
        ),
      );

      await api.generateAssessmentQuiz(gradeLabel: '   ');

      expect(requestBody, containsPair('grade_label', ''));
    },
  );

  test('sends the selected grade label after trimming it', () async {
    Object? requestBody;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestBody = options.data;
            handler.resolve(_generatedQuizResponse(options));
          },
        ),
      );
    final api = QuizApi(
      networkApi: NetworkApi(
        networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
      ),
    );

    await api.generateAssessmentQuiz(gradeLabel: '  Lớp 2  ');

    expect(requestBody, containsPair('grade_label', 'Lớp 2'));
  });
}

Response<Object?> _generatedQuizResponse(RequestOptions options) {
  return Response<Object?>(
    requestOptions: options,
    statusCode: 200,
    data: const <String, dynamic>{
      'mstatus': 200,
      'quiz': <String, dynamic>{
        'quiz_id': 1,
        'questions': <Map<String, dynamic>>[
          <String, dynamic>{
            'question_name': '1 + 1 = ?',
            'question_number': 1,
            'answers': <Map<String, dynamic>>[
              <String, dynamic>{'content': '2', 'label': 'A'},
            ],
          },
        ],
      },
    },
  );
}
