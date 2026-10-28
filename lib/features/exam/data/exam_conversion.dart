import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/helpers/grade_exam_level.dart';

extension SubmitExamAnswerConversion on SubmitExamAnswer {
  SubmitExamAnswerDto toDto() => SubmitExamAnswerDto(
    questionNumber: questionNumber,
    optionIds: value == null ? selectedOptionIds : null,
    value: value,
  );
}

extension SubmitExamAnswerDtoConversion on SubmitExamAnswerDto {
  SubmitExamAnswer toModel() => SubmitExamAnswer(
    questionNumber: questionNumber,
    optionIds: optionIds,
    value: value,
  );
}

extension ExamAnswerDtoConversion on ExamAnswerDto {
  ExamAnswer toModel() => ExamAnswer(text: text, id: id, imageUrl: imageUrl);
}

extension ExamQuestionDtoConversion on ExamQuestionDto {
  ExamQuestion toModel({int? questionNumberOverride}) {
    final ids =
        correctAnswer?.optionIds ??
        (correctAnswer?.value == null
            ? const <String>[]
            : [correctAnswer!.value.toString()]);
    return ExamQuestion(
      questionText: questionText,
      questionNumber: questionNumberOverride ?? questionNumber,
      options: options.map((answer) => answer.toModel()).toList(),
      correctOptionIds: ids,
      correctValues: correctAnswer?.values ?? const [],
      questionKind: questionKind,
      questionImageUrl: questionImageUrl,
      difficulty: questionLevel,
      topic: questionTopic,
      renderType: renderType,
    );
  }
}

extension ExamDetailAnswerDtoConversion on ExamDetailAnswerDto {
  SubmitExamAnswerDto? toSubmittedAnswer({int? questionNumberOverride}) {
    if (questionKind == 'NUMERIC_INPUT') {
      final value = childAnswerText;
      if (value == null || value.trim().isEmpty) return null;
      return SubmitExamAnswerDto(
        questionNumber: questionNumberOverride ?? questionNumber,
        value: value,
      );
    }
    if (childOptionIds.isEmpty) return null;
    return SubmitExamAnswerDto(
      questionNumber: questionNumberOverride ?? questionNumber,
      optionIds: childOptionIds,
    );
  }

  ExamQuestion toQuestionModel({required int questionNumber}) => ExamQuestion(
    questionText: questionText?.trim() ?? '',
    questionNumber: questionNumber,
    options: options.map((answer) => answer.toModel()).toList(growable: false),
    correctOptionIds: rightOptionIds,
    questionKind: questionKind,
    questionImageUrl: questionImageUrl,
    reviewCorrectText: rightAnswerText,
    reviewChildText: childAnswerText,
    reviewIsCorrect: isCorrect,
    difficulty: questionLevel,
    topic: questionTopic,
    renderType: renderType,
  );
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
    int questionNumberOffset = 0,
    List<ExamPracticeTopic> practiceWeakTopics = const <ExamPracticeTopic>[],
  }) => GeneratedExam(
    id: userAiExamIdOverride ?? elinkId,
    // The app model still calls the assigned-set ID examId; the DTO uses elinkId.
    examId: userAiExamIdOverride ?? elinkId,
    profileId: profileId,
    examStatus: examStatusOverride ?? status,
    examType: examType ?? stats?.examType,
    title: title ?? stats?.title,
    shortText: shortText ?? stats?.shortText,
    review: stats?.review,
    createDt: createDt,
    modifyDt: submittedDt,
    aiExamId: examId,
    userAiExamId: userAiExamIdOverride ?? elinkId,
    userExamId: userExamId ?? esessId ?? stats?.esessId,
    grade: grade,
    lastSetGrade: grade,
    lastSetShortText: shortText,
    aiReviewShort: stats?.aiReviewShort,
    aiReviewLong: stats?.aiReviewLong,
    practiceWeakTopics: practiceWeakTopics,
    level: GradeExamLevel.forExamType(
      level ?? stats?.level,
      examType ?? stats?.examType,
    ),
    numQuestions: numQuestions,
    startedDt: startedDt,
    submittedDt: submittedDt,
    grading: result?.toModel(review: stats?.review, grade: grade),
    answers: submittedAnswers.map((answer) => answer.toModel()).toList(),
    resumeQuestionIndex: resumeQuestionIndex,
    questionNumberOffset: questionNumberOffset,
    imageUrlsFetchedAt: DateTime.now(),
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

extension ExamProgressPointDtoConversion on ExamProgressPointDto {
  ExamProgressPoint toModel() => ExamProgressPoint(
    completedDt: lastSubmittedDt,
    correctNumber: correctNumber,
    examId: esessId,
    score: score,
    scorePct: scorePct,
    sequence: sequence,
    totalQuestions: totalQuestions,
    examType: examType,
    status: status,
    grade: grade,
    level: GradeExamLevel.forExamType(level, examType),
  );
}

extension ExamProgressSummaryDtoConversion on ExamProgressSummaryDto {
  ExamProgressSummary toModel() => ExamProgressSummary(
    averageDelta: averageDelta,
    averageScore: averageScore,
    averageScorePct: averageScorePct,
    count: count,
    highestExamId: highestEsessId,
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
    final questionNumberOffset =
        examType?.trim().toUpperCase() == 'ASSESSMENT' && totalQuestions > 0
        ? totalQuestions
        : 0;
    final activeExams = <GeneratedExam>[
      ...inProgressExams.map(
        (exam) => exam.toModel(
          userExamId: esessId,
          stats: this,
          questionNumberOffset: questionNumberOffset,
        ),
      ),
      if (inProgressExam != null)
        inProgressExam!.toModel(
          userExamId: esessId,
          stats: this,
          questionNumberOffset: questionNumberOffset,
        ),
    ];
    return ExamStats(
      correctNumber: correctNumber,
      scorePercentage: scorePercentage,
      skippedNumber: skippedNumber,
      totalQuestions: totalQuestions,
      examType: examType,
      userExamId: esessId,
      status: status,
      grade: grade,
      level: GradeExamLevel.forExamType(level, examType),
      lastSubmittedDt: lastSubmittedDt,
      endedDt: endedDt,
      createDt: createDt,
      passed: esessFlag,
      isLatest: isLatest,
      review: review,
      title: title,
      shortText: shortText,
      aiReviewShort: aiReviewShort,
      aiReviewLong: aiReviewLong,
      inProgressExams: activeExams,
    );
  }
}
