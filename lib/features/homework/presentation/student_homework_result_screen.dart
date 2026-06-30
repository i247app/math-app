import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';

part '../widgets/student_result/student_homework_result_summary.dart';
part '../widgets/student_result/student_homework_result_header.dart';
part '../widgets/student_result/student_homework_result_header_icon_button.dart';
part '../widgets/student_result/student_homework_score_ring.dart';
part '../widgets/student_result/student_homework_review_card.dart';
part '../widgets/student_result/student_homework_close_button.dart';
part '../widgets/student_result/student_homework_result_helpers.dart';

const _homeworkResultTeal = Color(0xFF006762);
const _homeworkResultHeaderTeal = Color(0xFF38898C);
const _homeworkResultScoreGreen = Color(0xFF006D36);
const _homeworkResultInk = Color(0xFF253228);
const _homeworkResultMuted = Color(0xFF515F54);
const _homeworkResultCardBorder = Color(0xFFE5E8EB);
const _homeworkResultAiAccent = Color(0xFFE8FEFF);
const _homeworkResultMascotBorder = Color(0xFF974320);

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
                        child: _StudentHomeworkResultHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: s(111),
                        child: _StudentHomeworkScoreRing(
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
                            color: _homeworkResultInk,
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
                        child: _StudentHomeworkReviewCard(
                          scale: scale,
                          reviewText: summary.reviewText,
                        ),
                      ),
                      Positioned(
                        left: s(26),
                        right: s(26),
                        top: s(592),
                        child: _StudentHomeworkCloseButton(scale: scale),
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
