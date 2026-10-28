import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/auth/models/guest_account.dart';
import 'package:numi/features/exam/controllers/exam_attempt_controller.dart';
import 'package:numi/features/exam/data/exam_api.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  for (final hasCanonicalSessionId in [true, false]) {
    test(
      'generate and submit use only the nested session ID (present: $hasCanonicalSessionId)',
      () async {
        final api = _apiReturning((_) {
          final response = _examResponse();
          response['esess_id'] = 11;
          (response['exam'] as Map<String, dynamic>)['esess_id'] = 22;
          if (!hasCanonicalSessionId) {
            (response['exam_session'] as Map<String, dynamic>).remove(
              'esess_id',
            );
          }
          return response;
        });
        final generated = await api.generateAssessmentExam(
          examType: examTypePractice,
          profileId: 21,
          userExamId: 33,
        );
        final submitted = await api.submitExam(
          examId: 2,
          profileId: 21,
          answers: const [],
        );
        expect(generated.userExamId, hasCanonicalSessionId ? 99 : isNull);
        expect(submitted.userExamId, hasCanonicalSessionId ? 99 : isNull);
      },
    );
  }

  test(
    'rogue-v2 submits IDs and numeric values without legacy labels',
    () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return _examResponse();
      });
      final exam = await api.submitExam(
        examId: 2,
        profileId: 21,
        answers: const [
          SubmitExamAnswer(questionNumber: 1, optionIds: ['b']),
          SubmitExamAnswer(questionNumber: 2, optionIds: ['Bank-Z', 'a']),
          SubmitExamAnswer(questionNumber: 3, optionIds: ['false']),
          SubmitExamAnswer(questionNumber: 4, value: '1/2'),
        ],
      );
      expect(_body(captured), {
        'profile_id': 21,
        'elink_id': 2,
        'answers': [
          {
            'question_number': 1,
            'option_ids': ['b'],
          },
          {
            'question_number': 2,
            'option_ids': ['Bank-Z', 'a'],
          },
          {
            'question_number': 3,
            'option_ids': ['false'],
          },
          {'question_number': 4, 'value': '1/2'},
        ],
      });
      expect(exam.answers.last.value, '1/2');
      expect(exam.answers[1].selectedOptionIds, ['Bank-Z', 'a']);
    },
  );

  for (final code in [13747, 13713]) {
    test(
      'rogue-v2 preserves error code $code and gives an actionable message',
      () async {
        final api = _apiReturning(
          (_) => {'mstatus': code, 'mmessage': 'Internal error'},
        );
        await expectLater(
          api.generateAssessmentExam(profileId: 21),
          throwsA(
            isA<ExamException>()
                .having((e) => e.status, 'status', code)
                .having((e) => e.message, 'message', isNot('Internal error')),
          ),
        );
      },
    );
  }

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
    expect(exam.questions.single.correctOptionIds, ['A']);
    expect(exam.questions.single.options.single.text, '4');
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

  for (final level in [1, 2, 7, 10]) {
    test(
      'generates GRADE display level $level with API level ${level - 1}',
      () async {
        late RequestOptions captured;
        final api = _apiReturning((options) {
          captured = options;
          final response = _examResponse();
          (response['exam'] as Map<String, dynamic>)
            ..['exam_type'] = examTypeGrade
            ..['level'] = level - 1;
          return response;
        });

        final exam = await api.generateAssessmentExam(
          examType: examTypeGrade,
          profileId: 21,
          gradeLabel: 'Lớp 5',
          level: level,
        );

        final body = _body(captured);
        expect(body, containsPair('exam_type', examTypeGrade));
        expect(body, containsPair('grade', 5));
        expect(body, containsPair('level', level - 1));
        expect(body, isNot(contains('esess_id')));
        expect(exam.level, level);
      },
    );
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

  for (final apiLevel in [0, 4, 9]) {
    test(
      'GRADE level $apiLevel round trips through submit and detail',
      () async {
        final api = _apiReturning((options) {
          final response = _examResponse();
          final exam = response['exam'] as Map<String, dynamic>;
          exam
            ..['exam_type'] = 'GRADE'
            ..['level'] = apiLevel
            ..['status'] = 'COMPLETE';
          response['exam_session'] = {
            'exam_type': 'GRADE',
            'esess_id': 99,
            'grade': 2,
            'level': apiLevel,
            'status': 'COMPLETE',
            'total_questions': 1,
            'correct_number': 1,
            'skipped_number': 0,
            'score_percentage': 100,
          };
          response['details'] = [
            {
              'question_number': 1,
              'question_text': '1 + 1 = ?',
              'child_option_ids': ['A'],
              'child_answer_text': '2',
              'right_option_ids': ['A'],
              'right_answer_text': '2',
            },
          ];
          return response;
        });
        final submitted = await api.submitExam(
          examId: 2,
          profileId: 21,
          answers: const [
            SubmitExamAnswer(questionNumber: 1, optionIds: ['A']),
          ],
        );
        final detailByLink = await api.getExamDetail(
          2,
          profileId: 21,
          examType: examTypeGrade,
        );
        final detailBySession = await api.getExamDetail(
          0,
          userExamId: 99,
          profileId: 21,
          examType: examTypeGrade,
        );
        expect(submitted.level, apiLevel + 1);
        expect(detailByLink.level, apiLevel + 1);
        expect(detailBySession.level, apiLevel + 1);
        expect(detailBySession.examType, examTypeGrade);
      },
    );
  }

  test('maps the kindergarten label to grade zero', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    await api.generateAssessmentExam(profileId: 21, gradeLabel: 'Mẫu giáo');

    expect(_body(captured), containsPair('grade', 0));
  });

  test('submits answers by elink_id and maps exam_session', () async {
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
        'exam_session': <String, dynamic>{
          'esess_id': 99,
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
        SubmitExamAnswer(questionNumber: 1, optionIds: ['A']),
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
    expect(exam.answers.single.selectedOptionIds.single, 'A');
  });

  test('updates the user exam status when assessment stops', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return const <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'exam_session': {
          'esess_id': 99,
          'status': 'COMPLETE',
          'last_submitted_dt': '20260927071430.940271',
          'correct_number': 5,
          'score_percentage': 50,
          'skipped_number': 0,
          'total_questions': 10,
        },
      };
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

  for (final id in <int?>[null, 0, -1]) {
    test('mark sends missing or invalid IDs to backend: $id', () async {
      final requests = <RequestOptions>[];
      final api = _apiReturning((options) {
        requests.add(options);
        return const <String, dynamic>{
          'mstatus': 400,
          'mmessage': 'Backend rejected mark',
        };
      }, guestAccountService: _GuestAccountService());

      await expectLater(
        api.updateUserExamStatus(
          profileId: id,
          userExamId: id,
          status: 'CANCEL',
        ),
        throwsA(
          isA<ExamException>().having((error) => error.status, 'status', 400),
        ),
      );

      expect(requests, hasLength(1));
      expect(requests.single.path, '/exams/sessions/mark');
      expect(_body(requests.single), containsPair('profile_id', id));
      expect(_body(requests.single), containsPair('esess_id', id));
      expect(_body(requests.single), containsPair('status', 'CANCEL'));
    });
  }

  test(
    'cancel with no exam still calls mark and exposes the backend error',
    () async {
      final requests = <RequestOptions>[];
      final api = _apiReturning((options) {
        requests.add(options);
        return const <String, dynamic>{
          'mstatus': 400,
          'mmessage': 'Missing ID',
        };
      }, guestAccountService: _GuestAccountService());
      final controller = ExamAttemptController(examService: api);
      addTearDown(controller.dispose);

      await expectLater(
        controller.updateStatusForExit('CANCEL'),
        throwsA(
          isA<ExamException>().having((error) => error.status, 'status', 400),
        ),
      );

      expect(requests, hasLength(1));
      expect(requests.single.path, '/exams/sessions/mark');
      expect(_body(requests.single), containsPair('esess_id', null));
      expect(_body(requests.single), containsPair('profile_id', null));
      expect(_body(requests.single), containsPair('status', 'CANCEL'));
    },
  );

  for (final nestedSessionId in [false, true]) {
    test(
      'cancels guest assessment with nested exam_session: $nestedSessionId',
      () async {
        final requests = <RequestOptions>[];
        final api = _apiReturning((options) {
          requests.add(options);
          if (options.path == '/exams/sessions/mark') {
            return const <String, dynamic>{'mstatus': 200, 'status': 'Success'};
          }
          final response = _examResponse();
          if (nestedSessionId) {
            response.remove('esess_id');
            (response['exam'] as Map<String, dynamic>).remove('esess_id');
            response['exam_session'] = <String, dynamic>{
              'esess_id': 9,
              'exam_type': 'ASSESSMENT',
              'status': 'ACTIVE',
              'total_questions': 0,
              'correct_number': 0,
              'skipped_number': 0,
              'esess_flag': null,
              'grade': 0,
              'level': 1,
              'create_dt': '20261005095805.694854',
            };
            response['resumed'] = false;
          }
          return response;
        }, guestAccountService: _GuestAccountService());
        final controller = ExamAttemptController(
          examService: api,
          profileId: 21,
        );
        addTearDown(controller.dispose);

        expect(await controller.generateExam(), isTrue);
        expect(controller.userExamId, nestedSessionId ? 9 : 99);
        await controller.updateStatusForExit('CANCEL');

        expect(requests.map((request) => request.path).toList(), <String>[
          '/exams/generate',
          '/exams/sessions/mark',
        ]);
        expect(
          _body(requests.last),
          containsPair('esess_id', nestedSessionId ? 9 : 99),
        );
        expect(_body(requests.last), isNot(contains('elink_id')));
        expect(_body(requests.last), containsPair('profile_id', 21));
        expect(_body(requests.last), containsPair('status', 'CANCEL'));
        expect(
          requests.every((request) => request.extra['useGuestToken'] == true),
          isTrue,
        );
      },
    );
  }

  for (final totalQuestions in [0, 6, 12]) {
    test(
      'assessment continues at session total_questions + 1: $totalQuestions',
      () async {
        final api = _apiReturning((_) {
          final response = _examResponse()..remove('esess_id');
          (response['exam'] as Map<String, dynamic>).remove('esess_id');
          response['exam_session'] = <String, dynamic>{
            'esess_id': 9,
            'exam_type': 'ASSESSMENT',
            'status': 'ACTIVE',
            'total_questions': totalQuestions,
            'correct_number': 0,
            'skipped_number': 0,
            'grade': 2,
            'level': 1,
          };
          response['resumed'] = totalQuestions > 0;
          return response;
        }, guestAccountService: _GuestAccountService());
        final controller = ExamAttemptController(
          examService: api,
          profileId: 21,
        );
        addTearDown(controller.dispose);

        expect(await controller.generateExam(), isTrue);
        expect(controller.userExamId, 9);
        expect(controller.questionIndex, 0);
        expect(controller.questionNumberOffset, totalQuestions);
        expect(controller.displayedQuestionNumber, totalQuestions + 1);
        if (totalQuestions > 0) expect(controller.currentGrade, 2);

        final reopened = ExamAttemptController(
          examService: api,
          initialExam: controller.exam,
          profileId: 21,
        );
        addTearDown(reopened.dispose);
        expect(reopened.displayedQuestionNumber, totalQuestions + 1);
      },
    );
  }

  for (final examType in [examTypeAssessment, examTypeGrade]) {
    test(
      'active session list preserves assessment numbering only: $examType',
      () async {
        final api = _apiReturning(
          (_) => <String, dynamic>{
            'mstatus': 200,
            'exam_sessions': <Map<String, dynamic>>[
              <String, dynamic>{
                'esess_id': 9,
                'exam_type': examType,
                'status': 'ACTIVE',
                'total_questions': 12,
                'correct_number': 0,
                'skipped_number': 0,
                'in_progress_exams': <Map<String, dynamic>>[
                  <String, dynamic>{
                    ..._examResponse()['exam'] as Map<String, dynamic>,
                    'exam_type': examType,
                  },
                ],
              },
            ],
          },
        );
        final sessions = await api.getExamStats(profileId: 21);
        final controller = ExamAttemptController(
          examService: api,
          initialExam: sessions.single.inProgressExams.single,
        );
        addTearDown(controller.dispose);

        expect(controller.userExamId, 9);
        expect(
          controller.displayedQuestionNumber,
          examType == examTypeAssessment ? 13 : 1,
        );
      },
    );
  }

  test('loads exam detail and maps selected answers from details', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return <String, dynamic>{
        ..._examResponse(),
        'details': <Map<String, dynamic>>[
          <String, dynamic>{
            'question_number': 1,
            'child_option_ids': ['A'],
            'child_answer_text': '4',
            'is_correct': true,
          },
        ],
      };
    });

    final exam = await api.getExamDetail(2, profileId: 21);

    final body = _body(captured);
    expect(captured.path, '/exams/sessions/detail');
    expect(body, containsPair('profile_id', 21));
    expect(body, containsPair('exam_type', examTypeAssessment));
    expect(body, containsPair('elink_id', 2));
    expect(body, isNot(contains('esess_id')));
    expect(exam.answers.single.questionNumber, 1);
    expect(exam.answers.single.selectedOptionIds.single, 'A');
  });

  test('sends GRADE exam type when loading grade detail', () async {
    late RequestOptions captured;
    final api = _apiReturning((options) {
      captured = options;
      return _examResponse();
    });

    await api.getExamDetail(2, profileId: 21, examType: examTypeGrade);

    final body = _body(captured);
    expect(captured.path, '/exams/sessions/detail');
    expect(body, containsPair('exam_type', examTypeGrade));
  });

  for (final entireJourney in [false, true]) {
    for (final type in [examTypeAssessment, examTypeGrade, examTypePractice]) {
      test(
        'detail maps AI fields from exam_session ($type, journey=$entireJourney)',
        () async {
          final api = _apiReturning(
            (_) => {
              ..._examResponse(),
              'exams': [
                {
                  'elink_id': 136,
                  'exam_id': 136,
                  'profile_id': 17,
                  'exam_type': type,
                  'grade': 1,
                  'level': 3,
                  'status': 'SUBMITTED',
                  'short_text': 'Different set text',
                  'num_questions': 10,
                },
              ],
              'exam_session': {
                'esess_id': 114,
                'exam_type': type,
                'status': 'COMPLETE',
                'total_questions': 10,
                'correct_number': 7,
                'skipped_number': 0,
                'score_percentage': 70,
                'review': 'Answered 7/10 correctly.',
                'title': 'Number skills',
                'short_text': 'Numbers and arithmetic within 100',
                'ai_review_short': 'Practice subtraction and ordering numbers.',
                'ai_review_long': 'Detailed feedback saved in stats.',
                'grade': 1,
                'level': 3,
              },
              'details': [
                {
                  'elink_id': 136,
                  'question_number': 1,
                  'question_text': 'What comes after 47?',
                  'right_option_ids': ['B'],
                  'right_answer_text': '48',
                  'child_option_ids': ['B'],
                  'child_answer_text': '48',
                  'is_correct': true,
                  'options': [
                    {'id': 'A', 'text': '46'},
                    {'id': 'B', 'text': '48'},
                  ],
                },
              ],
            },
          );
          final exam = await api.getExamDetail(
            136,
            profileId: 17,
            userExamId: entireJourney ? 114 : null,
            examType: type,
          );
          expect(
            exam.title,
            entireJourney ? 'Number skills' : 'Lớp 2 - Cấp độ 1',
          );
          expect(
            exam.shortText,
            entireJourney ? 'Numbers and arithmetic within 100' : isNull,
          );
          expect(
            exam.aiReviewShort,
            'Practice subtraction and ordering numbers.',
          );
          expect(exam.aiReviewLong, 'Detailed feedback saved in stats.');
        },
      );
    }
  }

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
        'exam_session': <String, dynamic>{
          'correct_number': 1,
          'score_percentage': 50,
          'skipped_number': 0,
          'total_questions': 2,
          'exam_type': 'ASSESSMENT',
          'status': 'COMPLETE',
          'esess_id': 99,
          'grade': 1,
          'last_submitted_dt': '20260912080200',
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
            'question_text': '1 + 1 = ?',
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'id': 'A', 'text': '2'},
              <String, dynamic>{'id': 'B', 'text': '1'},
              <String, dynamic>{'id': 'C', 'text': '3'},
              <String, dynamic>{'id': 'D', 'text': '4'},
            ],
            'question_level': 1,
            'question_topic': 'addition',
            'right_answer_text': '2',
            'right_option_ids': ['A'],
            'child_answer_text': '2',
            'child_option_ids': ['A'],
            'is_correct': true,
          },
          <String, dynamic>{
            'question_number': 1,
            'question_text': '3 + 2 = ?',
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'id': 'A', 'text': '5'},
              <String, dynamic>{'id': 'B', 'text': '4'},
              <String, dynamic>{'id': 'C', 'text': '6'},
              <String, dynamic>{'id': 'D', 'text': '3'},
            ],
            'question_level': 1,
            'question_topic': 'addition',
            'right_answer_text': '5',
            'right_option_ids': ['A'],
            'child_answer_text': '4',
            'child_option_ids': ['B'],
            'is_correct': false,
          },
        ],
      };
    });

    final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

    final body = _body(captured);
    expect(captured.path, '/exams/sessions/detail');
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
    expect(exam.questions.last.options, hasLength(4));
    expect(exam.questions.last.correctOptionIds, ['A']);
    expect(exam.answers.last.selectedOptionIds.single, 'B');
  });

  test(
    'does not infer an active sitting from session status or review rows',
    () async {
      final api = _apiReturning(
        (_) => {
          'mstatus': 200,
          'exam_session': {
            'esess_id': 99,
            'status': 'ACTIVE',
            'correct_number': 0,
            'skipped_number': 0,
            'total_questions': 1,
          },
          'exams': [
            {'elink_id': 41, 'status': 'SUBMITTED', 'num_questions': 1},
          ],
          'details': [
            {
              'elink_id': 41,
              'question_number': 1,
              'question_text': 'A saved review question',
              'child_option_ids': ['A'],
            },
          ],
        },
      );
      await expectLater(
        api.getExamDetail(99, profileId: 21, userExamId: 99),
        throwsA(isA<ExamException>()),
      );
    },
  );

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
                'question_text': 'Resume question ${index + 1}',
                'correct_answer': {
                  'option_ids': ['A'],
                },

                'options': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'A', 'text': '${index + 2}'},
                  <String, dynamic>{'id': 'B', 'text': '0'},
                ],
              },
            ),
          },
        ],
        'exam_session': <String, dynamic>{
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
            'child_option_ids': ['A'],
          },
          <String, dynamic>{
            'elink_id': 41,
            'question_number': 1,
            'child_option_ids': ['A'],
          },
          <String, dynamic>{
            'elink_id': 41,
            'question_number': 2,
            'child_option_ids': ['B'],
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
    expect(exam.questions.last.questionText, 'Resume question 3');
    expect(exam.answers, hasLength(2));
    expect(exam.resumeQuestionIndex, 2);
    expect(
      exam.answers.map((answer) => answer.questionNumber),
      orderedEquals(<int>[1, 2]),
    );
  });

  test('preserves a real first option ID when resuming', () async {
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
                'question_text': 'Resume question ${index + 1}',
                'correct_answer': {
                  'option_ids': ['A'],
                },

                'options': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'A', 'text': '${index + 2}'},
                  <String, dynamic>{'id': 'B', 'text': '0'},
                ],
              },
            ),
          },
        ],
        'exam_session': <String, dynamic>{
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
            'child_option_ids': ['A'],
          },
        ],
      };
    });

    final exam = await api.getExamDetail(99, profileId: 21, userExamId: 99);

    expect(exam.questions, hasLength(3));
    expect(exam.answers.single.selectedOptionIds, ['A']);
    expect(exam.resumeQuestionIndex, 1);
  });

  test(
    'loads the full active set and preserves the first selected ID',
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
                // The journey points to a canonical in-progress sitting.
                'status': 'IN_PROGRESS',
              },
            ],
            'exam_session': <String, dynamic>{
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
                'child_option_ids': ['A'],
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
            'status': 'IN_PROGRESS',
            'questions': List<Map<String, dynamic>>.generate(
              10,
              (index) => <String, dynamic>{
                'question_number': index + 1,
                'question_text': 'Resume question ${index + 1}',
                'correct_answer': {
                  'option_ids': ['B'],
                },

                'options': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'A', 'text': '0'},
                  <String, dynamic>{'id': 'B', 'text': '${index + 2}'},
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
      expect(exam.examStatus, 'IN_PROGRESS');
      expect(exam.questions, hasLength(10));
      expect(exam.answers.single.selectedOptionIds, ['A']);
      expect(exam.resumeQuestionIndex, 1);

      final controller = ExamAttemptController(
        examService: api,
        initialExam: exam,
        profileId: 21,
      );
      addTearDown(controller.dispose);
      controller.selectAnswer(exam.questions.first.options.first);

      expect(
        controller.prepareAssessmentFlow(),
        AssessmentFlowAction.continueSet,
      );
    },
  );

  test(
    'loads session list with a single-type array and maps sessions',
    () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return const <String, dynamic>{
          'mstatus': 200,
          'exam_sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'correct_number': 13,
              'exam_type': 'ASSESSMENT',
              'status': 'COMPLETE',
              'esess_id': 99,
              'grade': 1,
              'level': 5,
              'short_text': 'Practice subtraction',
              'ai_review_short': 'Good progress.',
              'ai_review_long': 'Good progress. Focus on subtraction next.',
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
                  'status': 'IN_PROGRESS',
                  'title': 'Lớp 2',
                  'questions': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'question_text': 'Resume from stats',
                      'question_number': 1,

                      'correct_answer': {
                        'option_ids': ['A'],
                      },
                      'options': <Map<String, dynamic>>[
                        <String, dynamic>{'text': '4', 'id': 'A'},
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

      expect(captured.method, 'POST');
      expect(captured.path, '/exams/sessions/list');
      expect(_body(captured), containsPair('exam_types', ['ASSESSMENT']));
      expect(_body(captured), isNot(contains('exam_type')));
      expect(stats.single.level, 5);
      expect(stats.single.status, 'COMPLETE');
      expect(stats.single.userExamId, 99);
      expect(stats.single.scorePercentage, 65);
      expect(stats.single.shortText, 'Practice subtraction');
      expect(stats.single.aiReviewShort, 'Good progress.');
      expect(
        stats.single.aiReviewLong,
        'Good progress. Focus on subtraction next.',
      );
      expect(stats.single.inProgressExams.single.userExamId, 99);
      expect(stats.single.inProgressExams.single.userAiExamId, 27);
      expect(stats.single.inProgressExams.single.examStatus, 'IN_PROGRESS');
      expect(
        stats.single.inProgressExams.single.questions.single.questionText,
        'Resume from stats',
      );
    },
  );

  test(
    'Learning session list maps completed Assessment and Grade entries',
    () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return const <String, dynamic>{
          'mstatus': 200,
          'exam_sessions': <Map<String, dynamic>>[
            {
              'esess_id': 101,
              'exam_type': 'ASSESSMENT',
              'status': 'COMPLETE',
              'total_questions': 20,
              'correct_number': 6,
              'skipped_number': 0,
              'score_percentage': 30,
              'review': 'Answered 6/20 correctly.',
              'esess_flag': null,
              'short_text': 'Enjoy learning math',
              'ai_review_short': 'Practice counting and matching quantities.',
              'ai_review_long': 'Practice with objects at home.',
              'grade': 0,
              'level': 1,
              'last_submitted_dt': '20261001135422.218208',
              'ended_dt': '20261001135422.500244',
              'create_dt': '20261001135345.600811',
            },
            {
              'esess_id': 99,
              'exam_type': 'GRADE',
              'status': 'COMPLETE',
              'total_questions': 10,
              'correct_number': 5,
              'skipped_number': 0,
              'score_percentage': 50,
              'review': 'Answered 5/10 correctly.',
              'esess_flag': true,
              'ai_review_short': 'Practice addition and subtraction.',
              'ai_review_long': 'Use toys to practice at home.',
              'grade': 0,
              'level': 1,
              'last_submitted_dt': '20261001130928.001546',
              'ended_dt': '20261001130928.266769',
              'create_dt': '20261001130907.978867',
            },
          ],
        };
      });

      final stats = await api.getExamStats(
        profileId: 21,
        examTypes: const [examTypeGrade, examTypeAssessment],
      );

      expect(captured.path, '/exams/sessions/list');
      expect(captured.method, 'POST');
      expect(_body(captured), containsPair('profile_id', 21));
      expect(
        _body(captured),
        containsPair('exam_types', ['GRADE', 'ASSESSMENT']),
      );
      expect(_body(captured), isNot(contains('exam_type')));
      expect(stats.map((entry) => entry.userExamId), [101, 99]);
      expect(stats.map((entry) => entry.examType), ['ASSESSMENT', 'GRADE']);
      expect(stats.every((entry) => entry.status == 'COMPLETE'), isTrue);
      expect(stats.first.passed, isNull);
      expect(stats.last.passed, isTrue);
      expect(stats.first.shortText, 'Enjoy learning math');
      final learningItems = stats
          .where(isCompletedAssessmentStats)
          .map((entry) => completedAssessmentFromStats(entry, profileId: 21))
          .toList();
      expect(learningItems.map((entry) => entry.userExamId), [101, 99]);
      expect(learningItems.every((entry) => entry.grade == 0), isTrue);
      expect(learningItems.map((entry) => entry.level), [1, 2]);
    },
  );

  for (final type in [examTypeGrade, examTypePractice]) {
    test('session list sends a single $type in an array', () async {
      late RequestOptions captured;
      final api = _apiReturning((options) {
        captured = options;
        return {'mstatus': 200, 'exam_sessions': <Map<String, dynamic>>[]};
      });
      await api.getExamStats(profileId: 21, examTypes: [type]);
      expect(captured.path, '/exams/sessions/list');
      expect(_body(captured), containsPair('profile_id', 21));
      expect(_body(captured), containsPair('exam_types', [type]));
      expect(_body(captured), isNot(contains('exam_type')));
    });
  }

  test(
    'session review sends IDs and parses AI text from exam_session',
    () async {
      late RequestOptions captured;
      const response = <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'exam_session': <String, dynamic>{
          'esess_id': 99,
          'exam_type': 'GRADE',
          'status': 'COMPLETE',
          'total_questions': 10,
          'correct_number': 5,
          'skipped_number': 0,
          'score_percentage': 50,
          'review': 'Answered 5/10 correctly.',
          'esess_flag': true,
          'title': 'Counting and subtraction',
          'short_text': 'Learn counting and subtraction.',
          'ai_review_short': 'Practice counting and subtraction.',
          'ai_review_long': 'First paragraph.\n\nSecond paragraph.',
          'grade': 0,
          'level': 1,
          'last_submitted_dt': '20261001130928.001546',
          'ended_dt': '20261001130928.266769',
          'create_dt': '20261001130907.978867',
        },
      };
      final api = _apiReturning((options) {
        captured = options;
        return response;
      });
      final result = await api.generateExamSessionAiReview(
        profileId: 21,
        userExamId: 99,
      );
      expect(captured.method, 'POST');
      expect(captured.path, '/exams/sessions/review/generate');
      expect(_body(captured)['profile_id'], 21);
      expect(_body(captured)['esess_id'], 99);
      expect(_body(captured), isNot(contains('exam_type')));
      expect(result, isNotNull);
      expect(result!.userExamId, 99);
      expect(result.examType, examTypeGrade);
      expect(result.status, 'COMPLETE');
      expect(result.grade, 0);
      expect(result.level, 2);
      expect(result.passed, isTrue);
      expect(result.correctNumber, 5);
      expect(result.scorePercentage, 50);
      expect(result.aiReviewShort, 'Practice counting and subtraction.');
      expect(result.title, 'Counting and subtraction');
      expect(result.shortText, 'Learn counting and subtraction.');
      expect(result.aiReviewLong, 'First paragraph.\n\nSecond paragraph.');
      expect(result.endedDt, DateTime.parse('2026-10-01T13:09:28.266769Z'));
    },
  );

  test('session review returns null when exam_session is absent', () async {
    final api = _apiReturning((_) => {'mstatus': 200, 'status': 'Success'});
    expect(
      await api.generateExamSessionAiReview(profileId: 21, userExamId: 99),
      isNull,
    );
  });

  test('session review maps API failure to ExamException', () async {
    final api = _apiReturning(
      (_) => <String, dynamic>{
        'mstatus': 503,
        'mmessage': 'Review unavailable',
      },
    );
    await expectLater(
      api.generateExamSessionAiReview(profileId: 21, userExamId: 99),
      throwsA(
        isA<ExamException>().having((error) => error.status, 'status', 503),
      ),
    );
  });

  test(
    'reads grade roadmap sessions and pass flags for a selected grade',
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
                'last_submitted_dt': '20260930165157.395796',
                'ended_dt': '20260930170645.875089',
                'create_dt': '20260930165020.962157',
              },
          ],
        };
      });

      final sessions = await api.getGradeRoadmap(profileId: 21, grade: 2);

      expect(captured.path, '/exams/grade/roadmap');
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
      expect(latest.level, 2);
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

  test('grade roadmap accepts an empty session history', () async {
    final api = _apiReturning((_) => {'mstatus': 200, 'exam_sessions': []});
    expect(await api.getGradeRoadmap(profileId: 21, grade: 0), isEmpty);
  });

  test('grade roadmap propagates API failure', () async {
    final api = _apiReturning((_) => {'mstatus': 500, 'status': 'Failed'});
    await expectLater(
      api.getGradeRoadmap(profileId: 21, grade: 2),
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
    expect(levels.latestLevel, 2);
    expect(levels.maxLevel, 4);
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
  'exam_session': <String, dynamic>{
    'esess_id': 99,
    'exam_type': 'ASSESSMENT',
    'status': 'ACTIVE',
    'correct_number': 0,
    'score_percentage': 0,
    'skipped_number': 0,
    'total_questions': 0,
    'grade': 2,
    'level': 1,
  },
  'exam': <String, dynamic>{
    'exam_id': 7,
    'elink_id': 2,
    'profile_id': 21,
    'exam_type': 'ASSESSMENT',
    'grade': 2,
    'level': 1,
    'num_questions': 1,
    'status': 'IN_PROGRESS',
    'title': 'Lớp 2 - Cấp độ 1',
    'questions': <Map<String, dynamic>>[
      <String, dynamic>{
        'question_text': '🍓 🍓 🍓 + 🍓 = ?',
        'question_number': 1,
        'question_grade': 2,
        'question_level': 1,
        'question_topic': 'counting',
        'render_type': 'COUNT',

        'correct_answer': {
          'option_ids': ['A'],
        },
        'options': <Map<String, dynamic>>[
          <String, dynamic>{'text': '4', 'id': 'A'},
        ],
      },
    ],
  },
};
