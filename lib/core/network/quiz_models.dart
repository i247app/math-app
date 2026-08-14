import 'package:json_annotation/json_annotation.dart';

part 'quiz_models.g.dart';

@JsonSerializable(includeIfNull: false)
class GenerateQuizRequest {
  const GenerateQuizRequest({
    required this.purpose,
    required this.typeOfQuiz,
    this.gradeLabel,
    this.previousQuizId,
    this.chapters,
    this.profileId,
  });

  final String purpose;
  @JsonKey(name: 'type_of_quiz')
  final String typeOfQuiz;
  @JsonKey(name: 'grade_label')
  final String? gradeLabel;
  @JsonKey(name: 'previous_quiz_id')
  final int? previousQuizId;
  final List<String>? chapters;
  @JsonKey(name: 'profile_id')
  final int? profileId;

  factory GenerateQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizRequestToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class SubmitQuizRequest {
  const SubmitQuizRequest({
    required this.quizId,
    required this.answers,
    this.profileId,
  });

  final int quizId;
  final List<SubmitQuizAnswer> answers;
  final int? profileId;

  factory SubmitQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitQuizAnswer {
  const SubmitQuizAnswer({required this.questionNumber, required this.label});

  final int questionNumber;
  final String label;

  factory SubmitQuizAnswer.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizAnswerToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class QuizListRequest {
  const QuizListRequest({
    this.userId,
    this.profileId,
    this.page,
    this.size,
    this.takeAll,
  });

  final int? userId;
  final int? profileId;
  final int? page;
  final int? size;
  final bool? takeAll;

  factory QuizListRequest.fromJson(Map<String, dynamic> json) =>
      _$QuizListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuizListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizProgressRequest {
  const QuizProgressRequest({
    required this.profileId,
    required this.fromDt,
    required this.toDt,
  });

  final int profileId;
  final DateTime fromDt;
  final DateTime toDt;

  factory QuizProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GenerateQuizResponse {
  const GenerateQuizResponse({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuiz? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory GenerateQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubmitQuizResponse {
  const SubmitQuizResponse({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuiz? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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

  factory QuizListResponse.fromJson(Map<String, dynamic> json) =>
      _$QuizListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuizListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QuizDetailResponse {
  const QuizDetailResponse({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuiz? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory QuizDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$QuizDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuizDetailResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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

  factory QuizProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory QuizProgressPoint.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressPointFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressPointToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory QuizProgressSummary.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressSummaryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory QuizPagination.fromJson(Map<String, dynamic> json) =>
      _$QuizPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$QuizPaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? quizId;
  @JsonKey(fromJson: _intFromJson)
  final int? previousQuizId;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? quizStatus;
  final String? purpose;
  @JsonKey(name: 'type_of_quiz')
  final String? typeOfQuiz;
  final String? type;
  final String? title;
  final String? shortText;
  @JsonKey(fromJson: _intFromJson)
  final int? userId;
  final String? createDt;
  final String? modifyDt;
  final QuizGrading? grading;
  final List<SubmitQuizAnswer> answers;
  @JsonKey(defaultValue: <QuizQuestion>[])
  final List<QuizQuestion> questions;

  factory GeneratedQuiz.fromJson(Map<String, dynamic> json) =>
      _$GeneratedQuizFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedQuizToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory QuizGrading.fromJson(Map<String, dynamic> json) =>
      _$QuizGradingFromJson(json);

  Map<String, dynamic> toJson() => _$QuizGradingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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
  @JsonKey(defaultValue: <QuizAnswer>[])
  final List<QuizAnswer> answers;
  final String? rightAnswer;
  final String? correctAnswer;
  @JsonKey(fromJson: _intFromJson)
  final int? difficulty;
  final String? topic;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class QuizAnswer {
  const QuizAnswer({required this.content, required this.label});

  final String content;
  final String label;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAnswerToJson(this);
}

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
