import 'package:flutter/material.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/math%20test%20process/widget/header_section.dart';
import 'package:math_ai_app/ui/bottom_navigation_bar/widget/bar_chart_widget.dart';

import '../../math test process/view/math_quizz_screen.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            children: [
              HeaderSection(),
              SizedBox(height: 120),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F6F4),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFD9F6F4,
                      ).withAlpha((255 * 0.3).toInt()),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const BarChartWidget(),
              ),

              Spacer(),
              CustomPrimaryButton(
                text: 'Test',
                height: 56,
                width: 150,
                circularNumber: 28,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MathQuizScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
