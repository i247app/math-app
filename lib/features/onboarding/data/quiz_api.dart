import '../../../core/config/api_config.dart';
import '../../../core/localization/app_keys.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/quiz_models.dart';

const quizPurposeAssessment = 'ASSESSMENT';
const quizPurposePractice = 'PRACTICE';
const quizTypeGeneral = 'GENERAL';
const quizTypeReinforcement = 'REINFORCEMENT';
const assessmentQuizType = quizPurposeAssessment;
const assessmentQuizGradeLabel = 'Grade 1';

class QuizException implements Exception {
  const QuizException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class QuizService {
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
  });

  Future<List<GeneratedQuiz>> listQuizzes({
    int? userId,
    int? profileId,
  });

  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  });

  Future<GeneratedQuiz> getQuizDetail(int quizId);
}

class FakeQuizApi implements QuizService {
  const FakeQuizApi();

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final response = GenerateQuizResponse.fromJson(
      _fakeGenerateQuizResponse(
        purpose: purpose,
        typeOfQuiz: typeOfQuiz,
        gradeLabel: gradeLabel,
        previousQuizId: previousQuizId,
        chapters: chapters,
      ),
    );
    final quiz = response.quiz;
    if (response.mstatus != 200 || quiz == null || quiz.questions.isEmpty) {
      throw QuizException(
        response.mmessage ??
            response.debug ??
            AppStrings.current(AppKeys.quizHasNoQuestions),
        status: response.mstatus,
      );
    }

    return quiz;
  }

  @override
  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final response = SubmitQuizResponse.fromJson(
      _fakeSubmitQuizResponse(quizId, answers),
    );
    final quiz = response.quiz;
    if (response.mstatus != 200 || quiz == null) {
      throw QuizException(
        response.mmessage ??
            response.debug ??
            AppStrings.current(AppKeys.submitQuizFailed),
        status: response.mstatus,
      );
    }

    return quiz;
  }

  @override
  Future<List<GeneratedQuiz>> listQuizzes({
    int? userId,
    int? profileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final response = QuizListResponse.fromJson(_fakeQuizListResponse());
    if (response.mstatus != 200) {
      throw QuizException(
        response.mmessage ??
            response.debug ??
            AppStrings.current(AppKeys.historyLoadFailed),
        status: response.mstatus,
      );
    }

    return response.quizzes;
  }

  @override
  Future<GeneratedQuiz> getQuizDetail(int quizId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final response = QuizListResponse.fromJson(_fakeQuizListResponse());
    if (response.mstatus != 200 || response.quizzes.isEmpty) {
      throw QuizException(
        response.mmessage ??
            response.debug ??
            AppStrings.current(AppKeys.quizDetailLoadFailed),
        status: response.mstatus,
      );
    }

    return response.quizzes.first;
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
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
  }) async {
    final GenerateQuizResponse response;
    final cleanGradeLabel = gradeLabel?.trim();
    try {
      response = await _networkApi.generateQuiz(
        GenerateQuizRequest(
          purpose: purpose,
          typeOfQuiz: typeOfQuiz,
          gradeLabel: previousQuizId == null
              ? cleanGradeLabel?.isNotEmpty == true
                  ? cleanGradeLabel
                  : assessmentQuizGradeLabel
              : null,
          previousQuizId: previousQuizId,
          chapters: _cleanChapters(chapters),
        ),
      );
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    final quiz = response.quiz;
    if (quiz == null || quiz.questions.isEmpty) {
      throw QuizException(AppStrings.current(AppKeys.quizHasNoQuestions));
    }

    return quiz;
  }

  @override
  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  }) async {
    final SubmitQuizResponse response;
    try {
      response = await _networkApi.submitQuiz(
        SubmitQuizRequest(
          quizId: quizId,
          answers: answers,
          profileId: profileId,
        ),
      );
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.submitQuizFailed));
    }

    return quiz;
  }

  @override
  Future<List<GeneratedQuiz>> listQuizzes({
    int? userId,
    int? profileId,
  }) async {
    if (userId == null && profileId == null) {
      throw QuizException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }

    final QuizListResponse response;
    try {
      response = await _networkApi.listQuizzes(
        QuizListRequest(
          userId: userId,
          profileId: profileId,
        ),
      );
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    return response.quizzes;
  }

  @override
  Future<GeneratedQuiz> getQuizDetail(int quizId) async {
    if (quizId <= 0) {
      throw QuizException(AppStrings.current(AppKeys.missingQuizIdShort));
    }

    final QuizDetailResponse response;
    try {
      response = await _networkApi.getQuizDetail(quizId);
    } on NetworkException catch (error) {
      throw QuizException(error.message, status: error.status);
    }

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.quizDetailLoadFailed));
    }

    return quiz;
  }
}

List<String>? _cleanChapters(List<String>? chapters) {
  final cleanChapters = chapters
      ?.map((chapter) => chapter.trim())
      .where((chapter) => chapter.isNotEmpty)
      .toList();
  return cleanChapters == null || cleanChapters.isEmpty ? null : cleanChapters;
}

Map<String, Object?> _fakeGenerateQuizResponse({
  String purpose = quizPurposeAssessment,
  String typeOfQuiz = quizTypeGeneral,
  String? gradeLabel,
  int? previousQuizId,
  List<String>? chapters,
}) {
  return <String, Object?>{
    'mstatus': 200,
    'quiz': _fakeGeneratedQuiz(
      purpose: purpose,
      typeOfQuiz: typeOfQuiz,
      gradeLabel: gradeLabel,
      previousQuizId: previousQuizId,
    ),
    'status': 'Success',
  };
}

Map<String, Object?> _fakeGeneratedQuiz({
  String purpose = quizPurposeAssessment,
  String typeOfQuiz = quizTypeGeneral,
  String? gradeLabel,
  int? previousQuizId,
}) {
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
        'right_answer': 'B',
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
        'right_answer': 'B',
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
        'right_answer': 'B',
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
        'right_answer': 'A',
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
        'right_answer': 'A',
      },
    ],
    'quiz_id': previousQuizId ?? 310,
    'quiz_status': 'GENERATED',
    'purpose': purpose,
    'type': purpose,
    'type_of_quiz': typeOfQuiz,
    'grading': gradeLabel == null
        ? null
        : <String, Object?>{'ai_detect_grade': gradeLabel},
  };
}

Map<String, Object?> _fakeSubmitQuizResponse(
  int quizId,
  List<SubmitQuizAnswer> answers,
) {
  final quiz = _fakeGeneratedQuiz();
  quiz
    ..['answers'] = answers.map((answer) => answer.toJson()).toList()
    ..['modify_dt'] = '2026-05-22T05:02:31Z'
    ..['quiz_id'] = quizId
    ..['quiz_status'] = 'SUBMITTED'
    ..['user_id'] = 1
    ..['grading'] = <String, Object?>{
      'ai_review': AppStrings.current(AppKeys.defaultAiReview),
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

Map<String, Object?> _fakeQuizListResponse() {
  final submittedAssessment = _fakeGeneratedQuiz()
    ..['answers'] = <Object?>[
      <String, Object?>{'question_number': 1, 'label': 'A'},
      <String, Object?>{'question_number': 2, 'label': 'B'},
      <String, Object?>{'question_number': 3, 'label': 'C'},
      <String, Object?>{'question_number': 4, 'label': 'A'},
      <String, Object?>{'question_number': 5, 'label': 'B'},
    ]
    ..['create_dt'] = '2026-05-23T11:28:10Z'
    ..['modify_dt'] = '2026-05-23T11:28:32Z'
    ..['quiz_id'] = 201
    ..['quiz_status'] = 'SUBMITTED'
    ..['purpose'] = quizPurposeAssessment
    ..['type'] = quizPurposeAssessment
    ..['type_of_quiz'] = quizTypeGeneral
    ..['user_id'] = 1
    ..['grading'] = <String, Object?>{
      'ai_detect_grade': assessmentQuizGradeLabel,
      'ai_review':
          'Good addition and subtraction skills; improve accuracy on addition problems.',
      'correct_number': 4,
      'score_percentage': 80,
      'total_questions': 5,
    };

  final generatedAssessment = _fakeGeneratedQuiz()
    ..['create_dt'] = '2026-05-23T11:28:43Z'
    ..['modify_dt'] = '2026-05-23T11:28:43Z'
    ..['previous_quiz_id'] = 201
    ..['quiz_id'] = 202
    ..['quiz_status'] = 'GENERATED'
    ..['purpose'] = quizPurposeAssessment
    ..['type'] = quizPurposeAssessment
    ..['type_of_quiz'] = quizTypeReinforcement
    ..['user_id'] = 1;

  final practiceQuiz = _fakeGeneratedQuiz()
    ..['create_dt'] = '2026-05-23T05:46:05Z'
    ..['modify_dt'] = '2026-05-23T05:46:32Z'
    ..['quiz_id'] = 203
    ..['quiz_status'] = 'SUBMITTED'
    ..['purpose'] = quizPurposePractice
    ..['type'] = quizPurposePractice
    ..['type_of_quiz'] = quizTypeGeneral
    ..['user_id'] = 1
    ..['grading'] = <String, Object?>{
      'ai_review':
          'Strong understanding of addition and subtraction; practice more on addition with larger numbers.',
      'correct_number': 5,
      'score_percentage': 100,
      'total_questions': 5,
    };

  return <String, Object?>{
    'mstatus': 200,
    'pagination': <String, Object?>{
      'has_next': false,
      'has_previous': false,
      'page': 1,
      'size': 20,
      'skip': 0,
      'take_all': false,
      'total_count': 3,
      'total_pages': 1,
    },
    'quizzes': <Object?>[
      generatedAssessment,
      submittedAssessment,
      practiceQuiz,
    ],
    'status': 'Success',
  };
}
