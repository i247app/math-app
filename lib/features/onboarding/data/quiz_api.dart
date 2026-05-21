import '../../../core/config/api_config.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/quiz_models.dart';

const practiceQuizType = 'PRACTICE';
const practiceQuizGradeLabel = 'Grade 1';

class QuizException implements Exception {
  const QuizException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class QuizService {
  Future<GeneratedQuiz> generatePracticeQuiz();
}

class FakeQuizApi implements QuizService {
  const FakeQuizApi();

  @override
  Future<GeneratedQuiz> generatePracticeQuiz() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final response = GenerateQuizResponse.fromJson(_fakeGenerateQuizResponse);
    final quiz = response.quiz;
    if (response.mstatus != 200 || quiz == null || quiz.questions.isEmpty) {
      throw QuizException(
        response.mmessage ?? response.debug ?? 'Quiz không có câu hỏi.',
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
  Future<GeneratedQuiz> generatePracticeQuiz() async {
    final GenerateQuizResponse response;
    try {
      response = await _networkApi.generateQuiz(
        const GenerateQuizRequest(
          type: practiceQuizType,
          gradeLabel: practiceQuizGradeLabel,
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
}

const _fakeGenerateQuizResponse = <String, Object?>{
  'mstatus': 200,
  'quiz': <String, Object?>{
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
    'quiz_id': '310f18bc-5933-4517-848f-fe4c096d6492',
    'quiz_status': 'GENERATED',
    'type': practiceQuizType,
  },
  'status': 'Success',
};
