import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';

/// Exam-specific route into the shared review-detail layout.
class ExamReviewScreen extends StatelessWidget {
  const ExamReviewScreen({super.key, required this.examId, this.initialExam});

  final int examId;
  final GeneratedExam? initialExam;

  @override
  Widget build(BuildContext context) {
    final examService = context.read<ExamService>();
    return ReviewDetailScreen(
      detailId: examId,
      detailLoader: (detailId) => examService.getExamDetail(
        detailId,
        profileId: initialExam?.profileId,
      ),
      initialDetail: initialExam,
    );
  }
}
