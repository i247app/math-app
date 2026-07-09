import 'package:flutter/widgets.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/models/profile_role.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/home/parent/home/models/parent_child_summary.dart';

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
      final profileQuizzes = await quizService.listQuizzes(
        profileId: profileId,
      );
      final profileAssessments = completed(profileQuizzes);
      if (profileAssessments.isNotEmpty) {
        return profileAssessments;
      }
    } catch (error) {
      profileError = error;
    }
  }

  if (userId != null && userId > 0) {
    try {
      final userQuizzes = await quizService.listQuizzes(userId: userId);
      return completed(userQuizzes);
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

DateTime quizDate(GeneratedQuiz quiz) {
  return DateTime.tryParse(quiz.modifyDt ?? quiz.createDt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String homeQuizDateLabel(GeneratedQuiz quiz) {
  final date = quizDate(quiz).toLocal();
  if (date.millisecondsSinceEpoch == 0) {
    return '--/--/----';
  }
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String homeQuizTitle(BuildContext context, GeneratedQuiz quiz) {
  final title = quiz.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final grade = quiz.grading?.aiDetectGrade?.trim();
  if (grade != null && grade.isNotEmpty) {
    return '${context.getText(AppKeys.mathAssessment)} $grade';
  }
  return context.getText(AppKeys.mathAssessment);
}

String? homeQuizShortText(GeneratedQuiz quiz) {
  final shortText = quiz.shortText?.trim();
  if (shortText == null || shortText.isEmpty) {
    return null;
  }
  return shortText;
}

List<StudentProfile> studentProfiles(List<StudentProfile> profiles) {
  return profiles
      .where(
        (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
      )
      .toList(growable: false);
}

String parentClassroomName(BuildContext context, ParentChildSummary summary) {
  final name = summary.classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final grade = summary.profile.grade?.label?.trim();
  if (grade != null && grade.isNotEmpty) {
    return grade;
  }
  return context.getText(AppKeys.parentNoClassroom);
}
