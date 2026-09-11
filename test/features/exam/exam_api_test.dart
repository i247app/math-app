import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/exam/data/exam_api.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  test('lists exams with the new endpoint and request fields', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'mstatus': 200,
        'exams': <Map<String, dynamic>>[],
      };
    });

    await api.listExams(profileId: 21);

    final body = _body(captured);
    expect(captured.path, '/exams/list');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('exam_type', 'ASSESSMENT'));
    expect(body, isNot(contains('purpose')));
    expect(body, isNot(contains('page')));
    expect(body, isNot(contains('size')));
    expect(body, isNot(contains('take_all')));
  });

  test('generates an exam with the new form and maps its identity', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    final exam = await api.generateAssessmentExam(
      profileId: 21,
      gradeLabel: '  Lớp 2  ',
    );

    final body = _body(captured);
    expect(captured.path, '/exams/generate');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('num_questions', 10));
    expect(body, containsPair('exam_type', 'ASSESSMENT'));
    expect(body, containsPair('grade', 2));
    expect(body, containsPair('level', 1));
    expect(body, isNot(contains('grade_label')));
    expect(body, isNot(contains('purpose')));
    expect(body, isNot(contains('type_of_exam')));
    expect(body, isNot(contains('previous_exam_id')));
    expect(body, isNot(contains('chapters')));
    expect(exam.examId, 2);
    expect(exam.aiExamId, 7);
    expect(exam.questions.single.rightAnswer, 'A');
    expect(exam.questions.single.correctAnswer, '4');
  });

  test('defaults an omitted assessment grade to kindergarten', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    await api.generateAssessmentExam(profileId: 21, gradeLabel: '   ');

    expect(_body(captured), containsPair('grade', 0));
  });

  test('maps the kindergarten label to grade zero', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    await api.generateAssessmentExam(profileId: 21, gradeLabel: 'Mẫu giáo');

    expect(_body(captured), containsPair('grade', 0));
  });

  test('submits answers by user_ai_exam_id and maps result stats', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return <String, dynamic>{
        ..._examResponse(),
        'exam': <String, dynamic>{
          ...(_examResponse()['exam']! as Map<String, dynamic>),
          'status': 'SUBMITTED',
          'result': <String, dynamic>{
            'correct_number': 1,
            'score_percentage': 100,
            'skipped_number': 0,
            'total_questions': 1,
          },
        },
        'stats': <String, dynamic>{
          'user_exam_id': 99,
          'correct_number': 13,
          'score_percentage': 65,
          'skipped_number': 0,
          'total_questions': 20,
          'review': 'Tiến bộ tốt.',
        },
      };
    });

    final exam = await api.submitExam(
      examId: 2,
      profileId: 21,
      answers: const <SubmitExamAnswer>[
        SubmitExamAnswer(questionNumber: 1, label: 'A'),
      ],
    );

    final body = _body(captured);
    expect(captured.path, '/exams/submit');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('user_ai_exam_id', 2));
    expect(body, isNot(contains('exam_id')));
    expect(exam.grading?.scorePercentage, 100);
    expect(exam.grading?.aiReview, 'Tiến bộ tốt.');
    expect(exam.userExamId, 99);
    expect(exam.answers.single.label, 'A');
  });

  test('updates the user exam status when assessment stops', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{'mstatus': 200, 'status': 'Success'};
    });

    await api.updateUserExamStatus(
      profileId: 21,
      userExamId: 99,
      status: 'COMPLETE',
    );

    final body = _body(captured);
    expect(captured.path, '/exams/update-user-exam-status');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('user_exam_id', 99));
    expect(body, containsPair('status', 'COMPLETE'));
  });

  test('loads exam detail and maps selected answers from details', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return <String, dynamic>{
        ..._examResponse(),
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'question_number': 1,
            'selected_label': 'A',
            'selected_content': '4',
            'is_correct': true,
          },
        ],
      };
    });

    final exam = await api.getExamDetail(2, profileId: 21);

    final body = _body(captured);
    expect(captured.path, '/exams/detail');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('user_ai_exam_id', 2));
    expect(exam.answers.single.questionNumber, 1);
    expect(exam.answers.single.label, 'A');
  });

  test('loads the new exam statistics endpoint', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'mstatus': 200,
        'stats': <Map<String, dynamic>>[
          <String, dynamic>{
            'correct_number': 13,
            'exam_type': 'ASSESSMENT',
            'grade': 1,
            'level': 5,
            'score_percentage': 65,
            'skipped_number': 0,
            'total_questions': 20,
          },
        ],
      };
    });

    final stats = await api.getExamStats(profileId: 21);

    expect(captured.path, '/exams/stats');
    expect(_body(captured), containsPair('exam_type', 'ASSESSMENT'));
    expect(stats.single.level, 5);
    expect(stats.single.scorePercentage, 65);
  });
}

ExamApi _apiReturning(
  Map<String, dynamic> Function(RequestOptions options) response,
) {
  final dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: response(options),
            ),
          );
        },
      ),
    );
  return ExamApi(
    networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
  );
}

Map<String, dynamic> _body(RequestOptions options) =>
    Map<String, dynamic>.from(options.data as Map<String, dynamic>);

Map<String, dynamic> _examResponse() => <String, dynamic>{
  'mstatus': 200,
  'status': 'Success',
  'exam': <String, dynamic>{
    'ai_exam_id': 7,
    'user_ai_exam_id': 2,
    'profile_id': 21,
    'exam_type': 'ASSESSMENT',
    'grade': 2,
    'level': 1,
    'num_questions': 1,
    'status': 'IN_PROGRESS',
    'title': 'Lớp 2 - Cấp độ 1',
    'questions': <Map<String, dynamic>>[
      <String, dynamic>{
        'question_name': '🍓 🍓 🍓 + 🍓 = ?',
        'question_number': 1,
        'question_grade': 2,
        'question_level': 1,
        'question_topic': 'counting',
        'question_type': 'COUNT',
        'right_answer_content': '4',
        'right_answer_label': 'A',
        'answers': <Map<String, dynamic>>[
          <String, dynamic>{'content': '4', 'label': 'A'},
        ],
      },
    ],
  },
};
