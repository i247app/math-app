class SubmitQuizAnswer {
  const SubmitQuizAnswer({required this.questionNumber, required this.label});

  final int questionNumber;
  final String label;
}

class QuizListResponse {
  const QuizListResponse({
    required this.mstatus,
    this.pagination,
    this.quizzes = const <GeneratedQuiz>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final QuizPagination? pagination;
  final List<GeneratedQuiz> quizzes;
  final String? status;
  final String? mmessage;
  final String? debug;
}

class QuizProgressResponse {
  const QuizProgressResponse({
    required this.mstatus,
    this.profileId,
    this.fromDt,
    this.toDt,
    this.limit,
    this.purpose,
    this.series = const <QuizProgressPoint>[],
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
  final String? purpose;
  final List<QuizProgressPoint> series;
  final QuizProgressSummary? summary;
  final String? status;
  final String? tz;
  final String? mmessage;
  final String? debug;
}

class QuizProgressPoint {
  const QuizProgressPoint({
    required this.completedDt,
    required this.correctNumber,
    required this.quizId,
    required this.score,
    required this.scorePct,
    required this.sequence,
    required this.totalQuestions,
    this.purpose,
    this.shortText,
    this.title,
    this.typeOfQuiz,
  });

  final DateTime completedDt;
  final int correctNumber;
  final int quizId;
  final double score;
  final double scorePct;
  final int sequence;
  final int totalQuestions;
  final String? purpose;
  final String? shortText;
  final String? title;
  final String? typeOfQuiz;
}

class QuizProgressSummary {
  const QuizProgressSummary({
    required this.averageDelta,
    required this.averageScore,
    required this.averageScorePct,
    required this.count,
    required this.highestScore,
    required this.highestScorePct,
    required this.lowestScore,
    required this.trend,
    this.highestQuizId,
  });

  final double? averageDelta;
  final double averageScore;
  final double averageScorePct;
  final int count;
  final int? highestQuizId;
  final double highestScore;
  final double highestScorePct;
  final double lowestScore;
  final String trend;
}

class QuizPagination {
  const QuizPagination({
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

class GeneratedQuiz {
  const GeneratedQuiz({
    this.id,
    this.quizId,
    this.previousQuizId,
    this.profileId,
    this.quizStatus,
    this.purpose,
    this.typeOfQuiz,
    this.type,
    this.title,
    this.shortText,
    this.userId,
    this.createDt,
    this.modifyDt,
    this.grading,
    this.answers = const <SubmitQuizAnswer>[],
    required this.questions,
  });

  final int? id;
  final int? quizId;
  final int? previousQuizId;
  final int? profileId;
  final String? quizStatus;
  final String? purpose;
  final String? typeOfQuiz;
  final String? type;
  final String? title;
  final String? shortText;
  final int? userId;
  final String? createDt;
  final String? modifyDt;
  final QuizGrading? grading;
  final List<SubmitQuizAnswer> answers;
  final List<QuizQuestion> questions;
}

class QuizGrading {
  const QuizGrading({
    this.aiDetectGrade,
    this.aiReview,
    this.correctNumber,
    this.scorePercentage,
    this.totalQuestions,
  });

  final String? aiDetectGrade;
  final String? aiReview;
  final int? correctNumber;
  final int? scorePercentage;
  final int? totalQuestions;
}

class QuizQuestion {
  const QuizQuestion({
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
  final List<QuizAnswer> answers;
  final String? rightAnswer;
  final String? correctAnswer;
  final int? difficulty;
  final String? topic;
}

class QuizAnswer {
  const QuizAnswer({required this.content, required this.label});

  final String content;
  final String label;
}
