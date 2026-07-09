import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class AssessmentProgressSection extends StatelessWidget {
  const AssessmentProgressSection({
    super.key,
    required this.scale,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  final double scale;
  final int currentQuestion;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final progress = totalQuestions == 0
        ? 0.0
        : currentQuestion / totalQuestions;
    final progressValue = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.formatText(AppKeys.questionProgress, {
            'current': currentQuestion,
            'total': totalQuestions,
          }),
          style: TextStyle(
            color: AppColors.textSubtle,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w900,
            height: 1.5,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: 16 * scale,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = 4 * scale;
              final trackWidth = constraints.maxWidth;
              final fillWidth = math.max(
                0.0,
                (trackWidth - inset * 2) * progressValue,
              );

              return Container(
                padding: EdgeInsets.all(inset),
                decoration: BoxDecoration(
                  color: AppColors.peachStrong,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4 * scale,
                      offset: Offset(0, 2 * scale),
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: fillWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.assessmentProgress,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
