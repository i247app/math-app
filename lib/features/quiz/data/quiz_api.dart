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

  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  });

  Future<QuizProgressResponse> getQuizProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  });

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
    final cleanGradeLabel = gradeLabel?.trim() ?? '';
    response = await _runQuizRequest(
      () => _networkApi.generateQuiz(
        GenerateQuizRequest(
          purpose: purpose,
          typeOfQuiz: typeOfQuiz,
          gradeLabel: previousQuizId == null ? cleanGradeLabel : null,
          previousQuizId: previousQuizId,
          chapters: _cleanChapters(chapters),
          profileId: profileId,
        ),
      ),
    );

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
    response = await _runQuizRequest(
      () => _networkApi.submitQuiz(
        SubmitQuizRequest(
          quizId: quizId,
          answers: answers,
          profileId: profileId,
        ),
      ),
    );

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.submitQuizFailed));
    }

    return quiz;
  }

  @override
  Future<List<GeneratedQuiz>> listQuizzes({int? userId, int? profileId}) async {
    final response = await _listQuizzes(userId: userId, profileId: profileId);
    return response.quizzes;
  }

  @override
  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) {
    return _listQuizzes(
      userId: userId,
      profileId: profileId,
      page: page,
      size: size,
      takeAll: takeAll,
    );
  }

  @override
  Future<QuizProgressResponse> getQuizProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  }) async {
    if (profileId <= 0) {
      throw QuizException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }
    if (toDt.isBefore(fromDt)) {
      throw QuizException(AppStrings.current(AppKeys.invalidServerResponse));
    }

    return _runQuizRequest(
      () => _networkApi.getQuizProgress(
        QuizProgressRequest(
          profileId: profileId,
          fromDt: fromDt.toUtc(),
          toDt: toDt.toUtc(),
        ),
      ),
    );
  }

  Future<QuizListResponse> _listQuizzes({
    int? userId,
    int? profileId,
    int? page,
    int? size,
    bool? takeAll,
  }) async {
    if (userId == null && profileId == null) {
      throw QuizException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }

    final QuizListResponse response;
    response = await _runQuizRequest(
      () => _networkApi.listQuizzes(
        QuizListRequest(
          userId: userId,
          profileId: profileId,
          page: page,
          size: size,
          takeAll: takeAll,
        ),
      ),
    );

    return response;
  }

  @override
  Future<GeneratedQuiz> getQuizDetail(int quizId) async {
    if (quizId <= 0) {
      throw QuizException(AppStrings.current(AppKeys.missingQuizIdShort));
    }

    final QuizDetailResponse response;
    response = await _runQuizRequest(() => _networkApi.getQuizDetail(quizId));

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.quizDetailLoadFailed));
    }

    return quiz;
  }
}

Future<T> _runQuizRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on NetworkException catch (error) {
    throw QuizException(error.message, status: error.status);
  }
}

List<String>? _cleanChapters(List<String>? chapters) {
  final cleanChapters = chapters
      ?.map((chapter) => chapter.trim())
      .where((chapter) => chapter.isNotEmpty)
      .toList();
  return cleanChapters == null || cleanChapters.isEmpty ? null : cleanChapters;
}
