import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';

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
    return Container(
      constraints: BoxConstraints(minHeight: 260 * scale),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: const Color(0xFFDCCACA)),
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 36 * scale,
          fontWeight: FontWeight.w900,
          height: 1.16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
