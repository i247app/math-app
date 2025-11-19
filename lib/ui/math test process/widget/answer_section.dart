import 'package:flutter/material.dart';
import 'answer_button.dart';

class AnswerSection extends StatelessWidget {
  const AnswerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnswerButton(
                label: "A",
                value: "7",
                color: Colors.lightBlue.shade400,
                labelColor: Colors.red,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: AnswerButton(
                label: "B",
                value: "5",
                color: Colors.pinkAccent.shade100,
                labelColor: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnswerButton(
                label: "C",
                value: "6",
                color: Colors.amber,
                labelColor: Colors.red,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: AnswerButton(
                label: "D",
                value: "8",
                color: Colors.lightGreen,
                labelColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
