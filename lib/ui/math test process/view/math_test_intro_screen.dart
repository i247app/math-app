import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/math test process/widget/board_and_bee_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/view/math_quizz_screen.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';

class MathTestIntroScreen extends StatelessWidget {
  const MathTestIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            children: [
              HeaderSection(),
              const SizedBox(height: 30),
              Text(
                "Hãy cùng AI chinh phục\nbài kiểm tra Toán đầu\nvào nào!",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1C),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 30),
              const Expanded(child: BoardAndBeeSection()),
              CustomPrimaryButton(
                text: "Bắt Đầu Làm Bài",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MathQuizScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
  