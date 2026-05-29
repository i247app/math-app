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
  });

  final String purpose;
  @JsonKey(name: 'type_of_quiz')
  final String typeOfQuiz;
  @JsonKey(name: 'grade_label')
  final String? gradeLabel;
  @JsonKey(name: 'previous_quiz_id')
  final String? previousQuizId;
  final List<String>? chapters;

  factory GenerateQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SubmitQuizRequest {
  const SubmitQuizRequest({
    required this.quizId,
    required this.answers,
  });

  final String quizId;
  final List<SubmitQuizAnswer> answers;

  factory SubmitQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitQuizAnswer {
  const SubmitQuizAnswer({
    required this.questionNumber,
    required this.label,
  });

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
  });

  final String? userId;
  final String? profileId;

  factory QuizListRequest.fromJson(Map<String, dynamic> json) =>
      _$QuizListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuizListRequestToJson(this);
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
  @JsonKey(defaultValue: <GeneratedQuiz>[])
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
    this.quizStatus,
    this.purpose,
    this.typeOfQuiz,
    this.type,
    this.title,
    this.userId,
    this.createDt,
    this.modifyDt,
    this.grading,
    this.answers = const <SubmitQuizAnswer>[],
    required this.questions,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? quizId;
  final String? previousQuizId;
  final String? quizStatus;
  final String? purpose;
  @JsonKey(name: 'type_of_quiz')
  final String? typeOfQuiz;
  final String? type;
  final String? title;
  final String? userId;
  final String? createDt;
  final String? modifyDt;
  final QuizGrading? grading;
  @JsonKey(defaultValue: <SubmitQuizAnswer>[])
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
  });

  final String questionName;
  final int questionNumber;
  @JsonKey(defaultValue: <QuizAnswer>[])
  final List<QuizAnswer> answers;
  final String? rightAnswer;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class QuizAnswer {
  const QuizAnswer({
    required this.content,
    required this.label,
  });

  final String content;
  final String label;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAnswerToJson(this);
}

String? _stringFromJson(Object? value) => value?.toString();
