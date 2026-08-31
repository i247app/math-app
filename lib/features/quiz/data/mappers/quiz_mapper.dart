import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';

extension SubmitQuizAnswerMapper on SubmitQuizAnswer {
  SubmitQuizAnswerDto toDto() =>
      SubmitQuizAnswerDto(questionNumber: questionNumber, label: label);
}

extension QuizAnswerDtoMapper on QuizAnswerDto {
  QuizAnswer toDomain() => QuizAnswer(content: content, label: label);
}

extension QuizQuestionDtoMapper on QuizQuestionDto {
  QuizQuestion toDomain() => QuizQuestion(
    questionName: questionName,
    questionNumber: questionNumber,
    answers: answers.map((answer) => answer.toDomain()).toList(),
    rightAnswer: rightAnswer,
    correctAnswer: correctAnswer,
    difficulty: difficulty,
    topic: topic,
  );
}

extension QuizGradingDtoMapper on QuizGradingDto {
  QuizGrading toDomain() => QuizGrading(
    aiDetectGrade: aiDetectGrade,
    aiReview: aiReview,
    correctNumber: correctNumber,
    scorePercentage: scorePercentage,
    totalQuestions: totalQuestions,
  );
}

extension GeneratedQuizDtoMapper on GeneratedQuizDto {
  GeneratedQuiz toDomain() => GeneratedQuiz(
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
    grading: grading?.toDomain(),
    answers: answers
        .map(
          (answer) => SubmitQuizAnswer(
            questionNumber: answer.questionNumber,
            label: answer.label,
          ),
        )
        .toList(),
    questions: questions.map((question) => question.toDomain()).toList(),
  );
}

extension QuizPaginationDtoMapper on QuizPaginationDto {
  QuizPagination toDomain() => QuizPagination(
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

extension QuizListResponseDtoMapper on QuizListResponseDto {
  QuizListResponse toDomain() => QuizListResponse(
    mstatus: mstatus,
    pagination: pagination?.toDomain(),
    quizzes: quizzes.map((quiz) => quiz.toDomain()).toList(),
    status: status,
    mmessage: mmessage,
    debug: debug,
  );
}

extension QuizProgressPointDtoMapper on QuizProgressPointDto {
  QuizProgressPoint toDomain() => QuizProgressPoint(
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

extension QuizProgressSummaryDtoMapper on QuizProgressSummaryDto {
  QuizProgressSummary toDomain() => QuizProgressSummary(
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

extension QuizProgressResponseDtoMapper on QuizProgressResponseDto {
  QuizProgressResponse toDomain() => QuizProgressResponse(
    mstatus: mstatus,
    profileId: profileId,
    fromDt: fromDt,
    toDt: toDt,
    limit: limit,
    purpose: purpose,
    series: series.map((point) => point.toDomain()).toList(),
    summary: summary?.toDomain(),
    status: status,
    tz: tz,
    mmessage: mmessage,
    debug: debug,
  );
}
