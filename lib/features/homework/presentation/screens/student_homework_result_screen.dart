import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_close_button.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_result_header.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_result_summary.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_review_card.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_score_ring.dart';

class StudentHomeworkResultScreen extends StatelessWidget {
  const StudentHomeworkResultScreen({super.key, required this.summary});

  final StudentHomeworkResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StudentHomeworkResultHeader(),
                    Padding(
                      padding: const EdgeInsets.only(top: 51),
                      child: StudentHomeworkScoreRing(
                        scoreText: summary.scoreText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        context.getText(AppKeys.excellentResultTitle),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.andika(
                          color: colors.textPrimary,
                          fontSize: FontSize.xxxl,
                          fontWeight: FontWeight.w800,
                          height: 32 / 24,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 52, 26, 0),
                      child: StudentHomeworkReviewCard(
                        reviewText: summary.reviewText,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(26, 62, 26, 24),
                      child: StudentHomeworkCloseButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
