import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_exception.dart';

class ExamApi implements ExamService, ExamStatsService {
  ExamApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
  }) async {
    final validProfileId = _requireProfileId(profileId);
    final GenerateExamResponseDto response;
    response = await _runExamRequest(
      () => _generateExam(
        GenerateExamRequest(
          profileId: validProfileId,
          numQuestions: 10,
          examType: examType,
          grade: _gradeFromLabel(gradeLabel),
          level: 1,
        ),
      ),
    );

    final exam = response.exam;
    if (exam == null || exam.questions.isEmpty) {
      throw ExamException(AppStrings.current(AppKeys.examHasNoQuestions));
    }

    return exam.toModel();
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    final validProfileId = _requireProfileId(profileId);
    final submittedAnswers = answers.map((answer) => answer.toDto()).toList();
    final SubmitExamResponseDto response;
    response = await _runExamRequest(
      () => _submitExam(
        SubmitExamRequest(
          profileId: validProfileId,
          userAiExamId: examId,
          answers: submittedAnswers,
        ),
      ),
    );

    final exam = response.exam;
    if (exam == null) {
      throw ExamException(AppStrings.current(AppKeys.submitExamFailed));
    }

    return exam.toModel(
      submittedAnswers: submittedAnswers,
      stats: response.stats,
    );
  }

  @override
  Future<List<GeneratedExam>> listExams({int? userId, int? profileId}) async {
    final response = await _listExams(userId: userId, profileId: profileId);
    return response.exams.map((exam) => exam.toModel()).toList();
  }

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) {
    return _listExams(
      userId: userId,
      profileId: profileId,
      page: page,
      size: size,
      takeAll: takeAll,
    ).then((response) => response.toModel());
  }

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  }) async {
    if (profileId <= 0) {
      throw ExamException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }
    if (toDt.isBefore(fromDt)) {
      throw ExamException(AppStrings.current(AppKeys.invalidServerResponse));
    }

    return _runExamRequest(
      () => _getExamProgressResponse(
        ExamProgressRequest(
          profileId: profileId,
          fromDt: fromDt.toUtc(),
          toDt: toDt.toUtc(),
          examType: examTypeAssessment,
        ),
      ),
    ).then((response) => response.toModel());
  }

  Future<ExamListResponseDto> _listExams({
    int? userId,
    int? profileId,
    int? page,
    int? size,
    bool? takeAll,
  }) async {
    final validProfileId = _requireProfileId(profileId);

    final ExamListResponseDto response;
    response = await _runExamRequest(
      () => _listExamResponse(
        ExamListRequest(
          profileId: validProfileId,
          page: page,
          size: size,
          takeAll: takeAll,
          examType: examTypeAssessment,
        ),
      ),
    );

    return response;
  }

  @override
  Future<GeneratedExam> getExamDetail(int examId, {int? profileId}) async {
    if (examId <= 0) {
      throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
    }

    final ExamDetailResponseDto response;
    final validProfileId = _requireProfileId(profileId);
    response = await _runExamRequest(
      () => _getExamDetailResponse(
        userAiExamId: examId,
        profileId: validProfileId,
      ),
    );

    final exam = response.exam;
    if (exam == null) {
      throw ExamException(AppStrings.current(AppKeys.examDetailLoadFailed));
    }

    final submittedAnswers = response.details
        .where((detail) => detail.selectedLabel?.trim().isNotEmpty == true)
        .map(
          (detail) => SubmitExamAnswerDto(
            questionNumber: detail.questionNumber,
            label: detail.selectedLabel!.trim(),
          ),
        )
        .toList();
    return exam.toModel(submittedAnswers: submittedAnswers);
  }

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    final response = await _runExamRequest(
      () => _getExamStatsResponse(
        ExamStatsRequest(
          profileId: _requireProfileId(profileId),
          examType: examType,
        ),
      ),
    );
    return response.stats.map((stats) => stats.toModel()).toList();
  }

  Future<GenerateExamResponseDto> _generateExam(GenerateExamRequest request) {
    return _postResponse(
      '/exams/generate',
      request.toJson(),
      GenerateExamResponseDto.fromJson,
      receiveTimeout: const Duration(seconds: 90),
    );
  }

  Future<SubmitExamResponseDto> _submitExam(SubmitExamRequest request) {
    return _postResponse(
      '/exams/submit',
      request.toJson(),
      SubmitExamResponseDto.fromJson,
      receiveTimeout: const Duration(seconds: 90),
    );
  }

  Future<ExamListResponseDto> _listExamResponse(ExamListRequest request) {
    return _postResponse(
      '/exams/list',
      request.toJson(),
      ExamListResponseDto.fromJson,
    );
  }

  Future<ExamProgressResponseDto> _getExamProgressResponse(
    ExamProgressRequest request,
  ) {
    return _postResponse(
      '/exams/analytics/progress',
      request.toJson(),
      ExamProgressResponseDto.fromJson,
    );
  }

  Future<ExamDetailResponseDto> _getExamDetailResponse({
    required int userAiExamId,
    required int profileId,
  }) {
    return _postResponse('/exams/detail', <String, dynamic>{
      'profile_id': profileId,
      'user_ai_exam_id': userAiExamId,
    }, ExamDetailResponseDto.fromJson);
  }

  Future<ExamStatsResponseDto> _getExamStatsResponse(ExamStatsRequest request) {
    return _postResponse(
      '/exams/stats',
      request.toJson(),
      ExamStatsResponseDto.fromJson,
    );
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

Future<T> _runExamRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on NetworkException catch (error) {
    throw ExamException(error.message, status: error.status);
  }
}

int _requireProfileId(int? profileId) {
  if (profileId == null || profileId <= 0) {
    throw ExamException(
      AppStrings.current(AppKeys.missingUserOrProfileForHistory),
    );
  }
  return profileId;
}

int _gradeFromLabel(String? gradeLabel) {
  final match = RegExp(r'\d+').firstMatch(gradeLabel?.trim() ?? '');
  return int.tryParse(match?.group(0) ?? '') ?? 1;
}
