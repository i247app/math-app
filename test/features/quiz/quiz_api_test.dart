import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/quiz/data/api/quiz_api.dart';

void main() {
  test('unpaginated quiz list omits page, size, and take_all', () async {
    Map<String, dynamic>? requestBody;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestBody = Map<String, dynamic>.from(
              options.data as Map<String, dynamic>,
            );
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{
                  'mstatus': 200,
                  'quizzes': <Map<String, dynamic>>[],
                },
              ),
            );
          },
        ),
      );
    final api = QuizApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await api.listQuizzes(profileId: 21);

    expect(requestBody, containsPair('profile_id', 21));
    expect(requestBody, containsPair('purpose', 'ASSESSMENT'));
    expect(requestBody, isNot(contains('page')));
    expect(requestBody, isNot(contains('size')));
    expect(requestBody, isNot(contains('take_all')));
  });

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
        networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
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
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await api.generateAssessmentQuiz(gradeLabel: '  Lớp 2  ');

    expect(requestBody, containsPair('grade_label', 'Lớp 2'));
  });

  test('sends both grade label and previous quiz id when provided', () async {
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
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await api.generateAssessmentQuiz(
      gradeLabel: '  Lớp 3  ',
      previousQuizId: 42,
    );

    expect(requestBody, containsPair('grade_label', 'Lớp 3'));
    expect(requestBody, containsPair('previous_quiz_id', 42));
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
