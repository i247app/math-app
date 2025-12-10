import 'package:flutter/material.dart';
import 'package:math_ai_app/core/shared/widget/custom_assessment_text.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/bottom_navigation_bar/view/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/suggestion_and_buttons.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/error_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.error != null) {
          return ErrorScreen(
            errorMessage: quizProvider.error!,
            onRetry: () {
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

        return Scaffold(
          backgroundColor: Colors.blue.shade50,
          body: Stack(
            children: [
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: Column(children: [
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

                        Container(
                          width: double.infinity,
                          height: 203,
                          decoration: BoxDecoration(
                            color: Color(0xFFF4714F),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF4714F,
                                ).withAlpha((255 * 0.3).toInt()),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomAssessmentText(text: result.aiReview),
                        SizedBox(height: 30),
                        const SuggestionAndButtons(),
                        SizedBox(height: 30),
                        CustomPrimaryButton(
                          circularNumber: 28,
                          text: 'Home Page',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    BottomNavigationBarScreen(initialIndex: 3),
                              ),
                            );
                          },
                        ),
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
