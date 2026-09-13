import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';

/// Exam-specific route into the shared review-detail layout.
class ExamReviewScreen extends StatelessWidget {
  const ExamReviewScreen({
    super.key,
    this.examId,
    this.userExamId,
    this.profileId,
    this.initialExam,
  }) : assert(examId != null || userExamId != null);

  final int? examId;
  final int? userExamId;
  final int? profileId;
  final GeneratedExam? initialExam;

  @override
  Widget build(BuildContext context) {
    final examService = context.read<ExamService>();
    final detailId = userExamId ?? examId!;
    final isEntireJourney = userExamId != null;
    return ReviewDetailScreen(
      detailId: detailId,
      detailLoader: (detailId) => examService.getExamDetail(
        detailId,
        profileId: profileId ?? initialExam?.profileId,
        userExamId: userExamId,
      ),
      initialDetail: initialExam,
      cacheKey: isEntireJourney
          ? (type: 'assessment-journey', userExamId: userExamId)
          : null,
    );
  }
}
