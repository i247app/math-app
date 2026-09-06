import 'package:json_annotation/json_annotation.dart';

part 'quiz_api_models.g.dart';

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
  final List<SubmitQuizAnswerDto> answers;
  final int? profileId;

  factory SubmitQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitQuizAnswerDto {
  const SubmitQuizAnswerDto({
    required this.questionNumber,
    required this.label,
  });

  final int questionNumber;
  final String label;

  factory SubmitQuizAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class QuizListRequest {
  const QuizListRequest({
    this.userId,
    this.profileId,
    this.page,
    this.size,
    this.takeAll,
    required this.purpose,
  });

  final int? userId;
  final int? profileId;
  final int? page;
  final int? size;
  final bool? takeAll;
  final String purpose;

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
    required this.purpose,
  });

  final int profileId;
  final DateTime fromDt;
  final DateTime toDt;
  final String purpose;

  factory QuizProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GenerateQuizResponseDto {
  const GenerateQuizResponseDto({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuizDto? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory GenerateQuizResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubmitQuizResponseDto {
  const SubmitQuizResponseDto({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuizDto? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SubmitQuizResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QuizListResponseDto {
  const QuizListResponseDto({
    required this.mstatus,
    this.pagination,
    this.quizzes = const <GeneratedQuizDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final QuizPaginationDto? pagination;
  final List<GeneratedQuizDto> quizzes;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory QuizListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuizListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizListResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QuizDetailResponseDto {
  const QuizDetailResponseDto({
    required this.mstatus,
    this.quiz,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedQuizDto? quiz;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory QuizDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuizDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizDetailResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QuizProgressResponseDto {
  const QuizProgressResponseDto({
    required this.mstatus,
    this.profileId,
    this.fromDt,
    this.toDt,
    this.limit,
    this.purpose,
    this.series = const <QuizProgressPointDto>[],
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
  final List<QuizProgressPointDto> series;
  final QuizProgressSummaryDto? summary;
  final String? status;
  final String? tz;
  final String? mmessage;
  final String? debug;

  factory QuizProgressResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizProgressPointDto {
  const QuizProgressPointDto({
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

  factory QuizProgressPointDto.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressPointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressPointDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizProgressSummaryDto {
  const QuizProgressSummaryDto({
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

  factory QuizProgressSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$QuizProgressSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizProgressSummaryDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizPaginationDto {
  const QuizPaginationDto({
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

  factory QuizPaginationDto.fromJson(Map<String, dynamic> json) =>
      _$QuizPaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizPaginationDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GeneratedQuizDto {
  const GeneratedQuizDto({
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
    this.answers = const <SubmitQuizAnswerDto>[],
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
  final QuizGradingDto? grading;
  final List<SubmitQuizAnswerDto> answers;
  @JsonKey(defaultValue: <QuizQuestionDto>[])
  final List<QuizQuestionDto> questions;

  factory GeneratedQuizDto.fromJson(Map<String, dynamic> json) =>
      _$GeneratedQuizDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedQuizDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizGradingDto {
  const QuizGradingDto({
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

  factory QuizGradingDto.fromJson(Map<String, dynamic> json) =>
      _$QuizGradingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizGradingDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QuizQuestionDto {
  const QuizQuestionDto({
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
  @JsonKey(defaultValue: <QuizAnswerDto>[])
  final List<QuizAnswerDto> answers;
  final String? rightAnswer;
  final String? correctAnswer;
  @JsonKey(fromJson: _intFromJson)
  final int? difficulty;
  final String? topic;

  factory QuizQuestionDto.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionDtoToJson(this);
}

@JsonSerializable()
class QuizAnswerDto {
  const QuizAnswerDto({required this.content, required this.label});

  final String content;
  final String label;

  factory QuizAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAnswerDtoToJson(this);
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
