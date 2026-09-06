import 'package:numi/features/quiz/data/quiz_api_models.dart';
import 'package:numi/features/quiz/models/quiz.dart';

extension SubmitQuizAnswerConversion on SubmitQuizAnswer {
  SubmitQuizAnswerDto toDto() =>
      SubmitQuizAnswerDto(questionNumber: questionNumber, label: label);
}

extension QuizAnswerDtoConversion on QuizAnswerDto {
  QuizAnswer toModel() => QuizAnswer(content: content, label: label);
}

extension QuizQuestionDtoConversion on QuizQuestionDto {
  QuizQuestion toModel() => QuizQuestion(
    questionName: questionName,
    questionNumber: questionNumber,
    answers: answers.map((answer) => answer.toModel()).toList(),
    rightAnswer: rightAnswer,
    correctAnswer: correctAnswer,
    difficulty: difficulty,
    topic: topic,
  );
}

extension QuizGradingDtoConversion on QuizGradingDto {
  QuizGrading toModel() => QuizGrading(
    aiDetectGrade: aiDetectGrade,
    aiReview: aiReview,
    correctNumber: correctNumber,
    scorePercentage: scorePercentage,
    totalQuestions: totalQuestions,
  );
}

extension GeneratedQuizDtoConversion on GeneratedQuizDto {
  GeneratedQuiz toModel() => GeneratedQuiz(
    id: id,
    quizId: quizId,
    previousQuizId: previousQuizId,
    profileId: profileId,
    quizStatus: quizStatus,
    purpose: purpose,
    typeOfQuiz: typeOfQuiz,
    type: type,
    title: title,
    shortText: shortText,
    userId: userId,
    createDt: createDt,
    modifyDt: modifyDt,
    grading: grading?.toModel(),
    answers: answers
        .map(
          (answer) => SubmitQuizAnswer(
            questionNumber: answer.questionNumber,
            label: answer.label,
          ),
        )
        .toList(),
    questions: questions.map((question) => question.toModel()).toList(),
  );
}

extension QuizPaginationDtoConversion on QuizPaginationDto {
  QuizPagination toModel() => QuizPagination(
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

extension QuizListResponseDtoConversion on QuizListResponseDto {
  QuizListResponse toModel() => QuizListResponse(
    mstatus: mstatus,
    pagination: pagination?.toModel(),
    quizzes: quizzes.map((quiz) => quiz.toModel()).toList(),
    status: status,
    mmessage: mmessage,
    debug: debug,
  );
}

extension QuizProgressPointDtoConversion on QuizProgressPointDto {
  QuizProgressPoint toModel() => QuizProgressPoint(
    completedDt: completedDt,
    correctNumber: correctNumber,
    quizId: quizId,
    score: score,
    scorePct: scorePct,
    sequence: sequence,
    totalQuestions: totalQuestions,
    purpose: purpose,
    shortText: shortText,
    title: title,
    typeOfQuiz: typeOfQuiz,
  );
}

extension QuizProgressSummaryDtoConversion on QuizProgressSummaryDto {
  QuizProgressSummary toModel() => QuizProgressSummary(
    averageDelta: averageDelta,
    averageScore: averageScore,
    averageScorePct: averageScorePct,
    count: count,
    highestQuizId: highestQuizId,
    highestScore: highestScore,
    highestScorePct: highestScorePct,
    lowestScore: lowestScore,
    trend: trend,
  );
}

extension QuizProgressResponseDtoConversion on QuizProgressResponseDto {
  QuizProgressResponse toModel() => QuizProgressResponse(
    mstatus: mstatus,
    profileId: profileId,
    fromDt: fromDt,
    toDt: toDt,
    limit: limit,
    purpose: purpose,
    series: series.map((point) => point.toModel()).toList(),
    summary: summary?.toModel(),
    status: status,
    tz: tz,
    mmessage: mmessage,
    debug: debug,
  );
}
