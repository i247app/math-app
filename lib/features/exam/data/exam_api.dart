import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/assessment_exit_placeholder.dart';
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
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    final validProfileId = _requireProfileId(profileId);
    final normalizedExamType = examType.trim().toUpperCase();
    final validUserExamId = userExamId != null && userExamId > 0
        ? userExamId
        : null;
    if (normalizedExamType == examTypePractice && validUserExamId == null) {
      throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
    }
    final GenerateExamResponseDto response;
    response = await _runExamRequest(
      () => _generateExam(
        GenerateExamRequest(
          profileId: validProfileId,
          numQuestions: AssessmentFlowPolicy.generatedQuestionCount,
          examType: examType,
          grade: _gradeFromLabel(gradeLabel),
          level: (level ?? 1).clamp(1, 10),
          userExamId: normalizedExamType == examTypePractice
              ? validUserExamId
              : null,
        ),
      ),
    );

    final exam = response.exam;
    if (exam == null || exam.questions.isEmpty) {
      throw ExamException(AppStrings.current(AppKeys.examHasNoQuestions));
    }

    return exam.toModel(userExamId: response.userExamId ?? validUserExamId);
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
    String examType = examTypeAssessment,
  }) async {
    if (profileId <= 0) {
      throw ExamException(
        AppStrings.current(AppKeys.missingUserOrProfileForHistory),
      );
    }
    if (toDt.isBefore(fromDt)) {
      throw ExamException(AppStrings.current(AppKeys.invalidServerResponse));
    }

    return _runExamRequest(() async {
      final json = await _postResponse(
        '/exams/stats',
        ExamStatsRequest(profileId: profileId, examType: examType).toJson(),
        (json) => json,
      );
      return examStatsToProgress(
        json,
        fromDt: fromDt,
        toDt: toDt,
        profileId: profileId,
        examType: examType,
      );
    });
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
    String examType = examTypeAssessment,
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
    final normalizedExamType = examType.trim().toUpperCase();
    final validExamType = normalizedExamType.isEmpty
        ? examTypeAssessment
        : normalizedExamType;
    response = await _runExamRequest(
      () => _getExamDetailResponse(
        userAiExamId: validUserAiExamId,
        userExamId: validUserExamId,
        profileId: validProfileId,
        examType: validExamType,
      ),
    );

    final isEntireJourney = validUserExamId != null;
    if (isEntireJourney) {
      final activeExam = _activeJourneyExam(response);
      var detailedActiveExam = _matchingDetailedActiveExam(
        response.exam,
        activeExam,
      );
      detailedActiveExam ??= _matchingDetailedActiveExam(
        activeExam,
        activeExam,
      );
      final activeUserAiExamId = activeExam?.userAiExamId;
      if (activeExam != null &&
          detailedActiveExam == null &&
          activeUserAiExamId != null &&
          activeUserAiExamId > 0) {
        final activeSetResponse = await _runExamRequest(
          () => _getExamDetailResponse(
            userAiExamId: activeUserAiExamId,
            userExamId: null,
            profileId: validProfileId,
            examType: validExamType,
          ),
        );
        detailedActiveExam = _matchingDetailedActiveExam(
          activeSetResponse.exam,
          activeExam,
        );
      }
      return _journeyDetailToModel(
        response,
        validUserExamId,
        detailedActiveExam: detailedActiveExam,
      );
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
      practiceWeakTopics: _practiceWeakTopics(response),
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

  Future<ExamDetailResponseDto> _getExamDetailResponse({
    int? userAiExamId,
    int? userExamId,
    required int profileId,
    required String examType,
  }) {
    return _postResponse('/exams/detail', <String, dynamic>{
      'profile_id': profileId,
      'exam_type': examType,
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
  int userExamId, {
  GeneratedExamDto? detailedActiveExam,
}) {
  final stats = response.stats;
  final activeExam = _activeJourneyExam(response);
  if (activeExam != null) {
    return _activeJourneySetToModel(
      response: response,
      activeExam: detailedActiveExam ?? activeExam,
      activeUserAiExamId: activeExam.userAiExamId,
      activeStatus: stats?.status ?? activeExam.status,
      expectedQuestionCount:
          activeExam.numQuestions ??
          AssessmentFlowPolicy.generatedQuestionCount,
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
    lastSetGrade: lastExam?.grade ?? stats.grade,
    lastSetShortText: lastExam?.shortText,
    practiceWeakTopics: _practiceWeakTopics(response),
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
  required int? activeUserAiExamId,
  required String? activeStatus,
  required int expectedQuestionCount,
  required int userExamId,
}) {
  final activeDetails = response.details
      .where((detail) {
        if (activeUserAiExamId == null) {
          return response.exams.length == 1;
        }
        return detail.userAiExamId == activeUserAiExamId ||
            (detail.userAiExamId == null && response.exams.length == 1);
      })
      .toList(growable: false);
  final hasOnlyExitPlaceholder = isAssessmentExitPlaceholderAnswer(
    answerCount: activeDetails.length,
    questionNumber: activeDetails.firstOrNull?.questionNumber,
    answerLabel: activeDetails.firstOrNull?.selectedLabel,
  );
  final submittedAnswers = <SubmitExamAnswerDto>[
    for (final detail
        in hasOnlyExitPlaceholder
            ? const <ExamDetailAnswerDto>[]
            : activeDetails)
      if (detail.selectedLabel?.trim().isNotEmpty == true)
        SubmitExamAnswerDto(
          questionNumber: detail.questionNumber,
          label: detail.selectedLabel!.trim(),
        ),
  ];
  final resumeQuestionIndex = hasOnlyExitPlaceholder
      ? 0
      : _activeResumeQuestionIndex(
          details: activeDetails,
          questions: activeExam.questions,
        );

  if (activeExam.questions.length >= expectedQuestionCount) {
    return activeExam.toModel(
      submittedAnswers: submittedAnswers,
      stats: response.stats,
      userExamId: userExamId,
      userAiExamIdOverride: activeUserAiExamId,
      examStatusOverride: activeStatus,
      resumeQuestionIndex: resumeQuestionIndex,
      practiceWeakTopics: _practiceWeakTopics(response),
    );
  }
  if (activeDetails.length < expectedQuestionCount) {
    throw ExamException(AppStrings.current(AppKeys.examDetailLoadFailed));
  }

  return GeneratedExam(
    examId: activeUserAiExamId,
    aiExamId: activeExam.aiExamId,
    userAiExamId: activeUserAiExamId,
    userExamId: userExamId,
    profileId: activeExam.profileId,
    examStatus: activeStatus,
    examType: activeExam.examType ?? examTypeAssessment,
    grade: activeExam.grade,
    lastSetGrade: activeExam.grade,
    lastSetShortText: activeExam.shortText,
    practiceWeakTopics: _practiceWeakTopics(response),
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

List<ExamPracticeTopic> _practiceWeakTopics(ExamDetailResponseDto response) {
  return response.practicePreview?.weakTopics
          .map((topic) => topic.toModel())
          .toList(growable: false) ??
      const <ExamPracticeTopic>[];
}

GeneratedExamDto? _activeJourneyExam(ExamDetailResponseDto response) {
  if (response.stats?.status?.trim().toUpperCase() == 'COMPLETE') {
    return null;
  }
  for (final candidate in response.exams.reversed) {
    if (_isActiveExamStatus(candidate.status)) {
      return candidate;
    }
  }

  if (_isActiveExamStatus(response.exam?.status)) {
    return response.exam;
  }

  if (!_isActiveExamStatus(response.stats?.status)) {
    return null;
  }
  if (response.exams.isNotEmpty) {
    return response.exams.last;
  }
  return response.exam;
}

GeneratedExamDto? _matchingDetailedActiveExam(
  GeneratedExamDto? detailedExam,
  GeneratedExamDto? activeExam,
) {
  if (detailedExam == null || detailedExam.questions.isEmpty) {
    return null;
  }
  final expectedQuestionCount =
      activeExam?.numQuestions ??
      detailedExam.numQuestions ??
      AssessmentFlowPolicy.generatedQuestionCount;
  if (detailedExam.questions.length < expectedQuestionCount) {
    return null;
  }
  final detailedId = detailedExam.userAiExamId;
  final activeId = activeExam?.userAiExamId;
  if (detailedId != null && activeId != null && detailedId != activeId) {
    return null;
  }
  return detailedExam;
}

bool _isActiveExamStatus(String? status) {
  final normalizedStatus = status?.trim().toUpperCase();
  return normalizedStatus == 'ACTIVE' || normalizedStatus == 'IN_PROGRESS';
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
