import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int currentQuiz;
  final int totalQuizzes;

  const CustomProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.currentQuiz,
    required this.totalQuizzes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bài $currentQuiz/$totalQuizzes - Câu $currentQuestion/$totalQuestions",
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCA28),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      totalQuestions > 10 ? 10 : totalQuestions,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index < currentQuestion
                              ? Colors.black87
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Image.asset('assets/imgs/bee_icon.png', width: 35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
