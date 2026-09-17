import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/models/exam.dart';

extension SubmitExamAnswerConversion on SubmitExamAnswer {
  SubmitExamAnswerDto toDto() =>
      SubmitExamAnswerDto(questionNumber: questionNumber, label: label);
}

extension ExamAnswerDtoConversion on ExamAnswerDto {
  ExamAnswer toModel() => ExamAnswer(content: content, label: label);
}

extension ExamQuestionDtoConversion on ExamQuestionDto {
  ExamQuestion toModel({int? questionNumberOverride}) => ExamQuestion(
    questionName: questionName,
    questionNumber: questionNumberOverride ?? questionNumber,
    answers: answers.map((answer) => answer.toModel()).toList(),
    rightAnswer: rightAnswerLabel,
    correctAnswer: rightAnswerContent,
    difficulty: questionLevel,
    topic: questionTopic,
  );
}

extension ExamDetailAnswerDtoConversion on ExamDetailAnswerDto {
  ExamQuestion toQuestionModel({required int questionNumber}) {
    final answersByLabel = <String, String>{
      for (final answer in this.answers)
        if (answer.label.trim().isNotEmpty)
          answer.label.trim().toUpperCase(): answer.content.trim(),
    };

    void addAnswer(String? label, String? content) {
      final normalizedLabel = label?.trim().toUpperCase();
      if (normalizedLabel == null || normalizedLabel.isEmpty) {
        return;
      }
      answersByLabel[normalizedLabel] = content?.trim() ?? '';
    }

    addAnswer(rightAnswerLabel, rightAnswerContent);
    addAnswer(selectedLabel, selectedContent);
    final answers = answersByLabel.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ExamQuestion(
      questionName: questionName?.trim() ?? '',
      questionNumber: questionNumber,
      answers: answers
          .map((answer) => ExamAnswer(label: answer.key, content: answer.value))
          .toList(growable: false),
      rightAnswer: rightAnswerLabel,
      correctAnswer: rightAnswerContent,
      difficulty: questionLevel,
      topic: questionTopic,
    );
  }
}

extension ExamResultDtoConversion on ExamResultDto {
  ExamGrading toModel({String? review, int? grade}) => ExamGrading(
    aiDetectGrade: grade == null ? null : 'Lớp $grade',
    aiReview: review,
    correctNumber: correctNumber,
    scorePercentage: scorePercentage,
    skippedNumber: skippedNumber,
    totalQuestions: totalQuestions,
  );
}

extension ExamPracticeTopicDtoConversion on ExamPracticeTopicDto {
  ExamPracticeTopic toModel() =>
      ExamPracticeTopic(topic: topic, answered: answered, wrong: wrong);
}

extension GeneratedExamDtoConversion on GeneratedExamDto {
  GeneratedExam toModel({
    List<SubmitExamAnswerDto> submittedAnswers = const <SubmitExamAnswerDto>[],
    ExamStatsDto? stats,
    bool useSequentialQuestionNumbers = false,
    int? userExamId,
    int? userAiExamIdOverride,
    String? examStatusOverride,
    int? resumeQuestionIndex,
    List<ExamPracticeTopic> practiceWeakTopics = const <ExamPracticeTopic>[],
  }) => GeneratedExam(
    id: userAiExamIdOverride ?? userAiExamId,
    examId: userAiExamIdOverride ?? userAiExamId,
    profileId: profileId,
    examStatus: examStatusOverride ?? status,
    examType: examType,
    title: title,
    shortText: shortText,
    createDt: createDt,
    modifyDt: submittedDt,
    aiExamId: aiExamId,
    userAiExamId: userAiExamIdOverride ?? userAiExamId,
    userExamId: userExamId ?? this.userExamId ?? stats?.userExamId,
    grade: grade,
    lastSetGrade: grade,
    lastSetShortText: shortText,
    practiceWeakTopics: practiceWeakTopics,
    level: level,
    numQuestions: numQuestions,
    startedDt: startedDt,
    submittedDt: submittedDt,
    grading: result?.toModel(review: stats?.review, grade: grade),
    answers: submittedAnswers
        .map(
          (answer) => SubmitExamAnswer(
            questionNumber: answer.questionNumber,
            label: answer.label,
          ),
        )
        .toList(),
    resumeQuestionIndex: resumeQuestionIndex,
    questions: questions.indexed
        .map(
          (entry) => entry.$2.toModel(
            questionNumberOverride: useSequentialQuestionNumbers
                ? entry.$1 + 1
                : null,
          ),
        )
        .toList(),
  );
}

extension ExamPaginationDtoConversion on ExamPaginationDto {
  ExamPagination toModel() => ExamPagination(
    hasNext: hasNext,
    hasPrevious: hasPrevious,
    page: page,
    size: size,
    skip: skip,
    takeAll: takeAll,
    totalCount: totalCount,
    totalPages: totalPages,
  );
}

extension ExamListResponseDtoConversion on ExamListResponseDto {
  ExamListResponse toModel() => ExamListResponse(
    mstatus: mstatus,
    pagination: pagination?.toModel(),
    exams: exams.map((exam) => exam.toModel()).toList(),
    status: status,
    mmessage: mmessage,
    debug: debug,
  );
}

extension ExamProgressPointDtoConversion on ExamProgressPointDto {
  ExamProgressPoint toModel() => ExamProgressPoint(
    completedDt: completedDt,
    correctNumber: correctNumber,
    examId: userAiExamId,
    score: score,
    scorePct: scorePct,
    sequence: sequence,
    totalQuestions: totalQuestions,
    examType: examType,
    grade: grade,
    level: level,
  );
}

extension ExamProgressSummaryDtoConversion on ExamProgressSummaryDto {
  ExamProgressSummary toModel() => ExamProgressSummary(
    averageDelta: averageDelta,
    averageScore: averageScore,
    averageScorePct: averageScorePct,
    count: count,
    highestExamId: highestUserAiExamId,
    highestScore: highestScore,
    highestScorePct: highestScorePct,
    lowestScore: lowestScore,
    trend: trend,
  );
}

extension ExamProgressResponseDtoConversion on ExamProgressResponseDto {
  ExamProgressResponse toModel() => ExamProgressResponse(
    mstatus: mstatus,
    profileId: profileId,
    fromDt: fromDt,
    toDt: toDt,
    limit: limit,
    examType: examType,
    series: series.map((point) => point.toModel()).toList(),
    summary: summary?.toModel(),
    status: status,
    tz: tz,
    mmessage: mmessage,
    debug: debug,
  );
}

extension ExamStatsDtoConversion on ExamStatsDto {
  ExamStats toModel() {
    final activeExams = <GeneratedExam>[
      ...inProgressExams.map((exam) => exam.toModel(userExamId: userExamId)),
      if (inProgressExam != null)
        inProgressExam!.toModel(userExamId: userExamId),
    ];
    return ExamStats(
      correctNumber: correctNumber,
      scorePercentage: scorePercentage,
      skippedNumber: skippedNumber,
      totalQuestions: totalQuestions,
      examType: examType,
      userExamId: userExamId,
      status: status,
      grade: grade,
      level: level,
      lastSubmittedDt: lastSubmittedDt,
      review: review,
      inProgressExams: activeExams,
    );
  }
}

/// Adapts the stats endpoint to the progress chart. Date filtering is local
/// because the stats request does not accept a date range.
ExamProgressResponse examStatsToProgress(
  Map<String, dynamic> json, {
  required DateTime fromDt,
  required DateTime toDt,
  required int profileId,
  required String examType,
}) {
  final response = ExamStatsResponseDto.fromJson(json);
  final rawStats = (json['stats'] as List<dynamic>?) ?? const [];
  final entries = <({ExamStatsDto stats, DateTime date})>[];
  for (var i = 0; i < response.stats.length; i++) {
    final stats = response.stats[i];
    final raw = rawStats[i] as Map<String, dynamic>;
    final date =
        DateTime.tryParse(raw['ended_dt']?.toString() ?? '') ??
        stats.lastSubmittedDt ??
        DateTime.tryParse(raw['create_dt']?.toString() ?? '');
    if (date == null || date.isBefore(fromDt) || date.isAfter(toDt)) continue;
    entries.add((stats: stats, date: date));
  }
  entries.sort((a, b) {
    final order = a.date.compareTo(b.date);
    return order != 0
        ? order
        : (a.stats.userExamId ?? 0).compareTo(b.stats.userExamId ?? 0);
  });
  final points = <ExamProgressPoint>[
    for (var i = 0; i < entries.length; i++)
      ExamProgressPoint(
        completedDt: entries[i].date,
        correctNumber: entries[i].stats.correctNumber,
        examId: entries[i].stats.userExamId ?? 0,
        score: entries[i].stats.scorePercentage / 10,
        scorePct: entries[i].stats.scorePercentage,
        sequence: i + 1,
        totalQuestions: entries[i].stats.totalQuestions,
        examType: entries[i].stats.examType,
        grade: entries[i].stats.grade,
        level: entries[i].stats.level,
      ),
  ];
  final rawSummary = json['summary'];
  // A global summary is valid only when the filter retains every record.
  final summary =
      entries.length == response.stats.length &&
          rawSummary is Map<String, dynamic>
      ? ExamProgressSummaryDto.fromJson({
          ...rawSummary,
          'highest_user_ai_exam_id': rawSummary['highest_user_exam_id'],
        }).toModel()
      : null;
  return ExamProgressResponse(
    mstatus: response.mstatus,
    profileId: profileId,
    examType: examType,
    fromDt: fromDt,
    toDt: toDt,
    series: points,
    summary: summary,
    status: response.status,
    mmessage: response.mmessage,
    debug: response.debug,
  );
}
