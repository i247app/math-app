import 'package:json_annotation/json_annotation.dart';

part 'exam_api_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class GenerateExamRequest {
  const GenerateExamRequest({
    required this.profileId,
    required this.numQuestions,
    required this.examType,
    required this.grade,
    required this.level,
  });

  final int profileId;
  final int numQuestions;
  final String examType;
  final int grade;
  final int level;

  factory GenerateExamRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateExamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateExamRequestToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class SubmitExamRequest {
  const SubmitExamRequest({
    required this.profileId,
    required this.userAiExamId,
    required this.answers,
  });

  final int profileId;
  final int userAiExamId;
  final List<SubmitExamAnswerDto> answers;

  factory SubmitExamRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitExamAnswerDto {
  const SubmitExamAnswerDto({
    required this.questionNumber,
    required this.label,
  });

  final int questionNumber;
  final String label;

  factory SubmitExamAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ExamListRequest {
  const ExamListRequest({
    required this.profileId,
    this.page,
    this.size,
    this.takeAll,
    required this.examType,
  });

  final int profileId;
  final int? page;
  final int? size;
  final bool? takeAll;
  final String examType;

  factory ExamListRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExamListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamStatsRequest {
  const ExamStatsRequest({required this.profileId, required this.examType});

  final int profileId;
  final String examType;

  factory ExamStatsRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStatsRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamProgressRequest {
  const ExamProgressRequest({
    required this.profileId,
    required this.fromDt,
    required this.toDt,
    required this.examType,
  });

  final int profileId;
  final DateTime fromDt;
  final DateTime toDt;
  final String examType;

  factory ExamProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamProgressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExamProgressRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GenerateExamResponseDto {
  const GenerateExamResponseDto({
    required this.mstatus,
    this.exam,
    this.userExamId,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  @JsonKey(name: 'user_exam_id', fromJson: _intFromJson)
  final int? userExamId;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory GenerateExamResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateExamResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateExamResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubmitExamResponseDto {
  const SubmitExamResponseDto({
    required this.mstatus,
    this.exam,
    this.stats,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  final ExamStatsDto? stats;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SubmitExamResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamListResponseDto {
  const ExamListResponseDto({
    required this.mstatus,
    this.pagination,
    this.exams = const <GeneratedExamDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final ExamPaginationDto? pagination;
  final List<GeneratedExamDto> exams;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ExamListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamListResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamDetailResponseDto {
  const ExamDetailResponseDto({
    required this.mstatus,
    this.exam,
    this.exams = const <GeneratedExamDto>[],
    this.stats,
    this.details = const <ExamDetailAnswerDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  final List<GeneratedExamDto> exams;
  final ExamStatsDto? stats;
  final List<ExamDetailAnswerDto> details;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ExamDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamDetailAnswerDto {
  const ExamDetailAnswerDto({
    required this.questionNumber,
    this.answers = const <ExamAnswerDto>[],
    this.userAiExamId,
    this.questionGrade,
    this.questionLevel,
    this.questionName,
    this.questionTopic,
    this.questionType,
    this.rightAnswerContent,
    this.rightAnswerLabel,
    this.selectedLabel,
    this.selectedContent,
    this.isCorrect,
  });

  final int questionNumber;
  final List<ExamAnswerDto> answers;
  @JsonKey(fromJson: _intFromJson)
  final int? userAiExamId;
  @JsonKey(fromJson: _intFromJson)
  final int? questionGrade;
  @JsonKey(fromJson: _intFromJson)
  final int? questionLevel;
  final String? questionName;
  final String? questionTopic;
  final String? questionType;
  final String? rightAnswerContent;
  final String? rightAnswerLabel;
  final String? selectedLabel;
  final String? selectedContent;
  final bool? isCorrect;

  factory ExamDetailAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamStatsResponseDto {
  const ExamStatsResponseDto({
    required this.mstatus,
    this.stats = const <ExamStatsDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ExamStatsDto> stats;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ExamStatsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStatsResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamStatsDto {
  const ExamStatsDto({
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
  @JsonKey(fromJson: _doubleFromJson)
  final double scorePercentage;
  final int skippedNumber;
  final int totalQuestions;
  final String? examType;
  @JsonKey(fromJson: _intFromJson)
  final int? userExamId;
  final String? status;
  final int? grade;
  final int? level;
  final DateTime? lastSubmittedDt;
  final String? review;

  factory ExamStatsDto.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStatsDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamProgressResponseDto {
  const ExamProgressResponseDto({
    required this.mstatus,
    this.profileId,
    this.fromDt,
    this.toDt,
    this.limit,
    this.examType,
    this.series = const <ExamProgressPointDto>[],
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
  final List<ExamProgressPointDto> series;
  final ExamProgressSummaryDto? summary;
  final String? status;
  final String? tz;
  final String? mmessage;
  final String? debug;

  factory ExamProgressResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamProgressResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamProgressResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamProgressPointDto {
  const ExamProgressPointDto({
    required this.completedDt,
    required this.correctNumber,
    required this.userAiExamId,
    required this.score,
    required this.scorePct,
    required this.sequence,
    required this.totalQuestions,
    this.examType,
    this.grade,
    this.level,
  });

  final DateTime completedDt;
  final int correctNumber;
  final int userAiExamId;
  @JsonKey(fromJson: _doubleFromJson)
  final double score;
  @JsonKey(fromJson: _doubleFromJson)
  final double scorePct;
  final int sequence;
  final int totalQuestions;
  final String? examType;
  final int? grade;
  final int? level;

  factory ExamProgressPointDto.fromJson(Map<String, dynamic> json) =>
      _$ExamProgressPointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamProgressPointDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamProgressSummaryDto {
  const ExamProgressSummaryDto({
    required this.averageDelta,
    required this.averageScore,
    required this.averageScorePct,
    required this.count,
    required this.highestScore,
    required this.highestScorePct,
    required this.lowestScore,
    required this.trend,
    this.highestUserAiExamId,
  });

  @JsonKey(fromJson: _nullableDoubleFromJson)
  final double? averageDelta;
  @JsonKey(fromJson: _doubleFromJson)
  final double averageScore;
  @JsonKey(fromJson: _doubleFromJson)
  final double averageScorePct;
  final int count;
  final int? highestUserAiExamId;
  @JsonKey(fromJson: _doubleFromJson)
  final double highestScore;
  @JsonKey(fromJson: _doubleFromJson)
  final double highestScorePct;
  @JsonKey(fromJson: _doubleFromJson)
  final double lowestScore;
  final String trend;

  factory ExamProgressSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ExamProgressSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamProgressSummaryDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamPaginationDto {
  const ExamPaginationDto({
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

  factory ExamPaginationDto.fromJson(Map<String, dynamic> json) =>
      _$ExamPaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPaginationDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GeneratedExamDto {
  const GeneratedExamDto({
    this.aiExamId,
    this.userAiExamId,
    this.userExamId,
    this.profileId,
    this.status,
    this.examType,
    this.grade,
    this.level,
    this.numQuestions,
    this.title,
    this.shortText,
    this.createDt,
    this.startedDt,
    this.submittedDt,
    this.result,
    required this.questions,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? aiExamId;
  @JsonKey(fromJson: _intFromJson)
  final int? userAiExamId;
  @JsonKey(fromJson: _intFromJson)
  final int? userExamId;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? status;
  final String? examType;
  @JsonKey(fromJson: _intFromJson)
  final int? grade;
  @JsonKey(fromJson: _intFromJson)
  final int? level;
  @JsonKey(fromJson: _intFromJson)
  final int? numQuestions;
  final String? title;
  final String? shortText;
  final String? createDt;
  final String? startedDt;
  final String? submittedDt;
  final ExamResultDto? result;
  @JsonKey(defaultValue: <ExamQuestionDto>[])
  final List<ExamQuestionDto> questions;

  factory GeneratedExamDto.fromJson(Map<String, dynamic> json) =>
      _$GeneratedExamDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedExamDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamResultDto {
  const ExamResultDto({
    this.correctNumber,
    this.scorePercentage,
    this.skippedNumber,
    this.totalQuestions,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? correctNumber;
  @JsonKey(fromJson: _intFromJson)
  final int? scorePercentage;
  @JsonKey(fromJson: _intFromJson)
  final int? skippedNumber;
  @JsonKey(fromJson: _intFromJson)
  final int? totalQuestions;

  factory ExamResultDto.fromJson(Map<String, dynamic> json) =>
      _$ExamResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResultDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamQuestionDto {
  const ExamQuestionDto({
    required this.questionName,
    required this.questionNumber,
    required this.answers,
    this.rightAnswerLabel,
    this.rightAnswerContent,
    this.questionGrade,
    this.questionLevel,
    this.questionTopic,
    this.questionType,
  });

  final String questionName;
  final int questionNumber;
  @JsonKey(defaultValue: <ExamAnswerDto>[])
  final List<ExamAnswerDto> answers;
  final String? rightAnswerLabel;
  final String? rightAnswerContent;
  @JsonKey(fromJson: _intFromJson)
  final int? questionGrade;
  @JsonKey(fromJson: _intFromJson)
  final int? questionLevel;
  final String? questionTopic;
  final String? questionType;

  factory ExamQuestionDto.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionDtoToJson(this);
}

@JsonSerializable()
class ExamAnswerDto {
  const ExamAnswerDto({required this.content, required this.label});

  final String content;
  final String label;

  factory ExamAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamAnswerDtoToJson(this);
}

int? _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double _doubleFromJson(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDoubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
