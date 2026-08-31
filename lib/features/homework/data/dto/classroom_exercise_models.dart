import 'package:json_annotation/json_annotation.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

part 'classroom_exercise_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ClassroomExerciseListRequest {
  const ClassroomExerciseListRequest({
    required this.classroomId,
    required this.profileId,
    this.search,
    this.visibility,
    this.submissionStatus,
    this.purpose,
  });

  final int classroomId;
  final int profileId;
  final String? search;
  final String? visibility;
  final String? submissionStatus;
  final String? purpose;

  factory ClassroomExerciseListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomExerciseListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomExerciseListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UpdateClassroomExerciseRequest {
  const UpdateClassroomExerciseRequest({
    required this.profileId,
    required this.classroomExerciseId,
    required this.visibility,
    this.purpose = classroomExercisePurposeHomework,
  });

  final int profileId;
  final int classroomExerciseId;
  final String visibility;
  final String purpose;

  factory UpdateClassroomExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateClassroomExerciseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateClassroomExerciseRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SubmitClassroomExerciseRequest {
  const SubmitClassroomExerciseRequest({
    required this.profileId,
    required this.classroomExerciseId,
    required this.answers,
  });

  final int profileId;
  final int classroomExerciseId;
  final List<SubmitClassroomExerciseAnswerDto> answers;

  factory SubmitClassroomExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitClassroomExerciseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitClassroomExerciseRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class SubmitClassroomExerciseAnswerDto {
  const SubmitClassroomExerciseAnswerDto({
    required this.questionNumber,
    required this.label,
    this.answer,
    this.answerContent,
  });

  final int questionNumber;
  final String label;
  final String? answer;
  final String? answerContent;

  factory SubmitClassroomExerciseAnswerDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SubmitClassroomExerciseAnswerDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SubmitClassroomExerciseAnswerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateClassroomExerciseRequest {
  const CreateClassroomExerciseRequest({
    required this.profileId,
    required this.classroomId,
    required this.programId,
    required this.title,
    required this.description,
    required this.numQuestions,
    required this.chapterName,
    required this.lessonName,
    required this.visibility,
    required this.startDate,
    required this.endDate,
    this.purpose = classroomExercisePurposeHomework,
    this.metadata,
  });

  final Map<String, dynamic>? metadata;
  final int profileId;
  final int classroomId;
  final int programId;
  final String title;
  final String description;
  final int numQuestions;
  final String chapterName;
  final String lessonName;
  final String visibility;
  final String startDate;
  final String endDate;
  final String purpose;

  factory CreateClassroomExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateClassroomExerciseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateClassroomExerciseRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomExerciseSubmissionResponseDto {
  const ClassroomExerciseSubmissionResponseDto({
    required this.mstatus,
    this.grading,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _submissionGradingFromJson)
  final ClassroomExerciseSubmissionGradingDto? grading;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomExerciseSubmissionResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    final submission =
        json['submission'] ??
        json['classroom_exercise_submission'] ??
        _nestedValue(data, 'submission') ??
        _nestedValue(data, 'classroom_exercise_submission') ??
        data;
    final grading =
        json['grading'] ??
        json['result'] ??
        _nestedValue(json['submission'], 'grading') ??
        _nestedValue(json['submission'], 'result') ??
        _nestedValue(submission, 'grading') ??
        _nestedValue(submission, 'result') ??
        submission;

    return _$ClassroomExerciseSubmissionResponseDtoFromJson(<String, dynamic>{
      ...json,
      'grading': grading,
    });
  }

  Map<String, dynamic> toJson() =>
      _$ClassroomExerciseSubmissionResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomExerciseSubmissionGradingDto {
  const ClassroomExerciseSubmissionGradingDto({
    this.aiReview,
    this.correctNumber,
    this.scorePercentage,
    this.totalQuestions,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? aiReview;
  @JsonKey(fromJson: _intFromJson)
  final int? correctNumber;
  @JsonKey(fromJson: _intFromJson)
  final int? scorePercentage;
  @JsonKey(fromJson: _intFromJson)
  final int? totalQuestions;

  factory ClassroomExerciseSubmissionGradingDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$ClassroomExerciseSubmissionGradingDtoFromJson(<String, dynamic>{
      ...json,
      'ai_review':
          json['ai_review'] ??
          json['review'] ??
          json['feedback'] ??
          json['message'],
      'correct_number':
          json['correct_number'] ??
          json['correct_count'] ??
          json['correct_answers'],
      'score_percentage':
          json['score_percentage'] ?? json['score'] ?? json['percentage'],
      'total_questions':
          json['total_questions'] ?? json['question_count'] ?? json['total'],
    });
  }

  Map<String, dynamic> toJson() =>
      _$ClassroomExerciseSubmissionGradingDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomExerciseListResponse {
  const ClassroomExerciseListResponse({
    required this.mstatus,
    this.exercises = const <ClassroomExerciseDto>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _exerciseListFromJson)
  final List<ClassroomExerciseDto> exercises;
  final ClassroomExercisePagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomExerciseListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final exercisesValue =
        json['exercises'] ??
        json['classroom_exercises'] ??
        json['items'] ??
        _nestedValue(data, 'exercises') ??
        _nestedValue(data, 'classroom_exercises') ??
        _nestedValue(data, 'items') ??
        data;

    return _$ClassroomExerciseListResponseFromJson(<String, dynamic>{
      ...json,
      'exercises': exercisesValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomExerciseListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomExerciseResponse {
  const ClassroomExerciseResponse({
    required this.mstatus,
    this.exercise,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _exerciseFromJson)
  final ClassroomExerciseDto? exercise;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomExerciseResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final exerciseValue =
        json['exercise'] ??
        json['classroom_exercise'] ??
        _nestedValue(data, 'exercise') ??
        _nestedValue(data, 'classroom_exercise') ??
        data;

    return _$ClassroomExerciseResponseFromJson(<String, dynamic>{
      ...json,
      'mstatus': json['mstatus'] ?? (exerciseValue == null ? null : 200),
      'exercise': exerciseValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomExerciseResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomExercisePagination {
  const ClassroomExercisePagination({
    this.hasNext,
    this.hasPrevious,
    this.page,
    this.size,
    this.totalCount,
    this.totalPages,
  });

  final bool? hasNext;
  final bool? hasPrevious;
  @JsonKey(fromJson: _intFromJson)
  final int? page;
  @JsonKey(fromJson: _intFromJson)
  final int? size;
  @JsonKey(fromJson: _intFromJson)
  final int? totalCount;
  @JsonKey(fromJson: _intFromJson)
  final int? totalPages;

  factory ClassroomExercisePagination.fromJson(Map<String, dynamic> json) =>
      _$ClassroomExercisePaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomExercisePaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomExerciseDto {
  const ClassroomExerciseDto({
    this.id,
    this.exerciseId,
    this.classroomExerciseId,
    this.classroomId,
    this.profileId,
    this.programId,
    this.title,
    this.numQuestions,
    this.chapterName,
    this.lessonName,
    this.description,
    this.shortText,
    this.visibility,
    this.purpose,
    this.status,
    this.submissionStatus,
    this.startDate,
    this.endDate,
    this.createDt,
    this.modifyDt,
    this.metadata,
    this.questions = const <ClassroomExerciseQuestionDto>[],
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? exerciseId;
  @JsonKey(fromJson: _intFromJson)
  final int? classroomExerciseId;
  @JsonKey(fromJson: _intFromJson)
  final int? classroomId;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  @JsonKey(fromJson: _intFromJson)
  final int? programId;
  @JsonKey(fromJson: _stringFromJson)
  final String? title;
  @JsonKey(fromJson: _intFromJson)
  final int? numQuestions;
  @JsonKey(fromJson: _stringFromJson)
  final String? chapterName;
  @JsonKey(fromJson: _stringFromJson)
  final String? lessonName;
  @JsonKey(fromJson: _stringFromJson)
  final String? description;
  @JsonKey(fromJson: _stringFromJson)
  final String? shortText;
  @JsonKey(fromJson: _stringFromJson)
  final String? visibility;
  @JsonKey(fromJson: _stringFromJson)
  final String? purpose;
  @JsonKey(fromJson: _stringFromJson)
  final String? status;
  @JsonKey(fromJson: _stringFromJson)
  final String? submissionStatus;
  @JsonKey(fromJson: _stringFromJson)
  final String? startDate;
  @JsonKey(fromJson: _stringFromJson)
  final String? endDate;
  @JsonKey(fromJson: _stringFromJson)
  final String? createDt;
  @JsonKey(fromJson: _stringFromJson)
  final String? modifyDt;
  final Map<String, dynamic>? metadata;
  @JsonKey(fromJson: _questionListFromJson)
  final List<ClassroomExerciseQuestionDto> questions;

  factory ClassroomExerciseDto.fromJson(Map<String, dynamic> json) {
    final questionsValue =
        json['questions'] ??
        json['exercise_questions'] ??
        json['items'] ??
        _nestedValue(json['data'], 'questions') ??
        _nestedValue(json['data'], 'exercise_questions');

    return _$ClassroomExerciseDtoFromJson(<String, dynamic>{
      ...json,
      'exercise_id': json['exercise_id'] ?? json['assignment_id'],
      'classroom_exercise_id':
          json['classroom_exercise_id'] ?? json['assignment_id'],
      'num_questions': json['num_questions'] ?? json['total_questions'],
      'profile_id': json['profile_id'] ?? json['creator_profile_id'],
      'description':
          json['description'] ??
          json['assignment_description'] ??
          json['exercise_description'] ??
          json['short_text'] ??
          _nestedValue(json['metadata'], 'description'),
      'short_text':
          json['short_text'] ??
          json['short_description'] ??
          _nestedValue(json['metadata'], 'short_text') ??
          _nestedValue(json['metadata'], 'short_description'),
      'status': json['status'] ?? json['exercise_status'],
      'purpose': json['purpose'] ?? json['type'],
      'submission_status': json['submission_status'],
      'questions': questionsValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomExerciseDtoToJson(this);

  int? get stableId => classroomExerciseId ?? exerciseId ?? id;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomExerciseQuestionDto {
  const ClassroomExerciseQuestionDto({
    this.id,
    this.questionId,
    this.questionNumber,
    this.content,
    this.prompt,
    this.question,
    this.correctAnswer,
    this.answers = const <String>[],
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? questionId;
  @JsonKey(fromJson: _intFromJson)
  final int? questionNumber;
  @JsonKey(fromJson: _stringFromJson)
  final String? content;
  @JsonKey(fromJson: _stringFromJson)
  final String? prompt;
  @JsonKey(fromJson: _stringFromJson)
  final String? question;
  @JsonKey(fromJson: _stringFromJson)
  final String? correctAnswer;
  @JsonKey(fromJson: _stringListFromJson)
  final List<String> answers;

  factory ClassroomExerciseQuestionDto.fromJson(Map<String, dynamic> json) {
    return _$ClassroomExerciseQuestionDtoFromJson(<String, dynamic>{
      ...json,
      'question_id': json['question_id'] ?? json['id'],
      'question_number': json['question_number'] ?? json['number'],
      'content':
          json['content'] ??
          json['question_content'] ??
          json['question_text'] ??
          json['question_name'] ??
          json['text'],
      'answers': json['answers'] ?? json['options'] ?? json['choices'],
      'correct_answer':
          json['correct_answer'] ?? json['right_answer'] ?? json['answer'],
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomExerciseQuestionDtoToJson(this);

  String? get displayPrompt {
    final values = <String?>[content, prompt, question];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}

List<ClassroomExerciseDto> _exerciseListFromJson(Object? value) {
  return _listFromJson(value, ClassroomExerciseDto.fromJson);
}

ClassroomExerciseDto? _exerciseFromJson(Object? value) {
  return _objectFromJson(value, ClassroomExerciseDto.fromJson);
}

ClassroomExerciseSubmissionGradingDto? _submissionGradingFromJson(
  Object? value,
) {
  return _objectFromJson(value, ClassroomExerciseSubmissionGradingDto.fromJson);
}

List<ClassroomExerciseQuestionDto> _questionListFromJson(Object? value) {
  return _listFromJson(value, ClassroomExerciseQuestionDto.fromJson);
}

Object? _nestedValue(Object? value, String key) {
  if (value case final Map<String, dynamic> json) {
    return json[key];
  }
  if (value case final Map<Object?, Object?> json) {
    return json[key];
  }
  return null;
}

T? _objectFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value case final Map<String, dynamic> json) {
    return fromJson(json);
  }
  if (value case final Map<Object?, Object?> json) {
    return fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}

List<T> _listFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .map((item) => _objectFromJson(item, fromJson))
      .whereType<T>()
      .toList(growable: false);
}

int _requiredIntFromJson(Object? value) => _intFromJson(value) ?? 0;

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

String? _stringFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}

List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((item) {
        if (item case final Map<String, dynamic> json) {
          return _stringFromJson(
            json['content'] ?? json['value'] ?? json['label'],
          );
        }
        if (item case final Map<Object?, Object?> json) {
          return _stringFromJson(
            json['content'] ?? json['value'] ?? json['label'],
          );
        }
        return _stringFromJson(item);
      })
      .whereType<String>()
      .toList(growable: false);
}
