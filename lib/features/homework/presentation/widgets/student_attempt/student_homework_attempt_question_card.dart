import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentHomeworkAttemptQuestionCard extends StatelessWidget {
  const StudentHomeworkAttemptQuestionCard({super.key, required this.question});
  final String question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: FontSize.displayLarge,
          fontWeight: FontWeight.w900,
          height: 1.16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
