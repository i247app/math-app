import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

bool isCompletedAssessment(GeneratedQuiz quiz) {
  final purpose = (quiz.purpose ?? quiz.type ?? '').trim().toUpperCase();
  final status = quiz.quizStatus?.trim().toUpperCase();
  return purpose == quizPurposeAssessment &&
      (status == 'SUBMITTED' || quiz.grading?.scorePercentage != null);
}

Future<List<GeneratedQuiz>> loadCompletedParentAssessments({
  required QuizService quizService,
  required int? profileId,
  required int? userId,
}) async {
  List<GeneratedQuiz> completed(List<GeneratedQuiz> quizzes) {
    return quizzes.where(isCompletedAssessment).toList(growable: false)
      ..sort((a, b) => quizDate(b).compareTo(quizDate(a)));
  }

  Object? profileError;
  if (profileId != null && profileId > 0) {
    try {
      final quizzes = await quizService.listQuizzes(profileId: profileId);
      final assessments = completed(quizzes);
      if (assessments.isNotEmpty) return assessments;
    } catch (error) {
      profileError = error;
    }
  }
  if (userId != null && userId > 0) {
    try {
      return completed(await quizService.listQuizzes(userId: userId));
    } catch (_) {
      if (profileError != null) {
        Error.throwWithStackTrace(profileError, StackTrace.current);
      }
      rethrow;
    }
  }
  if (profileError != null) {
    Error.throwWithStackTrace(profileError, StackTrace.current);
  }
  return const <GeneratedQuiz>[];
}

DateTime quizDate(GeneratedQuiz quiz) =>
    DateTime.tryParse(quiz.modifyDt ?? quiz.createDt ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

String homeQuizDateLabel(GeneratedQuiz quiz) {
  final date = quizDate(quiz).toLocal();
  if (date.millisecondsSinceEpoch == 0) return '--/--/----';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String homeQuizTitle(BuildContext context, GeneratedQuiz quiz) {
  final title = quiz.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  final grade = quiz.grading?.aiDetectGrade?.trim();
  if (grade != null && grade.isNotEmpty) {
    return '${context.getText(AppKeys.mathAssessment)} $grade';
  }
  return context.getText(AppKeys.mathAssessment);
}

String? homeQuizShortText(GeneratedQuiz quiz) {
  final value = quiz.shortText?.trim();
  return value == null || value.isEmpty ? null : value;
}
