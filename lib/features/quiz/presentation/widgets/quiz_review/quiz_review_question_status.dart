import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class QuizReviewQuestionStatus extends StatelessWidget {
  const QuizReviewQuestionStatus({super.key, required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.teal600 : AppColors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(
          isCorrect ? Icons.verified_outlined : Icons.error_outline_rounded,
          color: color,
          size: 17,
        ),
        Text(
          context
              .getText(
                isCorrect ? AppKeys.correctStatus : AppKeys.incorrectStatus,
              )
              .toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: FontSize.xxs,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
