import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/errors/quiz_exception.dart';

const quizPurposeAssessment = 'ASSESSMENT';
const quizPurposePractice = 'PRACTICE';
const quizTypeGeneral = 'GENERAL';
const quizTypeReinforcement = 'REINFORCEMENT';
const assessmentQuizType = quizPurposeAssessment;
const assessmentQuizGradeLabel = 'Grade 1';

abstract class QuizService {
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
    int? profileId,
  });

  Future<List<GeneratedQuiz>> listQuizzes({int? userId, int? profileId});

  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  });

  Future<GeneratedQuiz> getQuizDetail(int quizId);
}

class QuizApi implements QuizService {
  QuizApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
    int? profileId,
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
          profileId: profileId,
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
  Future<List<GeneratedQuiz>> listQuizzes({int? userId, int? profileId}) async {
    if (userId == null && profileId == null) {
      throw QuizException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }

    final QuizListResponse response;
    try {
      response = await _networkApi.listQuizzes(
        QuizListRequest(userId: userId, profileId: profileId),
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
