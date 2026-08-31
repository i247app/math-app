import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/data/mappers/quiz_mapper.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

void main() {
  test('quiz progress accepts a null average delta', () {
    final response = QuizProgressResponseDto.fromJson(<String, dynamic>{
      'from_dt': '2026-08-13T17:00:00.000Z',
      'limit': 10,
      'mstatus': 200,
      'profile_id': 153,
      'purpose': null,
      'series': <Map<String, dynamic>>[
        <String, dynamic>{
          'completed_dt': '2026-08-14T10:05:32.716344Z',
          'correct_number': 2,
          'purpose': 'ASSESSMENT',
          'quiz_id': 107,
          'score': 4,
          'score_pct': 40,
          'sequence': 1,
          'short_text': 'Grade 2 assessment',
          'title': 'Grade 2 - Level 1',
          'total_questions': 5,
          'type_of_quiz': 'GENERAL',
        },
        <String, dynamic>{
          'completed_dt': '2026-08-14T10:07:16.946980Z',
          'correct_number': 2,
          'purpose': 'ASSESSMENT',
          'quiz_id': 108,
          'score': 4,
          'score_pct': 40,
          'sequence': 2,
          'short_text': 'Grade 4 assessment',
          'title': 'Grade 4 - Level 2',
          'total_questions': 5,
          'type_of_quiz': 'GENERAL',
        },
      ],
      'status': 'Success',
      'summary': <String, dynamic>{
        'average_delta': null,
        'average_score': 4,
        'average_score_pct': 40,
        'count': 2,
        'highest_quiz_id': 108,
        'highest_score': 4,
        'highest_score_pct': 40,
        'lowest_score': 4,
        'trend': 'NEED_TO_TRY',
      },
      'to_dt': '2026-08-14T16:59:59.999999Z',
      'tz': '+07:00',
    }).toDomain();

    expect(response.series, hasLength(2));
    expect(response.summary?.averageDelta, isNull);
    expect(response.summary?.count, 2);
  });

  test('quiz progress posts the date range and parses analytics', () async {
    String? requestPath;
    Map<String, dynamic>? requestBody;
    final dio = Dio();
    final client = NetworkClient(
      baseUrl: 'https://example.test',
      dio: dio,
      metadataProvider: const _TestMetadataProvider(),
      authTokenStore: _TestAuthTokenStore(),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestPath = options.path;
          requestBody = Map<String, dynamic>.from(
            options.data as Map<String, dynamic>,
          );
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'from_dt': '2026-01-03T04:48:58.607719Z',
                'limit': 10,
                'mstatus': 200,
                'profile_id': 21,
                'series': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'completed_dt': '2026-07-28T06:15:28.136337Z',
                    'correct_number': 4,
                    'purpose': 'ASSESSMENT',
                    'quiz_id': 62,
                    'score': 8,
                    'score_pct': 80,
                    'sequence': 1,
                    'short_text': 'Multiplication and fractions',
                    'title': 'Grade 4 - Level 2',
                    'total_questions': 5,
                    'type_of_quiz': 'GENERAL',
                  },
                ],
                'status': 'Success',
                'summary': <String, dynamic>{
                  'average_delta': -1.8,
                  'average_score': 3.8,
                  'average_score_pct': 38,
                  'count': 10,
                  'highest_quiz_id': 62,
                  'highest_score': 8,
                  'highest_score_pct': 80,
                  'lowest_score': 2,
                  'trend': 'NEED_TO_TRY',
                },
                'to_dt': '2026-08-03T04:48:58.607719Z',
                'tz': '+07:00',
              },
            ),
          );
        },
      ),
    );
    final api = QuizApi(networkClient: client);

    final response = await api.getQuizProgress(
      profileId: 21,
      fromDt: DateTime.parse('2026-01-03T04:48:58.607719Z'),
      toDt: DateTime.parse('2026-08-03T04:48:58.607719Z'),
    );

    expect(requestPath, '/quizzes/analytics/progress');
    expect(requestBody, contains('metadata'));
    expect(requestBody, containsPair('profile_id', 21));
    expect(requestBody, containsPair('purpose', 'ASSESSMENT'));
    expect(requestBody, containsPair('from_dt', '2026-01-03T04:48:58.607719Z'));
    expect(requestBody, containsPair('to_dt', '2026-08-03T04:48:58.607719Z'));
    expect(response.series.single.quizId, 62);
    expect(response.series.single.score, 8);
    expect(response.summary?.averageDelta, -1.8);
    expect(response.summary?.trend, 'NEED_TO_TRY');
  });
}

class _TestMetadataProvider implements ApiMetadataProvider {
  const _TestMetadataProvider();

  @override
  Future<Map<String, Object>> buildMetadata() async {
    return <String, Object>{'device_uuid': 'test-device'};
  }
}

class _TestAuthTokenStore implements AuthTokenStore {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }
}
