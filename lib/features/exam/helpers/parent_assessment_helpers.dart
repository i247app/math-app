import 'package:flutter/widgets.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';

bool isCompletedAssessment(GeneratedExam exam) {
  final examType = (exam.examType ?? '').trim().toUpperCase();
  final status = exam.examStatus?.trim().toUpperCase();
  return examType == examTypeAssessment &&
      (status == 'SUBMITTED' || exam.grading?.scorePercentage != null);
}

class CompletedParentAssessmentPage {
  const CompletedParentAssessmentPage({
    required this.exams,
    required this.allExams,
    required this.pagination,
  });

  final List<GeneratedExam> exams;
  final List<GeneratedExam> allExams;
  final ExamPagination pagination;
}

Future<CompletedParentAssessmentPage> loadCompletedParentAssessments({
  required ExamService examService,
  required int? profileId,
  required int? userId,
  required int page,
  required int size,
  bool allowUserFallback = true,
  bool useUnpaginatedList = false,
}) async {
  List<GeneratedExam> completed(List<GeneratedExam> exams) {
    return exams.where(isCompletedAssessment).toList(growable: false)
      ..sort((a, b) => examDate(b).compareTo(examDate(a)));
  }

  CompletedParentAssessmentPage paginate(List<GeneratedExam> exams) {
    final assessments = completed(exams);
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
      exams: assessments.sublist(start, end),
      allExams: assessments,
      pagination: ExamPagination(
        page: currentPage,
        size: size,
        totalCount: totalCount,
        totalPages: totalPages,
        hasNext: currentPage < totalPages,
        hasPrevious: currentPage > 1,
      ),
    );
  }

  Future<List<GeneratedExam>> loadAll({int? profileId, int? userId}) async {
    if (useUnpaginatedList) {
      return examService.listExams(profileId: profileId, userId: userId);
    }

    final firstResponse = await examService.listExamPage(
      profileId: profileId,
      userId: userId,
      page: 1,
      size: size,
      takeAll: true,
    );
    final exams = <GeneratedExam>[...firstResponse.exams];
    final pagination = firstResponse.pagination;
    if (pagination?.takeAll == true || pagination?.hasNext != true) {
      return exams;
    }

    final totalPages = pagination?.totalPages ?? 1;
    for (var nextPage = 2; nextPage <= totalPages; nextPage++) {
      final response = await examService.listExamPage(
        profileId: profileId,
        userId: userId,
        page: nextPage,
        size: size,
      );
      exams.addAll(response.exams);
      if (response.pagination?.hasNext == false) {
        break;
      }
    }
    return exams;
  }

  Object? profileError;
  if (profileId != null && profileId > 0) {
    try {
      // An empty response is a successful profile-scoped result, not a signal
      // to retry the Exam API with the unrelated user id.
      return paginate(await loadAll(profileId: profileId));
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
  return paginate(const <GeneratedExam>[]);
}

DateTime examDate(GeneratedExam exam) =>
    DateTime.tryParse(exam.modifyDt ?? exam.createDt ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

String homeExamDateLabel(GeneratedExam exam) {
  final date = examDate(exam).toLocal();
  if (date.millisecondsSinceEpoch == 0) return '--/--/----';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String homeExamTitle(BuildContext context, GeneratedExam exam) {
  final title = exam.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  final numericGrade = exam.grade;
  if (numericGrade != null) {
    if (numericGrade == 0) {
      return context.getText(AppKeys.kindergartenMathAssessment);
    }
    return context.formatText(AppKeys.gradeMathAssessment, {
      'grade': numericGrade,
    });
  }
  final grade = exam.grading?.aiDetectGrade?.trim();
  if (grade != null && grade.isNotEmpty) {
    return '${context.getText(AppKeys.mathAssessment)} $grade';
  }
  return context.getText(AppKeys.mathAssessment);
}

String? homeExamShortText(GeneratedExam exam) {
  final value = exam.shortText?.trim();
  return value == null || value.isEmpty ? null : value;
}
