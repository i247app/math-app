import 'package:json_annotation/json_annotation.dart';

import '../base/base_response.dart';

part 'generate_quiz_response.g.dart';

@JsonSerializable()
class GenerateQuizResponse extends BaseResponse {
  final GenerateQuizResult result;

  GenerateQuizResponse({
    required super.message,
    required this.result,
    required super.status,
  });

  factory GenerateQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GenerateQuizResponseToJson(this);
}

@JsonSerializable()
class GenerateQuizResult {
  @JsonKey(name: 'user_latest_quiz_id')
  final String? userLatestQuizId;
  final String response;
  final List<QuizQuestion> data;
  final String role;
  final String model;
  final String timestamp;

  GenerateQuizResult({
    this.userLatestQuizId,
    required this.response,
    required this.data,
    required this.role,
    required this.model,
    required this.timestamp,
  });

  factory GenerateQuizResult.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuizResultFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuizResultToJson(this);
}

@JsonSerializable()
class QuizQuestion {
  @JsonKey(name: 'question_number')
  final int questionNumber;
  @JsonKey(name: 'question_name')
  final String questionName;
  final List<QuizAnswer> answers;
  @JsonKey(name: 'right_answer')
  final String rightAnswer;

  QuizQuestion({
    required this.questionNumber,
    required this.questionName,
    required this.answers,
    required this.rightAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class QuizAnswer {
  final String label;
  final String content;

  QuizAnswer({required this.label, required this.content});

  factory QuizAnswer.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAnswerToJson(this);
}
