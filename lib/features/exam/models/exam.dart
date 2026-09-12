class SubmitExamAnswer {
  const SubmitExamAnswer({required this.questionNumber, required this.label});

  final int questionNumber;
  final String label;
}

class ExamListResponse {
  const ExamListResponse({
    required this.mstatus,
    this.pagination,
    this.exams = const <GeneratedExam>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final ExamPagination? pagination;
  final List<GeneratedExam> exams;
  final String? status;
  final String? mmessage;
  final String? debug;
}

class ExamProgressResponse {
  const ExamProgressResponse({
    required this.mstatus,
    this.profileId,
    this.fromDt,
    this.toDt,
    this.limit,
    this.examType,
    this.series = const <ExamProgressPoint>[],
    this.summary,
    this.status,
    this.tz,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final int? profileId;
  final DateTime? fromDt;
  final DateTime? toDt;
  final int? limit;
  final String? examType;
  final List<ExamProgressPoint> series;
  final ExamProgressSummary? summary;
  final String? status;
  final String? tz;
  final String? mmessage;
  final String? debug;
}

class ExamProgressPoint {
  const ExamProgressPoint({
    required this.completedDt,
    required this.correctNumber,
    required this.examId,
    required this.score,
    required this.scorePct,
    required this.sequence,
    required this.totalQuestions,
    this.examType,
    this.shortText,
    this.title,
    this.grade,
    this.level,
  });

  final DateTime completedDt;
  final int correctNumber;
  final int examId;
  final double score;
  final double scorePct;
  final int sequence;
  final int totalQuestions;
  final String? examType;
  final String? shortText;
  final String? title;
  final int? grade;
  final int? level;
}

class ExamProgressSummary {
  const ExamProgressSummary({
    required this.averageDelta,
    required this.averageScore,
    required this.averageScorePct,
    required this.count,
    required this.highestScore,
    required this.highestScorePct,
    required this.lowestScore,
    required this.trend,
    this.highestExamId,
  });

  final double? averageDelta;
  final double averageScore;
  final double averageScorePct;
  final int count;
  final int? highestExamId;
  final double highestScore;
  final double highestScorePct;
  final double lowestScore;
  final String trend;
}

class ExamPagination {
  const ExamPagination({
    this.hasNext,
    this.hasPrevious,
    this.page,
    this.size,
    this.skip,
    this.takeAll,
    this.totalCount,
    this.totalPages,
  });

  final bool? hasNext;
  final bool? hasPrevious;
  final int? page;
  final int? size;
  final int? skip;
  final bool? takeAll;
  final int? totalCount;
  final int? totalPages;
}

class GeneratedExam {
  const GeneratedExam({
    this.id,
    this.examId,
    this.profileId,
    this.examStatus,
    this.examType,
    this.title,
    this.shortText,
    this.userId,
    this.createDt,
    this.modifyDt,
    this.aiExamId,
    this.userAiExamId,
    this.userExamId,
    this.grade,
    this.level,
    this.numQuestions,
    this.startedDt,
    this.submittedDt,
    this.grading,
    this.answers = const <SubmitExamAnswer>[],
    required this.questions,
  });

  final int? id;
  final int? examId;
  final int? profileId;
  final String? examStatus;
  final String? examType;
  final String? title;
  final String? shortText;
  final int? userId;
  final String? createDt;
  final String? modifyDt;
  final int? aiExamId;
  final int? userAiExamId;
  final int? userExamId;
  final int? grade;
  final int? level;
  final int? numQuestions;
  final String? startedDt;
  final String? submittedDt;
  final ExamGrading? grading;
  final List<SubmitExamAnswer> answers;
  final List<ExamQuestion> questions;
}

class ExamStats {
  const ExamStats({
    required this.correctNumber,
    required this.scorePercentage,
    required this.skippedNumber,
    required this.totalQuestions,
    this.examType,
    this.userExamId,
    this.status,
    this.grade,
    this.level,
    this.lastSubmittedDt,
    this.review,
  });

  final int correctNumber;
  final double scorePercentage;
  final int skippedNumber;
  final int totalQuestions;
  final String? examType;
  final int? userExamId;
  final String? status;
  final int? grade;
  final int? level;
  final DateTime? lastSubmittedDt;
  final String? review;
}

class ExamGrading {
  const ExamGrading({
    this.aiDetectGrade,
    this.aiReview,
    this.correctNumber,
    this.scorePercentage,
    this.skippedNumber,
    this.totalQuestions,
  });

  final String? aiDetectGrade;
  final String? aiReview;
  final int? correctNumber;
  final int? scorePercentage;
  final int? skippedNumber;
  final int? totalQuestions;
}

class ExamQuestion {
  const ExamQuestion({
    required this.questionName,
    required this.questionNumber,
    required this.answers,
    this.rightAnswer,
    this.correctAnswer,
    this.difficulty,
    this.topic,
  });

  final String questionName;
  final int questionNumber;
  final List<ExamAnswer> answers;
  final String? rightAnswer;
  final String? correctAnswer;
  final int? difficulty;
  final String? topic;
}

class ExamAnswer {
  const ExamAnswer({required this.content, required this.label});

  final String content;
  final String label;
}
