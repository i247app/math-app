import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_header.dart';

class ExamReviewTextScreen extends StatelessWidget {
  const ExamReviewTextScreen({super.key, required this.reviewText});

  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExamReviewHeader(
              title: context.getText(AppKeys.examReviewWeakTopicsTitle),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    reviewText,
                    style: GoogleFonts.andika(
                      fontSize: 16,
                      height: 1.6,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
