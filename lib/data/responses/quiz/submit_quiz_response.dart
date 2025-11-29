import 'package:json_annotation/json_annotation.dart';

import '../base/base_response.dart';

part 'submit_quiz_response.g.dart';

@JsonSerializable()
class SubmitQuizResponse extends BaseResponse {
  final SubmitQuizResult result;

  SubmitQuizResponse({
    required super.message,
    required this.result,
    required super.status,
  });

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubmitQuizResponseToJson(this);
}

@JsonSerializable()
class SubmitQuizResult {
  @JsonKey(name: 'user_latest_quiz_id')
  final String userLatestQuizId;
  final String response;
  final QuizResultData data;
  final String role;
  final String model;
  final String timestamp;

  SubmitQuizResult({
    required this.userLatestQuizId,
    required this.response,
    required this.data,
    required this.role,
    required this.model,
    required this.timestamp,
  });

  factory SubmitQuizResult.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResultFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitQuizResultToJson(this);
}

@JsonSerializable()
class QuizResultData {
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'correct_number')
  final int correctNumber;
  @JsonKey(name: 'score_percentage')
  final int scorePercentage;
  @JsonKey(name: 'ai_review')
  final String aiReview;

  QuizResultData({
    required this.totalQuestions,
    required this.correctNumber,
    required this.scorePercentage,
    required this.aiReview,
  });

  factory QuizResultData.fromJson(Map<String, dynamic> json) =>
      _$QuizResultDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuizResultDataToJson(this);
}
