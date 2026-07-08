import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';

class StudentHomeworkAttemptQuestionCard extends StatelessWidget {
  const StudentHomeworkAttemptQuestionCard({
    super.key,
    required this.scale,
    required this.question,
  });

  final double scale;
  final String question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      constraints: BoxConstraints(minHeight: 260 * scale),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 28 * scale,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 36 * scale,
          fontWeight: FontWeight.w900,
          height: 1.16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
