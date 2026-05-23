import 'package:json_annotation/json_annotation.dart';

part 'quiz_models.g.dart';

@JsonSerializable(includeIfNull: false)
class GenerateQuizRequest {
  const GenerateQuizRequest({
    required this.type,
    this.gradeLabel,
    this.previousQuizId,
  });

  final String type;
  @JsonKey(name: 'grade_label')
  final String? gradeLabel;
  @JsonKey(name: 'previous_quiz_id')
  final String? previousQuizId;

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
class GeneratedQuiz {
  const GeneratedQuiz({
    this.id,
    this.quizId,
    this.quizStatus,
    this.type,
    this.userId,
    this.createDt,
    this.modifyDt,
    this.grading,
    required this.questions,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? quizId;
  final String? quizStatus;
  final String? type;
  final String? userId;
  final String? createDt;
  final String? modifyDt;
  final QuizGrading? grading;
  @JsonKey(defaultValue: <QuizQuestion>[])
  final List<QuizQuestion> questions;

  factory GeneratedQuiz.fromJson(Map<String, dynamic> json) =>
      _$GeneratedQuizFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedQuizToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizGrading {
  const QuizGrading({
    this.aiReview,
    this.correctNumber,
    this.scorePercentage,
    this.totalQuestions,
  });

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
  });

  final String questionName;
  final int questionNumber;
  @JsonKey(defaultValue: <QuizAnswer>[])
  final List<QuizAnswer> answers;

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
