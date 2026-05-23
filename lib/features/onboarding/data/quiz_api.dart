import '../../../core/config/api_config.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/quiz_models.dart';

const assessmentQuizType = 'ASSESSMENT';
const assessmentQuizGradeLabel = 'Grade 1';

class QuizException implements Exception {
  const QuizException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class QuizService {
  Future<GeneratedQuiz> generateAssessmentQuiz({String? previousQuizId});

  Future<GeneratedQuiz> submitQuiz({
    required String quizId,
    required List<SubmitQuizAnswer> answers,
  });
}

class FakeQuizApi implements QuizService {
  const FakeQuizApi();

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({String? previousQuizId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final response = GenerateQuizResponse.fromJson(
      _fakeGenerateQuizResponse(previousQuizId: previousQuizId),
    );
    final quiz = response.quiz;
    if (response.mstatus != 200 || quiz == null || quiz.questions.isEmpty) {
      throw QuizException(
        response.mmessage ?? response.debug ?? 'Quiz không có câu hỏi.',
        status: response.mstatus,
      );
    }

    return quiz;
  }

  @override
  Future<GeneratedQuiz> submitQuiz({
    required String quizId,
    required List<SubmitQuizAnswer> answers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final response = SubmitQuizResponse.fromJson(
      _fakeSubmitQuizResponse(quizId, answers),
    );
    final quiz = response.quiz;
    if (response.mstatus != 200 || quiz == null) {
      throw QuizException(
        response.mmessage ?? response.debug ?? 'Nộp bài thất bại.',
        status: response.mstatus,
      );
    }

    return quiz;
  }
}

class QuizApi implements QuizService {
  QuizApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({String? previousQuizId}) async {
    final GenerateQuizResponse response;
    try {
      response = await _networkApi.generateQuiz(
        GenerateQuizRequest(
          type: assessmentQuizType,
          gradeLabel: previousQuizId == null ? assessmentQuizGradeLabel : null,
          previousQuizId: previousQuizId,
        ),
      );
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    final quiz = response.quiz;
    if (quiz == null || quiz.questions.isEmpty) {
      throw const QuizException('Quiz không có câu hỏi.');
    }

    return quiz;
  }

  @override
  Future<GeneratedQuiz> submitQuiz({
    required String quizId,
    required List<SubmitQuizAnswer> answers,
  }) async {
    final SubmitQuizResponse response;
    try {
      response = await _networkApi.submitQuiz(
        SubmitQuizRequest(
          quizId: quizId,
          answers: answers,
        ),
      );
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    final quiz = response.quiz;
    if (quiz == null) {
      throw const QuizException('Nộp bài thất bại.');
    }

    return quiz;
  }
}

Map<String, Object?> _fakeGenerateQuizResponse({String? previousQuizId}) {
  return <String, Object?>{
    'mstatus': 200,
    'quiz': _fakeGeneratedQuiz(previousQuizId: previousQuizId),
    'status': 'Success',
  };
}

Map<String, Object?> _fakeGeneratedQuiz({String? previousQuizId}) {
  return <String, Object?>{
    'create_dt': '2026-05-21T09:24:04Z',
    'id': 2,
    'modify_dt': '2026-05-21T09:24:04Z',
    'questions': <Object?>[
      <String, Object?>{
        'answers': <Object?>[
          <String, Object?>{'content': '72', 'label': 'A'},
          <String, Object?>{'content': '82', 'label': 'B'},
          <String, Object?>{'content': '83', 'label': 'C'},
          <String, Object?>{'content': '73', 'label': 'D'},
        ],
        'question_name': '45 + 37 = ?',
        'question_number': 1,
      },
      <String, Object?>{
        'answers': <Object?>[
          <String, Object?>{'content': '33', 'label': 'A'},
          <String, Object?>{'content': '48', 'label': 'B'},
          <String, Object?>{'content': '23', 'label': 'C'},
          <String, Object?>{'content': '38', 'label': 'D'},
        ],
        'question_name': '6 * 8 - 15 = ?',
        'question_number': 2,
      },
      <String, Object?>{
        'answers': <Object?>[
          <String, Object?>{'content': '4/12', 'label': 'A'},
          <String, Object?>{'content': '7/8', 'label': 'B'},
          <String, Object?>{'content': '5/8', 'label': 'C'},
          <String, Object?>{'content': '1/2', 'label': 'D'},
        ],
        'question_name': '3/4 + 1/8 = ?',
        'question_number': 3,
      },
      <String, Object?>{
        'answers': <Object?>[
          <String, Object?>{'content': '100', 'label': 'A'},
          <String, Object?>{'content': '90', 'label': 'B'},
          <String, Object?>{'content': '80', 'label': 'C'},
          <String, Object?>{'content': '110', 'label': 'D'},
        ],
        'question_name': '125 / 5 + 75 = ?',
        'question_number': 4,
      },
      <String, Object?>{
        'answers': <Object?>[
          <String, Object?>{'content': '15', 'label': 'A'},
          <String, Object?>{'content': '25', 'label': 'B'},
          <String, Object?>{'content': '75', 'label': 'C'},
          <String, Object?>{'content': '20', 'label': 'D'},
        ],
        'question_name': '(100 - 25) / 5 = ?',
        'question_number': 5,
      },
    ],
    'quiz_id': previousQuizId == null
        ? '310f18bc-5933-4517-848f-fe4c096d6492'
        : 'fake-assessment-retake-1',
    'quiz_status': 'GENERATED',
    'type': assessmentQuizType,
  };
}

Map<String, Object?> _fakeSubmitQuizResponse(
  String quizId,
  List<SubmitQuizAnswer> answers,
) {
  final quiz = _fakeGeneratedQuiz();
  quiz
    ..['answers'] = answers.map((answer) => answer.toJson()).toList()
    ..['modify_dt'] = '2026-05-22T05:02:31Z'
    ..['quiz_id'] = quizId
    ..['quiz_status'] = 'SUBMITTED'
    ..['user_id'] = 'fake-user'
    ..['grading'] = <String, Object?>{
      'ai_review':
          'Bé làm rất tốt phần phép cộng, hãy tiếp tục phát huy nhé! Chúng ta chỉ cần luyện tập thêm một chút ở các phép trừ có nhớ thôi.',
      'correct_number': 4,
      'score_percentage': 80,
      'total_questions': 5,
    };

  return <String, Object?>{
    'mstatus': 200,
    'quiz': quiz,
    'status': 'Success',
  };
}
