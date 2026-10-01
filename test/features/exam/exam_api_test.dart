import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/auth/models/guest_account.dart';
import 'package:numi/features/exam/controllers/exam_attempt_controller.dart';
import 'package:numi/features/exam/data/exam_api.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
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
    expect(body, isNot(contains('esess_id')));
    expect(body, isNot(contains('chapters')));
    expect(exam.examId, 2);
    expect(exam.aiExamId, 7);
    expect(exam.userExamId, 99);
    expect(exam.questions.single.rightAnswer, 'A');
    expect(exam.questions.single.correctAnswer, '4');
  });

  test('includes guest uid when generating without a profile id', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    }, guestAccountService: _GuestAccountService());

    await api.generateAssessmentExam();

    expect(_body(captured), containsPair('uid', 42));
    expect(_body(captured), isNot(contains('profile_id')));
    expect(captured.extra['useGuestToken'], isTrue);
  });

  test('generates PRACTICE with its assessment journey id', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    final exam = await api.generateAssessmentExam(
      examType: examTypePractice,
      profileId: 21,
      gradeLabel: 'Lớp 2',
      userExamId: 99,
    );

    final body = _body(captured);
    expect(captured.path, '/exams/generate');
    expect(body, containsPair('exam_type', examTypePractice));
    expect(body, containsPair('grade', 2));
    expect(body, containsPair('esess_id', 99));
    expect(exam.userExamId, 99);
  });

  for (final level in [0, 7]) {
    test('generates GRADE with requested level $level', () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return _examResponse();
      });

      await api.generateAssessmentExam(
        examType: examTypeGrade,
        profileId: 21,
        gradeLabel: 'Lớp 5',
        level: level,
      );

      final body = _body(captured);
      expect(body, containsPair('exam_type', examTypeGrade));
      expect(body, containsPair('grade', 5));
      expect(body, containsPair('level', level));
      expect(body, isNot(contains('esess_id')));
    });
  }

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

  test('submits answers by elink_id and maps result stats', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return <String, dynamic>{
        ..._examResponse(),
        'exam': <String, dynamic>{
          ...(_examResponse()['exam']! as Map<String, dynamic>),
          'esess_id': null,
          'status': 'SUBMITTED',
          'result': <String, dynamic>{
            'correct_number': 1,
            'score_percentage': 100,
            'skipped_number': 0,
            'total_questions': 1,
          },
        },
        'stats': <String, dynamic>{
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
    expect(body, containsPair('elink_id', 2));
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
    expect(captured.path, '/exams/sessions/mark');
    expect(captured.method, 'POST');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('esess_id', 99));
    expect(body, containsPair('status', 'COMPLETE'));
    expect(body, isNot(contains('esess_flag')));
    expect(captured.extra['useGuestToken'], isNull);
  });

  for (final passed in [true, false]) {
    test('marks a completed grade session with esess_flag=$passed', () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return const <String, dynamic>{'mstatus': 200, 'status': 'Success'};
      });

      await api.updateUserExamStatus(
        profileId: 21,
        userExamId: 99,
        status: 'COMPLETE',
        esessFlag: passed,
      );

      expect(captured.path, '/exams/sessions/mark');
      expect(captured.method, 'POST');
      expect(_body(captured), containsPair('profile_id', 21));
      expect(_body(captured), containsPair('esess_id', 99));
      expect(_body(captured), containsPair('status', 'COMPLETE'));
      expect(_body(captured), containsPair('esess_flag', passed));
    });
  }

  test('updates guest user exam status with the guest token', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{'mstatus': 200, 'status': 'Success'};
    }, guestAccountService: _GuestAccountService());

    await api.updateUserExamStatus(
      profileId: 21,
      userExamId: 99,
      status: 'COMPLETE',
    );

    expect(captured.path, '/exams/sessions/mark');
    expect(captured.method, 'POST');
    expect(captured.extra['useGuestToken'], isTrue);
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
    expect(body, containsPair('exam_type', examTypeAssessment));
    expect(body, containsPair('elink_id', 2));
    expect(body, isNot(contains('esess_id')));
    expect(exam.answers.single.questionNumber, 1);
    expect(exam.answers.single.label, 'A');
  });

  test('sends GRADE exam type when loading grade detail', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    await api.getExamDetail(2, profileId: 21, examType: examTypeGrade);

    final body = _body(captured);
    expect(captured.path, '/exams/detail');
    expect(body, containsPair('exam_type', examTypeGrade));
  });

  test('loads an entire assessment journey by esess_id', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'exam_id': 7,
            'elink_id': 2,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 1,
            'level': 1,
            'num_questions': 10,
            'status': 'ACTIVE',
            'title': 'Lớp 1 - Cấp độ 1',
            'started_dt': '2026-09-12T08:00:00Z',
            'submitted_dt': '2026-09-12T08:02:00Z',
          },
          <String, dynamic>{
            'exam_id': 8,
            'elink_id': 3,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 3,
            'level': 1,
            'num_questions': 10,
            'status': 'SUBMITTED',
            'title': 'Lớp 3 - Cấp độ 1',
            'short_text': 'Phân số cơ bản',
            'started_dt': '2026-09-12T08:03:00Z',
            'submitted_dt': '2026-09-12T08:05:00Z',
          },
        ],
        'stats': <String, dynamic>{
          'correct_number': 1,
          'score_percentage': 50,
          'skipped_number': 0,
          'total_questions': 2,
          'exam_type': 'ASSESSMENT',
          'status': 'COMPLETE',
          'esess_id': 99,
          'grade': 1,
          'last_submitted_dt': '2026-09-12T08:02:00Z',
          'review': 'Journey review',
        },
        'practice_preview': <String, dynamic>{
          'base_elink_id': 3,
          'mode': 'RETRY_WEAK',
          'strong_topics': <Map<String, dynamic>>[],
          'weak_topics': <Map<String, dynamic>>[
            <String, dynamic>{'topic': 'phép đếm', 'answered': 3, 'wrong': 3},
            <String, dynamic>{
              'topic': 'trừ không nhớ',
              'answered': 1,
              'wrong': 1,
            },
          ],
        },
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'question_number': 1,
            'question_name': '1 + 1 = ?',
            'answers': <Map<String, dynamic>>[
              <String, dynamic>{'label': 'A', 'content': '2'},
              <String, dynamic>{'label': 'B', 'content': '1'},
              <String, dynamic>{'label': 'C', 'content': '3'},
              <String, dynamic>{'label': 'D', 'content': '4'},
            ],
            'question_level': 1,
            'question_topic': 'addition',
            'right_answer_content': '2',
            'right_answer_label': 'A',
            'selected_content': '2',
            'selected_label': 'A',
            'is_correct': true,
          },
          <String, dynamic>{
            'question_number': 1,
            'question_name': '3 + 2 = ?',
            'answers': <Map<String, dynamic>>[
              <String, dynamic>{'label': 'A', 'content': '5'},
              <String, dynamic>{'label': 'B', 'content': '4'},
              <String, dynamic>{'label': 'C', 'content': '6'},
              <String, dynamic>{'label': 'D', 'content': '3'},
            ],
            'question_level': 1,
            'question_topic': 'addition',
            'right_answer_content': '5',
            'right_answer_label': 'A',
            'selected_content': '4',
            'selected_label': 'B',
            'is_correct': false,
          },
        ],
      };
    });

    final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

    final body = _body(captured);
    expect(captured.path, '/exams/detail');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('exam_type', examTypeAssessment));
    expect(body, containsPair('esess_id', 99));
    expect(body, isNot(contains('elink_id')));
    expect(exam.userExamId, 99);
    expect(
      exam.questions.map((question) => question.questionNumber),
      orderedEquals(<int>[1, 2]),
    );
    expect(
      exam.answers.map((answer) => answer.questionNumber),
      orderedEquals(<int>[1, 2]),
    );
    expect(exam.grading?.totalQuestions, 2);
    expect(exam.grading?.correctNumber, 1);
    expect(exam.grade, 1);
    expect(exam.lastSetGrade, 3);
    expect(exam.lastSetShortText, 'Phân số cơ bản');
    expect(
      exam.practiceWeakTopics.map((topic) => topic.topic),
      orderedEquals(<String>['phép đếm', 'trừ không nhớ']),
    );
    expect(exam.practiceWeakTopics.first.answered, 3);
    expect(exam.practiceWeakTopics.first.wrong, 3);
    expect(exam.questions.last.answers, hasLength(4));
    expect(exam.questions.last.rightAnswer, 'A');
    expect(exam.answers.last.label, 'B');
  });

  test('loads only the active set with its saved answers for resume', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'elink_id': 40,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 0,
            'status': 'SUBMITTED',
            'questions': <Map<String, dynamic>>[],
          },
          <String, dynamic>{
            'elink_id': 41,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 1,
            'num_questions': 3,
            'status': 'ACTIVE',
            'questions': List<Map<String, dynamic>>.generate(
              3,
              (index) => <String, dynamic>{
                'question_number': index + 1,
                'question_name': 'Resume question ${index + 1}',
                'right_answer_label': 'A',
                'right_answer_content': '${index + 2}',
                'answers': <Map<String, dynamic>>[
                  <String, dynamic>{'label': 'A', 'content': '${index + 2}'},
                  <String, dynamic>{'label': 'B', 'content': '0'},
                ],
              },
            ),
          },
        ],
        'stats': <String, dynamic>{
          'correct_number': 2,
          'score_percentage': 0,
          'skipped_number': 0,
          'total_questions': 3,
          'exam_type': 'ASSESSMENT',
          'status': 'ACTIVE',
          'esess_id': 99,
          'grade': 1,
        },
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'elink_id': 40,
            'question_number': 1,
            'selected_label': 'A',
          },
          <String, dynamic>{
            'elink_id': 41,
            'question_number': 1,
            'selected_label': 'A',
          },
          <String, dynamic>{
            'elink_id': 41,
            'question_number': 2,
            'selected_label': 'B',
          },
        ],
      };
    });

    final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

    final body = _body(captured);
    expect(body, containsPair('esess_id', 99));
    expect(exam.examId, 41);
    expect(exam.userExamId, 99);
    expect(exam.examStatus, 'ACTIVE');
    expect(exam.questions, hasLength(3));
    expect(exam.questions.last.questionName, 'Resume question 3');
    expect(exam.answers, hasLength(2));
    expect(exam.resumeQuestionIndex, 2);
    expect(
      exam.answers.map((answer) => answer.questionNumber),
      orderedEquals(<int>[1, 2]),
    );
  });

  test('clears the synthetic Q1/A exit answer when resuming', () async {
    final api = _apiReturning((_) {
      return <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'elink_id': 41,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 0,
            'num_questions': 3,
            'status': 'ACTIVE',
            'questions': List<Map<String, dynamic>>.generate(
              3,
              (index) => <String, dynamic>{
                'question_number': index + 1,
                'question_name': 'Resume question ${index + 1}',
                'right_answer_label': 'A',
                'right_answer_content': '${index + 2}',
                'answers': <Map<String, dynamic>>[
                  <String, dynamic>{'label': 'A', 'content': '${index + 2}'},
                  <String, dynamic>{'label': 'B', 'content': '0'},
                ],
              },
            ),
          },
        ],
        'stats': <String, dynamic>{
          'correct_number': 1,
          'score_percentage': 0,
          'skipped_number': 0,
          'total_questions': 1,
          'exam_type': 'ASSESSMENT',
          'status': 'ACTIVE',
          'esess_id': 99,
          'grade': 0,
        },
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'elink_id': 41,
            'question_number': 1,
            'selected_label': 'A',
          },
        ],
      };
    });

    final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

    expect(exam.questions, hasLength(3));
    expect(exam.answers, isEmpty);
    expect(exam.resumeQuestionIndex, 0);
  });

  test(
    'loads the full active set before resuming a placeholder-only journey',
    () async {
      final requests = <RequestOptions>[];
      final api = _apiReturning((options) {
        requests.add(options);
        final body = _body(options);
        if (body['esess_id'] == 99) {
          return <String, dynamic>{
            'mstatus': 200,
            'status': 'Success',
            'exams': <Map<String, dynamic>>[
              <String, dynamic>{
                'exam_id': 7,
                'elink_id': 41,
                'profile_id': 21,
                'exam_type': 'ASSESSMENT',
                'grade': 0,
                'num_questions': 10,
                // Submitting Q1/A creates the journey but leaves it ACTIVE.
                'status': 'SUBMITTED',
              },
            ],
            'stats': <String, dynamic>{
              'correct_number': 0,
              'score_percentage': 0,
              'skipped_number': 9,
              'total_questions': 1,
              'exam_type': 'ASSESSMENT',
              'status': 'ACTIVE',
              'esess_id': 99,
              'grade': 0,
            },
            'details': <Map<String, dynamic>>[
              <String, dynamic>{
                'elink_id': 41,
                'question_number': 1,
                'selected_label': 'A',
              },
            ],
          };
        }

        expect(body, containsPair('elink_id', 41));
        expect(body, isNot(contains('esess_id')));
        return <String, dynamic>{
          'mstatus': 200,
          'status': 'Success',
          'exam': <String, dynamic>{
            'exam_id': 7,
            'elink_id': 41,
            'profile_id': 21,
            'exam_type': 'ASSESSMENT',
            'grade': 0,
            'num_questions': 10,
            'status': 'SUBMITTED',
            'questions': List<Map<String, dynamic>>.generate(
              10,
              (index) => <String, dynamic>{
                'question_number': index + 1,
                'question_name': 'Resume question ${index + 1}',
                'right_answer_label': 'B',
                'right_answer_content': '${index + 2}',
                'answers': <Map<String, dynamic>>[
                  <String, dynamic>{'label': 'A', 'content': '0'},
                  <String, dynamic>{'label': 'B', 'content': '${index + 2}'},
                ],
              },
            ),
          },
        };
      });

      final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

      expect(requests, hasLength(2));
      expect(exam.examId, 41);
      expect(exam.userExamId, 99);
      expect(exam.examStatus, 'ACTIVE');
      expect(exam.questions, hasLength(10));
      expect(exam.answers, isEmpty);
      expect(exam.resumeQuestionIndex, 0);

      final controller = ExamAttemptController(
        examService: api,
        initialExam: exam,
        profileId: 21,
      );
      addTearDown(controller.dispose);
      controller.selectAnswer(exam.questions.first.answers.first);

      expect(
        controller.prepareAssessmentFlow(),
        AssessmentFlowAction.continueSet,
      );
    },
  );

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
            'esess_status': 'COMPLETE',
            'esess_id': 99,
            'grade': 1,
            'level': 5,
            'score_percentage': 65,
            'skipped_number': 0,
            'total_questions': 20,
            'in_progress_exams': <Map<String, dynamic>>[
              <String, dynamic>{
                'exam_id': 14,
                'elink_id': 27,
                'profile_id': 21,
                'exam_type': 'ASSESSMENT',
                'grade': 2,
                'num_questions': 1,
                'elink_status': 'IN_PROGRESS',
                'title': 'Lớp 2',
                'questions': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'question_name': 'Resume from stats',
                    'question_number': 1,
                    'right_answer_content': '4',
                    'right_answer_label': 'A',
                    'answers': <Map<String, dynamic>>[
                      <String, dynamic>{'content': '4', 'label': 'A'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      };
    });

    final stats = await api.getExamStats(profileId: 21);

    expect(captured.path, '/exams/stats');
    expect(_body(captured), containsPair('exam_type', 'ASSESSMENT'));
    expect(stats.single.level, 5);
    expect(stats.single.status, 'COMPLETE');
    expect(stats.single.userExamId, 99);
    expect(stats.single.scorePercentage, 65);
    expect(stats.single.inProgressExams.single.userExamId, 99);
    expect(stats.single.inProgressExams.single.userAiExamId, 27);
    expect(stats.single.inProgressExams.single.examStatus, 'IN_PROGRESS');
    expect(
      stats.single.inProgressExams.single.questions.single.questionName,
      'Resume from stats',
    );
  });

  test('omits exam_type when requesting stats for all exam types', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'mstatus': 200,
        'stats': <Map<String, dynamic>>[],
      };
    });

    await api.getExamStats(profileId: 21, examType: examTypeAll);

    expect(captured.path, '/exams/stats');
    expect(_body(captured), containsPair('profile_id', 21));
    expect(_body(captured), isNot(contains('exam_type')));
  });

  test(
    'reads grade ladder sessions and pass flags for a selected grade',
    () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return {
          'mstatus': 200,
          'status': 'Success',
          'profile_id': 21,
          'grade': 2,
          'exam_sessions': [
            for (final passed in [false, true])
              {
                'esess_id': passed ? 104 : 103,
                'exam_type': 'GRADE',
                'status': 'COMPLETE',
                'grade': 2,
                'level': 1,
                'correct_number': passed ? 9 : 4,
                'score_percentage': passed ? 90 : 40,
                'skipped_number': 0,
                'total_questions': 10,
                'review': 'Session review',
                'esess_flag': passed,
                'is_latest': passed,
                'last_submitted_dt': '2026-09-30T16:51:57.395796Z',
                'ended_dt': '2026-09-30T17:06:45.875089Z',
                'create_dt': '2026-09-30T16:50:20.962157Z',
              },
          ],
        };
      });

      final sessions = await api.getGradeLadder(profileId: 21, grade: 2);

      expect(captured.path, '/exams/grade/ladder');
      expect(_body(captured), containsPair('profile_id', 21));
      expect(_body(captured), containsPair('exam_type', 'GRADE'));
      expect(_body(captured), containsPair('grade', 2));
      expect(sessions, hasLength(2));
      expect(sessions.first.userExamId, 103);
      expect(sessions.first.passed, isFalse);
      expect(sessions.first.isLatest, isFalse);
      final latest = sessions.last;
      expect(latest.userExamId, 104);
      expect(latest.examType, 'GRADE');
      expect(latest.status, 'COMPLETE');
      expect(latest.grade, 2);
      expect(latest.level, 1);
      expect(latest.passed, isTrue);
      expect(latest.isLatest, isTrue);
      expect(latest.scorePercentage, 90);
      expect(latest.review, 'Session review');
      expect(
        latest.lastSubmittedDt,
        DateTime.parse('2026-09-30T16:51:57.395796Z'),
      );
      expect(latest.endedDt, DateTime.parse('2026-09-30T17:06:45.875089Z'));
      expect(latest.createDt, DateTime.parse('2026-09-30T16:50:20.962157Z'));
    },
  );

  test('grade ladder accepts an empty session history', () async {
    final api = _apiReturning((_) => {'mstatus': 200, 'exam_sessions': []});
    expect(await api.getGradeLadder(profileId: 21, grade: 0), isEmpty);
  });

  test('grade ladder propagates API failure', () async {
    final api = _apiReturning((_) => {'mstatus': 500, 'status': 'Failed'});
    await expectLater(
      api.getGradeLadder(profileId: 21, grade: 2),
      throwsException,
    );
  });

  test('reads grade levels for a profile and grade', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'latest_level': 1,
        'max_level': 3,
        'mstatus': 200,
        'status': 'Success',
      };
    });

    final levels = await api.getGradeLevels(profileId: 21, grade: 2);

    expect(captured.path, '/exams/grade/levels');
    expect(_body(captured), containsPair('profile_id', 21));
    expect(_body(captured), containsPair('grade', 2));
    expect(_body(captured), isNot(contains('exam_type')));
    expect(levels.latestLevel, 1);
    expect(levels.maxLevel, 3);
  });
}

ExamApi _apiReturning(
  Map<String, dynamic> Function(RequestOptions options) response, {
  GuestAccountService? guestAccountService,
}) {
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
    guestAccountService: guestAccountService,
  );
}

class _GuestAccountService implements GuestAccountService {
  @override
  GuestAccount? get current =>
      const GuestAccount(uid: 42, user: <String, dynamic>{'uid': 42});

  @override
  Future<int?> readStoredUid() async => 42;

  @override
  Future<GuestAccount> ensureGuest() async => current!;

  @override
  Future<void> clear() async {}
}

Map<String, dynamic> _body(RequestOptions options) =>
    Map<String, dynamic>.from(options.data as Map<String, dynamic>);

Map<String, dynamic> _examResponse() => <String, dynamic>{
  'mstatus': 200,
  'status': 'Success',
  'esess_id': 99,
  'exam': <String, dynamic>{
    'exam_id': 7,
    'elink_id': 2,
    'esess_id': 99,
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
