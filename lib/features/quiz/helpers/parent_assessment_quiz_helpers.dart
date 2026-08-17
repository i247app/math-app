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

class CompletedParentAssessmentPage {
  const CompletedParentAssessmentPage({
    required this.quizzes,
    required this.allQuizzes,
    required this.pagination,
  });

  final List<GeneratedQuiz> quizzes;
  final List<GeneratedQuiz> allQuizzes;
  final QuizPagination pagination;
}

Future<CompletedParentAssessmentPage> loadCompletedParentAssessments({
  required QuizService quizService,
  required int? profileId,
  required int? userId,
  required int page,
  required int size,
  bool allowUserFallback = true,
}) async {
  List<GeneratedQuiz> completed(List<GeneratedQuiz> quizzes) {
    return quizzes.where(isCompletedAssessment).toList(growable: false)
      ..sort((a, b) => quizDate(b).compareTo(quizDate(a)));
  }

  CompletedParentAssessmentPage paginate(List<GeneratedQuiz> quizzes) {
    final assessments = completed(quizzes);
    final totalCount = assessments.length;
    final totalPages = totalCount == 0 ? 1 : (totalCount + size - 1) ~/ size;
    final currentPage = page < 1
        ? 1
        : page > totalPages
        ? totalPages
        : page;
    final start = (currentPage - 1) * size;
    final end = start + size < totalCount ? start + size : totalCount;
    return CompletedParentAssessmentPage(
      quizzes: assessments.sublist(start, end),
      allQuizzes: assessments,
      pagination: QuizPagination(
        page: currentPage,
        size: size,
        totalCount: totalCount,
        totalPages: totalPages,
        hasNext: currentPage < totalPages,
        hasPrevious: currentPage > 1,
      ),
    );
  }

  Future<List<GeneratedQuiz>> loadAll({int? profileId, int? userId}) async {
    final firstResponse = await quizService.listQuizPage(
      profileId: profileId,
      userId: userId,
      page: 1,
      size: size,
      takeAll: true,
    );
    final quizzes = <GeneratedQuiz>[...firstResponse.quizzes];
    final pagination = firstResponse.pagination;
    if (pagination?.takeAll == true || pagination?.hasNext != true) {
      return quizzes;
    }

    final totalPages = pagination?.totalPages ?? 1;
    for (var nextPage = 2; nextPage <= totalPages; nextPage++) {
      final response = await quizService.listQuizPage(
        profileId: profileId,
        userId: userId,
        page: nextPage,
        size: size,
      );
      quizzes.addAll(response.quizzes);
      if (response.pagination?.hasNext == false) {
        break;
      }
    }
    return quizzes;
  }

  Object? profileError;
  if (profileId != null && profileId > 0) {
    try {
      final quizzes = await loadAll(profileId: profileId);
      final assessments = completed(quizzes);
      if (assessments.isNotEmpty) {
        return paginate(assessments);
      }
    } catch (error) {
      profileError = error;
    }
  }
  if (allowUserFallback && userId != null && userId > 0) {
    try {
      return paginate(await loadAll(userId: userId));
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
  return paginate(const <GeneratedQuiz>[]);
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
