import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AssessmentQuestionCard extends StatelessWidget {
  const AssessmentQuestionCard({super.key, required this.question});
  final String question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 356,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
