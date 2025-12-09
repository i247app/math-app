import 'package:flutter/material.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/quiz_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';

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
          // child: SizedBox(
          //   height: 56,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (_) => const BottomNavigationBarScreen(),
          //         ),
          //       );
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF3E2723),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: Text(
          //       "Trang Chủ",
          //       style: GoogleFonts.nunito(
          //         fontSize: 18,
          //         fontWeight: FontWeight.w700,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomPrimaryButton(
            text: 'Practice',
            circularNumber: 28,
            height: 56,
            onPressed: () async {
              // Call generatePractice API first
              final userProvider = context.read<UserProvider>();
              final quizProvider = context.read<QuizProvider>();
              final uid = userProvider.user?.id;

              if (uid != null && uid.isNotEmpty) {
                try {
                  await quizProvider.generatePractice(uid);
                  // Navigate to MathQuizScreen after API call
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MathQuizScreen()),
                    );
                  }
                } catch (e) {
                  // Handle error if needed
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to generate practice quiz: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
          // child: SizedBox(
          //   height: 56,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (_) =>
          //               const BottomNavigationBarScreen(initialIndex: 1),
          //         ),
          //       );
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF3E2723),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: Text(
          //       "Tiếp tục",
          //       style: GoogleFonts.nunito(
          //         fontSize: 18,
          //         fontWeight: FontWeight.w700,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }

  // Widget _buildBulletPoint(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 4.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "• ",
  //           style: GoogleFonts.nunito(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: GoogleFonts.nunito(fontSize: 18, height: 1.3),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
