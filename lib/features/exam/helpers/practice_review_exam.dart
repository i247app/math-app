import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_attempt_answers.dart';

/// Retains the generated questions and grades Practice by first attempts only.
GeneratedExam buildPracticeReviewExam({
  required GeneratedExam sourceExam,
  required GeneratedExam submittedExam,
  required List<SubmitExamAnswer> answers,
}) {
  final correctNumber = ExamAttemptAnswers.correctSubmittedCount(
    sourceExam,
    answers,
  );
  final totalQuestions = answers.length;
  final grading = ExamGrading(
    aiDetectGrade: submittedExam.grading?.aiDetectGrade,
    aiReview: submittedExam.grading?.aiReview,
    correctNumber: correctNumber,
    scorePercentage: totalQuestions == 0
        ? 0
        : ((correctNumber * 100) / totalQuestions).round(),
    skippedNumber: 0,
    totalQuestions: totalQuestions,
  );
  return GeneratedExam(
    id: submittedExam.id ?? sourceExam.id,
    examId: submittedExam.examId ?? sourceExam.examId,
    profileId: submittedExam.profileId ?? sourceExam.profileId,
    examStatus: submittedExam.examStatus ?? sourceExam.examStatus,
    examType: sourceExam.examType ?? submittedExam.examType,
    title: submittedExam.title ?? sourceExam.title,
    shortText: submittedExam.shortText ?? sourceExam.shortText,
    review: submittedExam.review ?? sourceExam.review,
    aiTitle: submittedExam.aiTitle ?? sourceExam.aiTitle,
    aiShortText: submittedExam.aiShortText ?? sourceExam.aiShortText,
    aiReviewShort: submittedExam.aiReviewShort ?? sourceExam.aiReviewShort,
    aiReviewLong: submittedExam.aiReviewLong ?? sourceExam.aiReviewLong,
    userId: submittedExam.userId ?? sourceExam.userId,
    createDt: submittedExam.createDt ?? sourceExam.createDt,
    modifyDt: submittedExam.modifyDt ?? sourceExam.modifyDt,
    aiExamId: submittedExam.aiExamId ?? sourceExam.aiExamId,
    userAiExamId: submittedExam.userAiExamId ?? sourceExam.userAiExamId,
    userExamId: sourceExam.userExamId ?? submittedExam.userExamId,
    grade: sourceExam.grade ?? submittedExam.grade,
    practiceWeakTopics: sourceExam.practiceWeakTopics.isNotEmpty
        ? sourceExam.practiceWeakTopics
        : submittedExam.practiceWeakTopics,
    level: submittedExam.level ?? sourceExam.level,
    numQuestions: submittedExam.numQuestions ?? sourceExam.numQuestions,
    startedDt: submittedExam.startedDt ?? sourceExam.startedDt,
    submittedDt: submittedExam.submittedDt ?? sourceExam.submittedDt,
    grading: grading,
    answers: List<SubmitExamAnswer>.unmodifiable(answers),
    questions: sourceExam.questions,
  );
}
