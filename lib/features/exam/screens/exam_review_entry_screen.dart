import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';

/// Exam-specific route into the shared review-detail layout.
class ExamReviewScreen extends StatelessWidget {
  const ExamReviewScreen({
    super.key,
    this.examId,
    this.userExamId,
    this.profileId,
    this.examType,
    this.initialExam,
  }) : assert(examId != null || userExamId != null);

  final int? examId;
  final int? userExamId;
  final int? profileId;
  final String? examType;
  final GeneratedExam? initialExam;

  @override
  Widget build(BuildContext context) {
    final examService = context.read<ExamService>();
    final detailId = userExamId ?? examId!;
    final isEntireJourney = userExamId != null;
    final resolvedExamType =
        (examType ?? initialExam?.examType ?? examTypeAssessment)
            .trim()
            .toUpperCase();
    return ReviewDetailScreen(
      detailId: detailId,
      detailLoader: (detailId) => examService.getExamDetail(
        detailId,
        profileId: profileId ?? initialExam?.profileId,
        userExamId: userExamId,
        examType: resolvedExamType,
      ),
      initialDetail: initialExam,
      cacheKey: isEntireJourney
          ? (
              type: '${resolvedExamType.toLowerCase()}-journey',
              userExamId: userExamId,
            )
          : null,
      onPractice: isEntireJourney
          ? (detail) async {
              final journeyId = detail.userExamId ?? userExamId;
              if (journeyId == null || journeyId <= 0) {
                throw ExamException(
                  AppStrings.current(AppKeys.missingExamIdShort),
                );
              }
              final practiceGrade = AssessmentFlowPolicy.clampGrade(
                detail.lastSetGrade ?? detail.grade ?? initialExam?.grade ?? 0,
              );
              final practiceProfileId =
                  detail.profileId ?? profileId ?? initialExam?.profileId;
              final generatedExam = await examService.generateAssessmentExam(
                examType: examTypePractice,
                gradeLabel: AssessmentFlowPolicy.gradeLabel(practiceGrade),
                profileId: practiceProfileId,
                userExamId: journeyId,
              );
              if (!context.mounted) {
                return;
              }
              ExamCache.seedDetail(generatedExam);
              final reviewRoute = ModalRoute.of(context);
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (practiceContext) => AiAssessmentScreen(
                    examService: examService,
                    initialExam: generatedExam,
                    examType: examTypePractice,
                    gradeLabel: AssessmentFlowPolicy.gradeLabel(practiceGrade),
                    profileId: practiceProfileId,
                    onResultBack: () {
                      final navigator = Navigator.of(practiceContext);
                      if (reviewRoute == null) {
                        navigator.popUntil((route) => route.isFirst);
                        return;
                      }
                      navigator.popUntil(
                        (route) => identical(route, reviewRoute),
                      );
                    },
                  ),
                ),
              );
            }
          : null,
    );
  }
}
