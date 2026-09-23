import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';

Future<void> openInitialAssessmentFromHome({
  required BuildContext context,
  required ExamService examService,
  required int? profileId,
  required String? gradeLabel,
}) async {
  final homeRoute = ModalRoute.of(context);
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);

  List<ExamStats>? stats;
  try {
    stats = profileId == null || profileId <= 0
        ? null
        : await examService.getExamStats(
            profileId: profileId,
            examType: examTypeAssessment,
          );
  } catch (_) {
    if (!context.mounted) return;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.getText(AppKeys.parentExamLoadFailed))),
      );
    return;
  }
  if (!context.mounted) return;

  final activeExam = stats == null ? null : latestActiveAssessmentExam(stats);
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => AiAssessmentScreen(
        examService: examService,
        initialExam: activeExam,
        examType: activeExam?.examType ?? examTypeAssessment,
        gradeLabel: activeExam == null
            ? gradeLabel
            : AssessmentFlowPolicy.gradeLabel(activeExam.grade ?? 0),
        profileId: profileId,
        allowQuestionNavigation: false,
        showQuestionNavigation: false,
        isResumedAssessment: activeExam != null,
        onResultBack: () {
          if (!context.mounted) return;
          navigator.popUntil(
            (route) =>
                homeRoute == null ? route.isFirst : identical(route, homeRoute),
          );
        },
      ),
    ),
  );
}
