import 'package:flutter/material.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentEmptyPoster extends StatelessWidget {
  const ParentAssessmentEmptyPoster({
    super.key,
    required this.onTap,
    this.onSecondaryTap,
  });

  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final assessmentBanner = _AssessmentEmptyBanner(
      assetPath: homeInitialAssessmentBannerAsset,
      aspectRatio: 1280 / 852,
      onTap: onTap,
    );
    final practiceBanner = _AssessmentEmptyBanner(
      assetPath: parentHomeAfterReviewBannerAsset,
      aspectRatio: 1280 / 854,
      onTap: onSecondaryTap,
    );

    return Column(spacing: 12, children: [assessmentBanner, practiceBanner]);
  }
}

class _AssessmentEmptyBanner extends StatelessWidget {
  const _AssessmentEmptyBanner({
    required this.assetPath,
    required this.aspectRatio,
    this.onTap,
  });

  final String assetPath;
  final double aspectRatio;
  final VoidCallback? onTap;

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
            aspectRatio: aspectRatio,
            child: Image.asset(
              assetPath,
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
