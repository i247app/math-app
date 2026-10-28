import 'package:json_annotation/json_annotation.dart';
import 'package:numi/core/helpers/api_date_time.dart';

part 'exam_api_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class GenerateExamRequest {
  const GenerateExamRequest({
    this.profileId,
    required this.numQuestions,
    required this.examType,
    required this.grade,
    required this.level,
    this.esessId,
    this.guestUid,
  });

  final int? profileId;
  final int numQuestions;
  final String examType;
  final int grade;
  final int level;
  @JsonKey(name: 'esess_id')
  final int? esessId;
  @JsonKey(name: 'uid')
  final int? guestUid;

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
    required this.elinkId,
    required this.answers,
  });

  final int profileId;
  @JsonKey(name: 'elink_id')
  final int elinkId;
  final List<SubmitExamAnswerDto> answers;

  factory SubmitExamRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class SubmitExamAnswerDto {
  const SubmitExamAnswerDto({
    required this.questionNumber,
    this.optionIds,
    this.value,
  }) : assert((optionIds == null) != (value == null));

  final int questionNumber;
  final List<String>? optionIds;
  final String? value;

  factory SubmitExamAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamStatsRequest {
  const ExamStatsRequest({required this.profileId, required this.examTypes});

  final int profileId;
  final List<String> examTypes;

  factory ExamStatsRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStatsRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GenerateExamResponseDto {
  const GenerateExamResponseDto({
    required this.mstatus,
    this.exam,
    this.examSession,
    this.esessId,
    this.resumed,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  @JsonKey(name: 'exam_session')
  final ExamStatsDto? examSession;
  @JsonKey(name: 'esess_id', fromJson: _intFromJson)
  final int? esessId;
  final bool? resumed;
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
    this.examSession,
    this.esessId,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  @JsonKey(name: 'exam_session')
  final ExamStatsDto? examSession;
  @JsonKey(name: 'esess_id', fromJson: _intFromJson)
  final int? esessId;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SubmitExamResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitExamResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitExamResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamDetailResponseDto {
  const ExamDetailResponseDto({
    required this.mstatus,
    this.exam,
    this.exams = const <GeneratedExamDto>[],
    this.examSession,
    this.practicePreview,
    this.details = const <ExamDetailAnswerDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final GeneratedExamDto? exam;
  final List<GeneratedExamDto> exams;
  final ExamStatsDto? examSession;
  final ExamPracticePreviewDto? practicePreview;
  final List<ExamDetailAnswerDto> details;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ExamDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailResponseDtoToJson(this);
}

class ExamPracticePreviewDto {
  const ExamPracticePreviewDto({
    this.baseElinkId,
    this.mode,
    this.strongTopics = const <ExamPracticeTopicDto>[],
    this.weakTopics = const <ExamPracticeTopicDto>[],
  });

  final int? baseElinkId;
  final String? mode;
  final List<ExamPracticeTopicDto> strongTopics;
  final List<ExamPracticeTopicDto> weakTopics;

  factory ExamPracticePreviewDto.fromJson(Map<String, dynamic> json) {
    return ExamPracticePreviewDto(
      baseElinkId: _intFromJson(json['base_elink_id']),
      mode: json['mode']?.toString(),
      strongTopics: _practiceTopicsFromJson(json['strong_topics']),
      weakTopics: _practiceTopicsFromJson(json['weak_topics']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'base_elink_id': baseElinkId,
    'mode': mode,
    'strong_topics': strongTopics.map((topic) => topic.toJson()).toList(),
    'weak_topics': weakTopics.map((topic) => topic.toJson()).toList(),
  };
}

class ExamPracticeTopicDto {
  const ExamPracticeTopicDto({
    required this.topic,
    this.answered = 0,
    this.wrong = 0,
  });

  final String topic;
  final int answered;
  final int wrong;

  factory ExamPracticeTopicDto.fromJson(Map<String, dynamic> json) {
    return ExamPracticeTopicDto(
      topic: json['topic']?.toString().trim() ?? '',
      answered: _intFromJson(json['answered']) ?? 0,
      wrong: _intFromJson(json['wrong']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'topic': topic,
    'answered': answered,
    'wrong': wrong,
  };
}

List<ExamPracticeTopicDto> _practiceTopicsFromJson(Object? value) {
  if (value is! List) {
    return const <ExamPracticeTopicDto>[];
  }
  return value
      .whereType<Map>()
      .map(
        (topic) =>
            ExamPracticeTopicDto.fromJson(Map<String, dynamic>.from(topic)),
      )
      .where((topic) => topic.topic.isNotEmpty)
      .toList(growable: false);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamDetailAnswerDto {
  const ExamDetailAnswerDto({
    required this.questionNumber,
    this.options = const <ExamAnswerDto>[],
    this.elinkId,
    this.userExamDetailId,
    this.detailStatus,
    this.questionGrade,
    this.questionLevel,
    this.questionText,
    this.questionTopic,
    this.renderType,
    this.rightAnswerText,
    this.childAnswerText,
    this.isCorrect,
    this.questionKind = 'SINGLE_CHOICE',
    this.rightOptionIds = const [],
    this.childOptionIds = const [],
    this.questionImageUrl,
  });

  final int questionNumber;
  @JsonKey(name: 'options')
  final List<ExamAnswerDto> options;
  @JsonKey(name: 'elink_id', fromJson: _intFromJson)
  final int? elinkId;
  @JsonKey(name: 'esess_ln_id', fromJson: _intFromJson)
  final int? userExamDetailId;
  @JsonKey(name: 'esess_ln_status')
  final String? detailStatus;
  @JsonKey(fromJson: _intFromJson)
  final int? questionGrade;
  @JsonKey(fromJson: _intFromJson)
  final int? questionLevel;
  final String? questionText;
  final String? questionTopic;
  final String? renderType;
  final String? rightAnswerText;
  final String? childAnswerText;
  final bool? isCorrect;
  final String questionKind;
  final List<String> rightOptionIds;
  final List<String> childOptionIds;
  final String? questionImageUrl;

  factory ExamDetailAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamStatsResponseDto {
  const ExamStatsResponseDto({
    required this.mstatus,
    this.cursor,
    this.examSessions = const <ExamStatsDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final ExamSessionCursorDto? cursor;
  final List<ExamStatsDto> examSessions;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ExamStatsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStatsResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamSessionCursorDto {
  const ExamSessionCursorDto({
    this.startCursor,
    this.endCursor,
    this.hasNext,
    this.hasPrev,
  });

  final String? startCursor;
  final String? endCursor;
  final bool? hasNext;
  final bool? hasPrev;

  factory ExamSessionCursorDto.fromJson(Map<String, dynamic> json) =>
      _$ExamSessionCursorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSessionCursorDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExamStatsDto {
  const ExamStatsDto({
    required this.correctNumber,
    required this.scorePercentage,
    required this.skippedNumber,
    required this.totalQuestions,
    this.examType,
    this.esessId,
    this.status,
    this.grade,
    this.level,
    this.lastSubmittedDt,
    this.endedDt,
    this.createDt,
    this.esessFlag,
    this.isLatest,
    this.review,
    this.title,
    this.shortText,
    this.aiReviewShort,
    this.aiReviewLong,
    this.inProgressExam,
    this.inProgressExams = const <GeneratedExamDto>[],
  });

  final int correctNumber;
  @JsonKey(fromJson: _doubleFromJson)
  final double scorePercentage;
  final int skippedNumber;
  final int totalQuestions;
  final String? examType;
  @JsonKey(name: 'esess_id', fromJson: _intFromJson)
  final int? esessId;
  @JsonKey(readValue: _readEsessStatus)
  final String? status;
  final int? grade;
  final int? level;
  @JsonKey(fromJson: tryParseApiDateTime)
  final DateTime? lastSubmittedDt;
  @JsonKey(fromJson: tryParseApiDateTime)
  final DateTime? endedDt;
  @JsonKey(fromJson: tryParseApiDateTime)
  final DateTime? createDt;
  @JsonKey(name: 'esess_flag')
  final bool? esessFlag;
  final bool? isLatest;
  final String? review;
  final String? title;
  final String? shortText;
  final String? aiReviewShort;
  final String? aiReviewLong;
  final GeneratedExamDto? inProgressExam;
  final List<GeneratedExamDto> inProgressExams;

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
  @JsonKey(fromJson: tryParseApiDateTime)
  final DateTime? fromDt;
  @JsonKey(fromJson: tryParseApiDateTime)
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
    required this.lastSubmittedDt,
    required this.correctNumber,
    required this.esessId,
    required this.score,
    required this.scorePct,
    required this.sequence,
    required this.totalQuestions,
    this.examType,
    this.status,
    this.grade,
    this.level,
  });

  @JsonKey(fromJson: parseApiDateTime)
  final DateTime lastSubmittedDt;
  final int correctNumber;
  @JsonKey(name: 'esess_id')
  final int esessId;
  @JsonKey(fromJson: _doubleFromJson)
  final double score;
  @JsonKey(fromJson: _doubleFromJson)
  final double scorePct;
  final int sequence;
  final int totalQuestions;
  final String? examType;
  final String? status;
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
    this.highestEsessId,
  });

  @JsonKey(fromJson: _nullableDoubleFromJson)
  final double? averageDelta;
  @JsonKey(fromJson: _doubleFromJson)
  final double averageScore;
  @JsonKey(fromJson: _doubleFromJson)
  final double averageScorePct;
  final int count;
  @JsonKey(name: 'highest_esess_id')
  final int? highestEsessId;
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

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GeneratedExamDto {
  const GeneratedExamDto({
    this.examId,
    this.elinkId,
    this.esessId,
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

  @JsonKey(name: 'exam_id', fromJson: _intFromJson)
  final int? examId;
  @JsonKey(name: 'elink_id', fromJson: _intFromJson)
  final int? elinkId;
  @JsonKey(name: 'esess_id', fromJson: _intFromJson)
  final int? esessId;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  @JsonKey(readValue: _readElinkStatus)
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
    required this.questionText,
    required this.questionNumber,
    required this.options,
    this.correctAnswer,
    this.questionKind = 'SINGLE_CHOICE',
    this.questionImageUrl,
    this.questionGrade,
    this.questionLevel,
    this.questionTopic,
    this.renderType,
  });

  final String questionText;
  final int questionNumber;
  @JsonKey(defaultValue: <ExamAnswerDto>[])
  final List<ExamAnswerDto> options;
  final ExamCorrectAnswerDto? correctAnswer;
  final String questionKind;
  final String? questionImageUrl;
  @JsonKey(fromJson: _intFromJson)
  final int? questionGrade;
  @JsonKey(fromJson: _intFromJson)
  final int? questionLevel;
  final String? questionTopic;
  final String? renderType;

  factory ExamQuestionDto.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ExamCorrectAnswerDto {
  const ExamCorrectAnswerDto({this.optionIds, this.value, this.values});

  final List<String>? optionIds;
  final bool? value;
  final List<String>? values;

  factory ExamCorrectAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$ExamCorrectAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamCorrectAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ExamAnswerDto {
  const ExamAnswerDto({required this.text, required this.id, this.imageUrl});

  @JsonKey(defaultValue: '')
  final String text;
  final String id;
  final String? imageUrl;

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

Object? _readEsessStatus(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['esess_status'];

Object? _readElinkStatus(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['elink_status'] ?? json['exam_status'];
