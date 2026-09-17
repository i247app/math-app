import 'package:flutter/material.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentTabBanner extends StatelessWidget {
  const ParentAssessmentTabBanner({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: AspectRatio(
          aspectRatio: 1280 / 497,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/assessment-tab-banner.jpg',
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  if (frame == null) {
                    return ParentAssessmentSkeletonPulse(
                      builder: (context, color) =>
                          AppSkeletonBlock(radius: 10, color: color),
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
              if (isLoading)
                const ColoredBox(
                  color: Color(0x52000000),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
