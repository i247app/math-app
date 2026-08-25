import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class AssessmentProgressSection extends StatelessWidget {
  const AssessmentProgressSection({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredQuestionIndexes,
  });
  final int currentQuestion;
  final int totalQuestions;
  final Set<int> answeredQuestionIndexes;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.formatText(AppKeys.questionProgress, {
            'current': currentQuestion,
            'total': totalQuestions,
          }),
          style: TextStyle(
            color: colors.brandStrong,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: totalQuestions,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final answered = answeredQuestionIndexes.contains(index);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: answered ? colors.brandStrong : colors.elevatedSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.brandStrong, width: 2),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: answered ? colors.onBrand : colors.brandStrong,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1,
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
