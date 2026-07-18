import 'package:flutter/material.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentEmptyPoster extends StatelessWidget {
  const ParentAssessmentEmptyPoster({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.asset(
              parentReviewEmptyAssessmentAsset,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                if (frame == null) {
                  return ParentAssessmentSkeletonPulse(
                    builder: (context, color) =>
                        AppSkeletonBlock(radius: 24, color: color),
                  );
                }
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: homeFadeInDuration,
                  curve: Curves.easeOut,
                  builder: (context, value, animatedChild) =>
                      Opacity(opacity: value, child: animatedChild),
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
