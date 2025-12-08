import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/stats_row.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/level_chart_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/suggestion_and_buttons.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/error_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Check for error first
        if (quizProvider.error != null) {
          return ErrorScreen(
            errorMessage: quizProvider.error!,
            onRetry: () {
              // Navigate back to quiz screen to retry
              Navigator.of(context).pop();
            },
          );
        }

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
          backgroundColor: Colors.blue.shade50,
          body: Stack(
            children: [
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

                    SizedBox(
                      height: 220,
                      width: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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
                        const SizedBox(height: 120),
                        SizedBox(
                          height: 120,
                          child: Image(
                            image: const AssetImage(
                              'assets/imgs/appriciation.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
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
            ],
          ),
        );
      },
    );
  }
}
