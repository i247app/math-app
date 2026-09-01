import 'package:flutter/material.dart';

class QuizReviewSkeletonBlock extends StatelessWidget {
  const QuizReviewSkeletonBlock({
    super.key,
    required this.progress,
    required this.height,
    required this.borderRadius,
  });

  final double progress;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final highlightPosition = -1.4 + progress * 2.8;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(highlightPosition - 1, 0),
          end: Alignment(highlightPosition + 1, 0),
          colors: const [
            Color(0xFFE5F3F5),
            Color(0xFFF8FEFF),
            Color(0xFFE5F3F5),
          ],
          stops: const [0.22, 0.5, 0.78],
        ).createShader(bounds);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F3F5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
