import 'package:numi/core/helpers/api_date_time.dart';

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

/// Return the resumable exam carried by an active assessment journey.
GeneratedExam? activeInProgressAssessmentExam(ExamStats stats) {
  final status = stats.status?.trim().toUpperCase();
  if (status == 'COMPLETE' || status == 'SUBMITTED' || status == 'CANCEL') {
    return null;
  }
  final outerIsActive = status == 'ACTIVE' || status == 'IN_PROGRESS';
  final candidates = stats.inProgressExams.where((exam) {
    final examStatus = exam.examStatus?.trim().toUpperCase();
    return exam.questions.isNotEmpty &&
        (outerIsActive ||
            examStatus == 'ACTIVE' ||
            examStatus == 'IN_PROGRESS');
  });
  GeneratedExam? latest;
  for (final exam in candidates) {
    if (latest == null || examDate(exam).isAfter(examDate(latest))) {
      latest = exam;
    }
  }
  return latest;
}

GeneratedExam? latestActiveAssessmentExam(Iterable<ExamStats> stats) {
  GeneratedExam? latest;
  for (final item in stats) {
    final exam = activeInProgressAssessmentExam(item);
    if (exam != null &&
        (latest == null || examDate(exam).isAfter(examDate(latest)))) {
      latest = exam;
    }
  }
  return latest;
}

bool isCompletedAssessmentStats(ExamStats stats) {
  if (activeInProgressAssessmentExam(stats) != null) return false;
  final status = stats.status?.trim().toUpperCase();
  return status == null ||
      status.isEmpty ||
      status == 'COMPLETE' ||
      status == 'SUBMITTED';
}

GeneratedExam completedAssessmentFromStats(
  ExamStats stats, {
  required int profileId,
  String fallbackExamType = examTypeAssessment,
}) {
  final submittedAt = stats.lastSubmittedDt?.toIso8601String();
  return GeneratedExam(
    userExamId: stats.userExamId,
    profileId: profileId,
    examStatus: stats.status,
    examType: stats.examType ?? fallbackExamType,
    grade: stats.grade,
    level: stats.level,
    createDt: submittedAt,
    modifyDt: submittedAt,
    review: stats.review,
    title: stats.title,
    shortText: stats.shortText,
    aiReviewShort: stats.aiReviewShort,
    aiReviewLong: stats.aiReviewLong,
    grading: ExamGrading(
      aiDetectGrade: stats.grade == null ? null : 'Lớp ${stats.grade}',
      aiReview: stats.review,
      correctNumber: stats.correctNumber,
      scorePercentage: stats.scorePercentage.round(),
      skippedNumber: stats.skippedNumber,
      totalQuestions: stats.totalQuestions,
    ),
    questions: const <ExamQuestion>[],
  );
}

DateTime examDate(GeneratedExam exam) =>
    tryParseApiDateTime(exam.modifyDt ?? exam.createDt ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

String homeExamDateLabel(GeneratedExam exam) {
  final date = examDate(exam).toLocal();
  if (date.millisecondsSinceEpoch == 0) return '--/--/----';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String homeExamTitle(BuildContext context, GeneratedExam exam) {
  final numericGrade = exam.grade;
  final level = exam.level;
  final normalizedExamType = exam.examType?.trim().toUpperCase();
  if (normalizedExamType == examTypeGrade &&
      numericGrade != null &&
      level != null) {
    return context.formatText(AppKeys.gradeLevelExamTitle, {
      'grade': numericGrade,
      'level': level,
    });
  }
  if (normalizedExamType == examTypeAssessment && numericGrade != null) {
    if (numericGrade == 0) {
      return context.getText(AppKeys.assessmentListKindergartenTitle);
    }
    return context.formatText(AppKeys.assessmentListGradeTitle, {
      'grade': numericGrade,
    });
  }

  final title = exam.title?.trim();
  if (title != null && title.isNotEmpty) return title;
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

String? homeExamReview(GeneratedExam exam) {
  final review = (exam.review ?? exam.shortText)?.trim();
  return review == null || review.isEmpty ? null : review;
}
