import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_loading_section.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_skeleton.dart';

class QuizReviewQuestionLoadingSectionState
    extends State<QuizReviewQuestionLoadingSection>
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
      return QuizReviewQuestionSkeleton(progress: widget.progress ?? 0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return QuizReviewQuestionSkeleton(progress: controller.value);
      },
    );
  }
}
