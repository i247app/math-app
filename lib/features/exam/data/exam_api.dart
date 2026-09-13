import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_exception.dart';

class ExamApi implements ExamService {
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
          numQuestions: AssessmentFlowPolicy.generatedQuestionCount,
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

    return exam.toModel(userExamId: response.userExamId);
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
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {
    if (userExamId <= 0) {
      throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
    }
    await _runExamRequest(() async {
      final json = await _networkClient
          .postJson('/exams/update-user-exam-status', <String, dynamic>{
            'profile_id': _requireProfileId(profileId),
            'user_exam_id': userExamId,
            'status': status,
          });
      NetworkClient.throwForApiStatus(json);
    });
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
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
  }) async {
    final validUserExamId = userExamId != null && userExamId > 0
        ? userExamId
        : null;
    final validUserAiExamId = validUserExamId == null && detailId > 0
        ? detailId
        : null;
    if (validUserExamId == null && validUserAiExamId == null) {
      throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
    }

    final ExamDetailResponseDto response;
    final validProfileId = _requireProfileId(profileId);
    response = await _runExamRequest(
      () => _getExamDetailResponse(
        userAiExamId: validUserAiExamId,
        userExamId: validUserExamId,
        profileId: validProfileId,
      ),
    );

    final isEntireJourney = validUserExamId != null;
    if (isEntireJourney) {
      return _journeyDetailToModel(response, validUserExamId);
    }

    final exam = response.exam;
    if (exam == null) {
      throw ExamException(AppStrings.current(AppKeys.examDetailLoadFailed));
    }

    final submittedAnswers = <SubmitExamAnswerDto>[
      for (var index = 0; index < response.details.length; index++)
        if (response.details[index].selectedLabel?.trim().isNotEmpty == true)
          SubmitExamAnswerDto(
            questionNumber: isEntireJourney
                ? index + 1
                : response.details[index].questionNumber,
            label: response.details[index].selectedLabel!.trim(),
          ),
    ];
    return exam.toModel(
      submittedAnswers: submittedAnswers,
      useSequentialQuestionNumbers: isEntireJourney,
      userExamId: validUserExamId,
    );
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
    int? userAiExamId,
    int? userExamId,
    required int profileId,
  }) {
    return _postResponse('/exams/detail', <String, dynamic>{
      'profile_id': profileId,
      'user_ai_exam_id': ?userAiExamId,
      'user_exam_id': ?userExamId,
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

GeneratedExam _journeyDetailToModel(
  ExamDetailResponseDto response,
  int userExamId,
) {
  final stats = response.stats;
  GeneratedExamDto? activeExam;
  for (final candidate in response.exams.reversed) {
    final status = candidate.status?.trim().toUpperCase();
    if (status == 'ACTIVE' || status == 'IN_PROGRESS') {
      activeExam = candidate;
      break;
    }
  }
  final journeyStatus = stats?.status?.trim().toUpperCase();
  if (activeExam == null &&
      (journeyStatus == 'ACTIVE' || journeyStatus == 'IN_PROGRESS') &&
      response.exams.isNotEmpty) {
    activeExam = response.exams.last;
  }
  if (activeExam != null) {
    return _activeJourneySetToModel(
      response: response,
      activeExam: activeExam,
      userExamId: userExamId,
    );
  }

  if (stats == null || response.details.isEmpty) {
    throw ExamException(AppStrings.current(AppKeys.examDetailLoadFailed));
  }

  final sourceExams = response.exams;
  final firstExam = sourceExams.isEmpty ? null : sourceExams.first;
  final lastExam = sourceExams.isEmpty ? null : sourceExams.last;
  final questions = <ExamQuestion>[
    for (var index = 0; index < response.details.length; index++)
      response.details[index].toQuestionModel(questionNumber: index + 1),
  ];
  final submittedAnswers = <SubmitExamAnswer>[
    for (var index = 0; index < response.details.length; index++)
      if (response.details[index].selectedLabel?.trim().isNotEmpty == true)
        SubmitExamAnswer(
          questionNumber: index + 1,
          label: response.details[index].selectedLabel!.trim(),
        ),
  ];

  return GeneratedExam(
    profileId: lastExam?.profileId ?? firstExam?.profileId,
    examStatus: stats.status,
    examType: stats.examType ?? lastExam?.examType ?? examTypeAssessment,
    userExamId: userExamId,
    grade: stats.grade ?? lastExam?.grade,
    level: stats.level ?? lastExam?.level,
    numQuestions: stats.totalQuestions,
    title: lastExam?.title,
    shortText: stats.review ?? lastExam?.shortText,
    createDt: firstExam?.createDt ?? firstExam?.startedDt,
    modifyDt: stats.lastSubmittedDt?.toIso8601String() ?? lastExam?.submittedDt,
    startedDt: firstExam?.startedDt,
    submittedDt: lastExam?.submittedDt,
    grading: ExamGrading(
      aiDetectGrade: stats.grade == null ? null : 'Lớp ${stats.grade}',
      aiReview: stats.review,
      correctNumber: stats.correctNumber,
      scorePercentage: stats.scorePercentage.round(),
      skippedNumber: stats.skippedNumber,
      totalQuestions: stats.totalQuestions,
    ),
    answers: submittedAnswers,
    questions: questions,
  );
}

GeneratedExam _activeJourneySetToModel({
  required ExamDetailResponseDto response,
  required GeneratedExamDto activeExam,
  required int userExamId,
}) {
  final activeUserAiExamId = activeExam.userAiExamId;
  final activeDetails = response.details
      .where((detail) {
        if (activeUserAiExamId == null) {
          return response.exams.length == 1;
        }
        return detail.userAiExamId == activeUserAiExamId ||
            (detail.userAiExamId == null && response.exams.length == 1);
      })
      .toList(growable: false);
  final submittedAnswers = <SubmitExamAnswerDto>[
    for (final detail in activeDetails)
      if (detail.selectedLabel?.trim().isNotEmpty == true)
        SubmitExamAnswerDto(
          questionNumber: detail.questionNumber,
          label: detail.selectedLabel!.trim(),
        ),
  ];
  final resumeQuestionIndex = _activeResumeQuestionIndex(
    details: activeDetails,
    questions: activeExam.questions,
  );

  if (activeExam.questions.isNotEmpty) {
    return activeExam.toModel(
      submittedAnswers: submittedAnswers,
      stats: response.stats,
      userExamId: userExamId,
      resumeQuestionIndex: resumeQuestionIndex,
    );
  }
  if (activeDetails.isEmpty) {
    throw ExamException(AppStrings.current(AppKeys.examDetailLoadFailed));
  }

  return GeneratedExam(
    examId: activeExam.userAiExamId,
    aiExamId: activeExam.aiExamId,
    userAiExamId: activeExam.userAiExamId,
    userExamId: userExamId,
    profileId: activeExam.profileId,
    examStatus: activeExam.status,
    examType: activeExam.examType ?? examTypeAssessment,
    grade: activeExam.grade,
    level: activeExam.level,
    numQuestions: activeDetails.length,
    title: activeExam.title,
    shortText: activeExam.shortText,
    createDt: activeExam.createDt,
    startedDt: activeExam.startedDt,
    answers: submittedAnswers
        .map(
          (answer) => SubmitExamAnswer(
            questionNumber: answer.questionNumber,
            label: answer.label,
          ),
        )
        .toList(growable: false),
    resumeQuestionIndex: _activeResumeQuestionIndex(
      details: activeDetails,
      questions: const <ExamQuestionDto>[],
      questionCount: activeDetails.length,
    ),
    questions: activeDetails
        .map(
          (detail) =>
              detail.toQuestionModel(questionNumber: detail.questionNumber),
        )
        .toList(growable: false),
  );
}

int? _activeResumeQuestionIndex({
  required List<ExamDetailAnswerDto> details,
  required List<ExamQuestionDto> questions,
  int? questionCount,
}) {
  if (details.isEmpty) {
    return null;
  }
  final totalQuestions = questionCount ?? questions.length;
  if (totalQuestions <= 0) {
    return null;
  }
  final furthestQuestionNumber = details.fold<int>(
    0,
    (furthest, detail) =>
        detail.questionNumber > furthest ? detail.questionNumber : furthest,
  );
  if (furthestQuestionNumber <= 0) {
    return null;
  }
  if (questions.isNotEmpty) {
    final nextIndex = questions.indexWhere(
      (question) => question.questionNumber == furthestQuestionNumber + 1,
    );
    if (nextIndex >= 0) {
      return nextIndex;
    }
  }
  return furthestQuestionNumber.clamp(0, totalQuestions - 1);
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
  return AssessmentFlowPolicy.gradeFromLabel(gradeLabel);
}
