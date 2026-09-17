import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/data/exam_api.dart';

void main() {
  test('exam progress accepts a null average delta', () {
    final response = ExamProgressResponseDto.fromJson(<String, dynamic>{
      'from_dt': '2026-08-13T17:00:00.000Z',
      'limit': 10,
      'mstatus': 200,
      'profile_id': 153,
      'exam_type': 'ASSESSMENT',
      'series': <Map<String, dynamic>>[
        <String, dynamic>{
          'completed_dt': '2026-08-14T10:05:32.716344Z',
          'correct_number': 2,
          'exam_type': 'ASSESSMENT',
          'grade': 1,
          'level': 1,
          'user_ai_exam_id': 107,
          'score': 4,
          'score_pct': 40,
          'sequence': 1,
          'total_questions': 5,
        },
        <String, dynamic>{
          'completed_dt': '2026-08-14T10:07:16.946980Z',
          'correct_number': 2,
          'exam_type': 'ASSESSMENT',
          'grade': 1,
          'level': 2,
          'user_ai_exam_id': 108,
          'score': 4,
          'score_pct': 40,
          'sequence': 2,
          'total_questions': 5,
        },
      ],
      'status': 'Success',
      'summary': <String, dynamic>{
        'average_delta': null,
        'average_score': 4,
        'average_score_pct': 40,
        'count': 2,
        'highest_user_ai_exam_id': 108,
        'highest_score': 4,
        'highest_score_pct': 40,
        'lowest_score': 4,
        'trend': 'NEED_TO_TRY',
      },
      'to_dt': '2026-08-14T16:59:59.999999Z',
      'tz': '+07:00',
    }).toModel();

    expect(response.series, hasLength(2));
    expect(response.summary?.averageDelta, isNull);
    expect(response.summary?.count, 2);
  });

  test('stats progress sorts all records and filters dates inclusively', () {
    final rows = List.generate(
      12,
      (i) => <String, dynamic>{
        'user_exam_id': i + 1,
        'ended_dt': DateTime.utc(2026, 9, 12 - i).toIso8601String(),
        'correct_number': 2,
        'score_percentage': 40,
        'skipped_number': 0,
        'total_questions': 5,
        'grade': i % 6,
        'status': i == 0 ? 'CANCEL' : 'COMPLETE',
      },
    );
    final json = <String, dynamic>{
      'mstatus': 200,
      'stats': rows,
      'summary': {
        'average_delta': null,
        'average_score': 4,
        'average_score_pct': 40,
        'count': 12,
        'highest_score': 4,
        'highest_score_pct': 40,
        'lowest_score': 4,
        'highest_user_exam_id': 1,
        'trend': 'NEED_TO_TRY',
      },
    };
    final all = examStatsToProgress(
      json,
      fromDt: DateTime.utc(2026, 9),
      toDt: DateTime.utc(2026, 10),
      profileId: 2,
      examType: 'ASSESSMENT',
    );
    expect(all.series, hasLength(12));
    expect(all.series.first.examId, 12);
    expect(all.series.last.examId, 1);
    expect(all.series.last.sequence, 12);
    expect(all.summary?.highestExamId, 1);
    expect(all.summary?.averageDelta, isNull);
    final filtered = examStatsToProgress(
      json,
      fromDt: DateTime.utc(2026, 9, 3),
      toDt: DateTime.utc(2026, 9, 4),
      profileId: 2,
      examType: 'ASSESSMENT',
    );
    expect(filtered.series, hasLength(2));
    expect(filtered.series.first.sequence, 1);
    expect(filtered.summary, isNull);
  });

  test('exam progress uses stats and parses the new summary', () async {
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
                'stats': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'ended_dt': '2026-07-28T06:15:28.136337Z',
                    'correct_number': 4,
                    'exam_type': 'ASSESSMENT',
                    'grade': 1,
                    'level': 1,
                    'user_exam_id': 62,
                    'score': 8,
                    'score_percentage': 80,
                    'skipped_number': 0,
                    'sequence': 1,
                    'total_questions': 5,
                  },
                ],
                'status': 'Success',
                'summary': <String, dynamic>{
                  'average_delta': -1.8,
                  'average_score': 3.8,
                  'average_score_pct': 38,
                  'count': 10,
                  'highest_user_exam_id': 62,
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
    final api = ExamApi(networkClient: client);

    final response = await api.getExamProgress(
      profileId: 21,
      fromDt: DateTime.parse('2026-01-03T04:48:58.607719Z'),
      toDt: DateTime.parse('2026-08-03T04:48:58.607719Z'),
    );

    expect(requestPath, '/exams/stats');
    expect(requestBody, contains('metadata'));
    expect(requestBody, containsPair('profile_id', 21));
    expect(requestBody, containsPair('exam_type', 'ASSESSMENT'));
    expect(requestBody, isNot(contains('from_dt')));
    expect(requestBody, isNot(contains('to_dt')));
    expect(response.series.single.examId, 62);
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
