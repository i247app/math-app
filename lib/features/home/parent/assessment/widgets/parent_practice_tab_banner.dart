import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';

class ParentPracticeTabBanner extends StatelessWidget {
  const ParentPracticeTabBanner({required this.onTap, required this.scale});

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
                      HomeSkeletonBlock(radius: 10 * scale, color: color),
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