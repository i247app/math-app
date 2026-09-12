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
    final answersByLabel = <String, String>{};

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

extension GeneratedExamDtoConversion on GeneratedExamDto {
  GeneratedExam toModel({
    List<SubmitExamAnswerDto> submittedAnswers = const <SubmitExamAnswerDto>[],
    ExamStatsDto? stats,
    bool useSequentialQuestionNumbers = false,
    int? userExamId,
  }) => GeneratedExam(
    id: userAiExamId,
    examId: userAiExamId,
    profileId: profileId,
    examStatus: status,
    examType: examType,
    title: title,
    shortText: shortText,
    createDt: createDt,
    modifyDt: submittedDt,
    aiExamId: aiExamId,
    userAiExamId: userAiExamId,
    userExamId: userExamId ?? stats?.userExamId,
    grade: grade,
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
  ExamStats toModel() => ExamStats(
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
  );
}
