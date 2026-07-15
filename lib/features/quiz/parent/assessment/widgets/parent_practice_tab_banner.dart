import 'package:flutter/material.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/features/quiz/parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';

class ParentPracticeTabBanner extends StatelessWidget {
  const ParentPracticeTabBanner({
    super.key,
    required this.onTap,
    required this.scale,
  });

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10 * scale);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3.21,
          child: Image.asset(
            'assets/images/review_tab_banner.jpg',
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              if (frame == null) {
                return ParentAssessmentSkeletonPulse(
                  builder: (context, color) =>
                      AppSkeletonBlock(radius: 10 * scale, color: color),
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
    );
  }
}
