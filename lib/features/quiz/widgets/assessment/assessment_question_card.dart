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
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: _fontSizeFor(question),
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _fontSizeFor(String value) {
    final length = value.trim().length;
    if (length <= 18) return 52;
    if (length <= 45) return 40;
    if (length <= 90) return 30;
    if (length <= 160) return 24;
    return 20;
  }
}
