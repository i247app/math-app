import 'package:flutter/material.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';

import '../view/math_quizz_screen.dart';

class SuggestionAndButtons extends StatelessWidget {
  const SuggestionAndButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomPrimaryButton(
            text: 'Next Test',
            circularNumber: 28,
            height: 56,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MathQuizScreen()));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomPrimaryButton(
            text: 'Practice',
            circularNumber: 28,
            height: 56,
            onPressed: () {
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MathQuizScreen(isPractice: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
