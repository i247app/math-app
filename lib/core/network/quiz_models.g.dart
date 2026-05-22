// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateQuizRequest _$GenerateQuizRequestFromJson(Map<String, dynamic> json) =>
    GenerateQuizRequest(
      type: json['type'] as String,
      gradeLabel: json['grade_label'] as String,
    );

Map<String, dynamic> _$GenerateQuizRequestToJson(
        GenerateQuizRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'grade_label': instance.gradeLabel,
    };

SubmitQuizRequest _$SubmitQuizRequestFromJson(Map<String, dynamic> json) =>
    SubmitQuizRequest(
      quizId: json['quiz_id'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => SubmitQuizAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmitQuizRequestToJson(
        SubmitQuizRequest instance) =>
    <String, dynamic>{
      'quiz_id': instance.quizId,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

SubmitQuizAnswer _$SubmitQuizAnswerFromJson(Map<String, dynamic> json) =>
    SubmitQuizAnswer(
      questionNumber: (json['question_number'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$SubmitQuizAnswerToJson(SubmitQuizAnswer instance) =>
    <String, dynamic>{
      'question_number': instance.questionNumber,
      'label': instance.label,
    };

GenerateQuizResponse _$GenerateQuizResponseFromJson(
        Map<String, dynamic> json) =>
    GenerateQuizResponse(
      mstatus: (json['mstatus'] as num).toInt(),
      quiz: json['quiz'] == null
          ? null
          : GeneratedQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );

Map<String, dynamic> _$GenerateQuizResponseToJson(
        GenerateQuizResponse instance) =>
    <String, dynamic>{
      'mstatus': instance.mstatus,
      'quiz': instance.quiz?.toJson(),
      'status': instance.status,
      'mmessage': instance.mmessage,
      'debug': instance.debug,
    };

SubmitQuizResponse _$SubmitQuizResponseFromJson(Map<String, dynamic> json) =>
    SubmitQuizResponse(
      mstatus: (json['mstatus'] as num).toInt(),
      quiz: json['quiz'] == null
          ? null
          : GeneratedQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );

Map<String, dynamic> _$SubmitQuizResponseToJson(
        SubmitQuizResponse instance) =>
    <String, dynamic>{
      'mstatus': instance.mstatus,
      'quiz': instance.quiz?.toJson(),
      'status': instance.status,
      'mmessage': instance.mmessage,
      'debug': instance.debug,
    };

GeneratedQuiz _$GeneratedQuizFromJson(Map<String, dynamic> json) =>
    GeneratedQuiz(
      id: _stringFromJson(json['id']),
      quizId: json['quiz_id'] as String?,
      quizStatus: json['quiz_status'] as String?,
      type: json['type'] as String?,
      userId: json['user_id'] as String?,
      createDt: json['create_dt'] as String?,
      modifyDt: json['modify_dt'] as String?,
      grading: json['grading'] == null
          ? null
          : QuizGrading.fromJson(json['grading'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$GeneratedQuizToJson(GeneratedQuiz instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quiz_id': instance.quizId,
      'quiz_status': instance.quizStatus,
      'type': instance.type,
      'user_id': instance.userId,
      'create_dt': instance.createDt,
      'modify_dt': instance.modifyDt,
      'grading': instance.grading?.toJson(),
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

QuizGrading _$QuizGradingFromJson(Map<String, dynamic> json) => QuizGrading(
      aiReview: json['ai_review'] as String?,
      correctNumber: (json['correct_number'] as num?)?.toInt(),
      scorePercentage: (json['score_percentage'] as num?)?.toInt(),
      totalQuestions: (json['total_questions'] as num?)?.toInt(),
    );

Map<String, dynamic> _$QuizGradingToJson(QuizGrading instance) =>
    <String, dynamic>{
      'ai_review': instance.aiReview,
      'correct_number': instance.correctNumber,
      'score_percentage': instance.scorePercentage,
      'total_questions': instance.totalQuestions,
    };

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) => QuizQuestion(
      questionName: json['question_name'] as String,
      questionNumber: (json['question_number'] as num).toInt(),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'question_name': instance.questionName,
      'question_number': instance.questionNumber,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

QuizAnswer _$QuizAnswerFromJson(Map<String, dynamic> json) => QuizAnswer(
      content: json['content'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$QuizAnswerToJson(QuizAnswer instance) =>
    <String, dynamic>{
      'content': instance.content,
      'label': instance.label,
    };
