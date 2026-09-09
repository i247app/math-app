import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';

void historyOpenExamReview(BuildContext context, GeneratedExam exam) {
  final examId = exam.examId ?? exam.id;
  if (examId == null) {
    context.showErrorDialog(context.readText(AppKeys.missingExamId));
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ExamReviewScreen(examId: examId, initialExam: exam),
    ),
  );
}
