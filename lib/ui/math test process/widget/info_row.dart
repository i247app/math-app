import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoRow extends StatelessWidget {
  final int remainingTime;
  final int currentQuestion;
  final int totalQuestions;

  const InfoRow({
    super.key,
    required this.remainingTime,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/imgs/alarm_clock.png',
              width: 28,
              height: 28,
              errorBuilder: (c, o, s) => const Icon(
                Icons.access_time_filled,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Câu $currentQuestion/$totalQuestions",
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
