import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/exam_review/exam_review_question_loading_section.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_skeleton.dart';

class ExamReviewQuestionLoadingSectionState
    extends State<ExamReviewQuestionLoadingSection>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return ExamReviewQuestionSkeleton(progress: widget.progress ?? 0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ExamReviewQuestionSkeleton(progress: controller.value);
      },
    );
  }
}
