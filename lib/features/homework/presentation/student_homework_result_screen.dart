import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_close_button.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_header.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_summary.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_review_card.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_score_ring.dart';

class StudentHomeworkResultScreen extends StatelessWidget {
  const StudentHomeworkResultScreen({super.key, required this.summary});

  final StudentHomeworkResultSummary summary;

  static const _designWidth = 390.0;
  static const _designHeight = 800.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale = math.min(
                width / _designWidth,
                height / _designHeight,
              );
              double s(double value) => value * scale;

              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: StudentHomeworkResultHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: s(111),
                        child: StudentHomeworkScoreRing(
                          scale: scale,
                          scoreText: summary.scoreText,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: s(285),
                        child: Text(
                          context.getText(AppKeys.excellentResultTitle),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.andika(
                            color: AppColors.textPrimary,
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w800,
                            height: 32 / 24,
                            letterSpacing: -0.4 * scale,
                          ),
                        ),
                      ),
                      Positioned(
                        left: s(26),
                        right: s(26),
                        top: s(369),
                        child: StudentHomeworkReviewCard(
                          scale: scale,
                          reviewText: summary.reviewText,
                        ),
                      ),
                      Positioned(
                        left: s(26),
                        right: s(26),
                        top: s(592),
                        child: StudentHomeworkCloseButton(scale: scale),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
