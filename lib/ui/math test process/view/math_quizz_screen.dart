import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_result_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/custom_progress_bar.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/info_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/question_board.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/answer_section.dart';

class MathQuizScreen extends StatelessWidget {
  const MathQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/imgs/grass_background.png',
              fit: BoxFit.cover,
              height: 180,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.green.withAlpha((255 * 0.3).toInt()),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  HeaderSection(),
                  const SizedBox(height: 10),
                  Text(
                    "Kiểm Tra",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3E2723),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const CustomProgressBar(),

                  const SizedBox(height: 20),

                  const InfoRow(),

                  const SizedBox(height: 10),

                  const QuestionBoard(),

                  const SizedBox(height: 20),

                  const Expanded(child: AnswerSection()),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: -10,
            child: Image.asset(
              'assets/imgs/bee12.png',
              height: 160,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.bug_report, size: 100, color: Colors.yellow),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPrimaryButton(
                text: 'Nộp',
                width: 160,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ResultScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
