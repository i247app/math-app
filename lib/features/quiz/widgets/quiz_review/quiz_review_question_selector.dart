import 'package:flutter/material.dart';

import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_centered_text.dart';

class QuizReviewQuestionSelector extends StatelessWidget {
  const QuizReviewQuestionSelector({
    super.key,
    required this.questions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(questions.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(
                right: index == questions.length - 1 ? 0 : 11,
              ),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal600 : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.teal600, width: 1.2),
                  ),
                  child: QuizReviewCenteredText(
                    '${index + 1}',
                    color: selected ? Colors.white : AppColors.teal600,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
