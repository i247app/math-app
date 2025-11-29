import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/stats_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/level_chart_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/suggestion_and_buttons.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final result = quizProvider.result;
        if (result == null) {
          return const Scaffold(
            body: Center(child: Text('No results available')),
          );
        }

        final percentage = result.scorePercentage;
        final message = percentage >= 80
            ? "TỐT LẮM!"
            : percentage >= 60
            ? "KHÁ TỐT!"
            : "CẦN CỐ GẮNG!";
        final completedText =
            "Đã hoàn thành ${result.correctNumber}/${result.totalQuestions} câu!";

        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/imgs/cloud.png',
                  fit: BoxFit.cover,
                  height: 500,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => Container(
                    height: 500,
                    color: Colors.white.withAlpha((255 * 0.5).toInt()),
                  ),
                ),
              ),

              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      message,
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                    Text(
                      completedText,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0277BD),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      width: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/bee13.png',
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.amber,
                              width: 100,
                              height: 100,
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 120,
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Text(
                                "$percentage%",
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/imgs/grass_background.png',
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (c, e, s) =>
                      Container(height: 150, color: Colors.green),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Column(
                      children: [
                        HeaderSection(),
                        const SizedBox(height: 10),
                        const SizedBox(height: 250),
                        StatsRow(
                          correctAnswers: result.correctNumber,
                          totalQuestions: result.totalQuestions,
                          percentage: percentage,
                        ),
                        const SizedBox(height: 15),
                        LevelChartSection(aiReview: result.aiReview),
                        const SuggestionAndButtons(),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: -10,
                child: Image.asset(
                  'assets/imgs/bee15.png',
                  height: 180,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.bug_report, size: 100),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
