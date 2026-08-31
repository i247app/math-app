import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/data/mappers/quiz_mapper.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/errors/quiz_exception.dart';

class QuizApi implements QuizService {
  QuizApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
    int? profileId,
  }) async {
    final GenerateQuizResponseDto response;
    final cleanGradeLabel = gradeLabel?.trim() ?? '';
    response = await _runQuizRequest(
      () => _generateQuiz(
        GenerateQuizRequest(
          purpose: purpose,
          typeOfQuiz: typeOfQuiz,
          gradeLabel: cleanGradeLabel,
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

    return quiz.toDomain();
  }

  @override
  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  }) async {
    final SubmitQuizResponseDto response;
    response = await _runQuizRequest(
      () => _submitQuiz(
        SubmitQuizRequest(
          quizId: quizId,
          answers: answers.map((answer) => answer.toDto()).toList(),
          profileId: profileId,
        ),
      ),
    );

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.submitQuizFailed));
    }

    return quiz.toDomain();
  }

  @override
  Future<List<GeneratedQuiz>> listQuizzes({int? userId, int? profileId}) async {
    final response = await _listQuizzes(userId: userId, profileId: profileId);
    return response.quizzes.map((quiz) => quiz.toDomain()).toList();
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
    ).then((response) => response.toDomain());
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
      () => _getQuizProgressResponse(
        QuizProgressRequest(
          profileId: profileId,
          fromDt: fromDt.toUtc(),
          toDt: toDt.toUtc(),
          purpose: quizPurposeAssessment,
        ),
      ),
    ).then((response) => response.toDomain());
  }

  Future<QuizListResponseDto> _listQuizzes({
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

    final QuizListResponseDto response;
    response = await _runQuizRequest(
      () => _listQuizResponse(
        QuizListRequest(
          userId: userId,
          profileId: profileId,
          page: page,
          size: size,
          takeAll: takeAll,
          purpose: quizPurposeAssessment,
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

    final QuizDetailResponseDto response;
    response = await _runQuizRequest(() => _getQuizDetailResponse(quizId));

    final quiz = response.quiz;
    if (quiz == null) {
      throw QuizException(AppStrings.current(AppKeys.quizDetailLoadFailed));
    }

    return quiz.toDomain();
  }

  Future<GenerateQuizResponseDto> _generateQuiz(GenerateQuizRequest request) {
    return _postResponse(
      '/quizzes/generate',
      request.toJson(),
      GenerateQuizResponseDto.fromJson,
      receiveTimeout: const Duration(seconds: 90),
    );
  }

  Future<SubmitQuizResponseDto> _submitQuiz(SubmitQuizRequest request) {
    return _postResponse(
      '/quizzes/submit',
      request.toJson(),
      SubmitQuizResponseDto.fromJson,
      receiveTimeout: const Duration(seconds: 90),
    );
  }

  Future<QuizListResponseDto> _listQuizResponse(QuizListRequest request) {
    return _postResponse(
      '/quizzes/list',
      request.toJson(),
      QuizListResponseDto.fromJson,
    );
  }

  Future<QuizProgressResponseDto> _getQuizProgressResponse(
    QuizProgressRequest request,
  ) {
    return _postResponse(
      '/quizzes/analytics/progress',
      request.toJson(),
      QuizProgressResponseDto.fromJson,
    );
  }

  Future<QuizDetailResponseDto> _getQuizDetailResponse(int quizId) {
    return _postResponse('/quizzes/detail', <String, dynamic>{
      'quiz_id': quizId,
    }, QuizDetailResponseDto.fromJson);
  }

  Future<T> _postResponse<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson, {
    Duration? receiveTimeout,
  }) async {
    final json = await _networkClient.postJson(
      path,
      body,
      receiveTimeout: receiveTimeout,
    );
    NetworkClient.throwForApiStatus(json);
    return fromJson(json);
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
