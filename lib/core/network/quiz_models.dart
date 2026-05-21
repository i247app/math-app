import 'package:json_annotation/json_annotation.dart';

part 'quiz_models.g.dart';

@JsonSerializable()
class GenerateQuizRequest {
  const GenerateQuizRequest({
    required this.type,
    required this.gradeLabel,
  });

  final String type;
  @JsonKey(name: 'grade_label')
  final String gradeLabel;

  factory GenerateQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizRequestToJson(this);
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

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GeneratedQuiz {
  const GeneratedQuiz({
    this.id,
    this.quizId,
    this.quizStatus,
    this.type,
    this.createDt,
    this.modifyDt,
    required this.questions,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? quizId;
  final String? quizStatus;
  final String? type;
  final String? createDt;
  final String? modifyDt;
  @JsonKey(defaultValue: <QuizQuestion>[])
  final List<QuizQuestion> questions;

  factory GeneratedQuiz.fromJson(Map<String, dynamic> json) =>
      _$GeneratedQuizFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedQuizToJson(this);
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
