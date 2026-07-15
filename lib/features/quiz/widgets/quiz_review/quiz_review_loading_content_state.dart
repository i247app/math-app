import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_loading_content.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_loading_section.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_skeleton_block.dart';

class QuizReviewLoadingContentState extends State<QuizReviewLoadingContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizReviewSkeletonBlock(
                progress: progress,
                height: 44,
                borderRadius: 12,
              ),
              const SizedBox(height: 12),
              QuizReviewSkeletonBlock(
                progress: progress,
                height: 94,
                borderRadius: 14,
              ),
              const SizedBox(height: 24),
              QuizReviewQuestionLoadingSection(progress: progress),
            ],
          ),
        );
      },
    );
  }
}
