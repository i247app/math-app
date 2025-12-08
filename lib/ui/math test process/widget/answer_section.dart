import 'package:flutter/material.dart';
import 'package:math_ai_app/data/responses/quiz/generate_quiz_response.dart';
import 'answer_button.dart';

class AnswerSection extends StatelessWidget {
  final QuizQuestion? question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const AnswerSection({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return const Center(child: Text('No question available'));
    }

    final answers = question!.answers;
    if (answers.isEmpty) {
      return const Center(child: Text('No answers available'));
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnswerButton(
                value: answers[0].content,
                color: Colors.lightBlue.shade400,
                isSelected: selectedAnswer == answers[0].label,
                onTap: () => onAnswerSelected(answers[0].label),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: AnswerButton(
                value: answers[1].content,
                color: Colors.pinkAccent.shade100,
                isSelected: selectedAnswer == answers[1].label,
                onTap: () => onAnswerSelected(answers[1].label),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnswerButton(
                value: answers[2].content,
                color: Colors.amber,
                isSelected: selectedAnswer == answers[2].label,
                onTap: () => onAnswerSelected(answers[2].label),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: AnswerButton(
                value: answers[3].content,
                color: Colors.lightGreen,
                isSelected: selectedAnswer == answers[3].label,
                onTap: () => onAnswerSelected(answers[3].label),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (onPrevious != null)
              ElevatedButton(
                onPressed: onPrevious,
                child: const Text('Previous'),
              )
            else
              const SizedBox.shrink(),
            if (onNext != null)
              ElevatedButton(onPressed: onNext, child: const Text('Next'))
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
