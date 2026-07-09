import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentEmptyPoster extends StatelessWidget {
  const ParentAssessmentEmptyPoster({
    required this.onTap,
    required this.scale,
  });

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24 * scale);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
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
                        HomeSkeletonBlock(radius: 24 * scale, color: color),
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