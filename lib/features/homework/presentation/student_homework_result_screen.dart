import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';

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
                        child: _HomeworkResultHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: s(111),
                        child: _HomeworkScoreRing(
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
                        child: _HomeworkReviewCard(
                          scale: scale,
                          reviewText: summary.reviewText,
                        ),
                      ),
                      Positioned(
                        left: s(26),
                        right: s(26),
                        top: s(592),
                        child: _HomeworkCloseButton(scale: scale),
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

class StudentHomeworkResultSummary {
  const StudentHomeworkResultSummary({
    required this.scoreText,
    required this.reviewText,
  });

  final String scoreText;
  final String reviewText;
}

class _HomeworkResultHeader extends StatelessWidget {
  const _HomeworkResultHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.only(left: 20 * scale, right: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _HomeworkHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              scale: scale,
              onTap: () => _closeHomeworkResult(context),
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _homeworkResultHeaderTeal,
              fontSize: 25 * scale,
              fontWeight: FontWeight.w800,
              height: 34 / 25,
              letterSpacing: -0.2 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkHeaderIconButton extends StatelessWidget {
  const _HomeworkHeaderIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 40 * scale,
          height: 40 * scale,
          child: Icon(icon, color: _homeworkResultHeaderTeal, size: 23 * scale),
        ),
      ),
    );
  }
}

class _HomeworkScoreRing extends StatelessWidget {
  const _HomeworkScoreRing({required this.scale, required this.scoreText});

  final double scale;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    final scoreTotal = slashIndex == -1
        ? '/10'
        : scoreText.substring(slashIndex);

    return Center(
      child: SizedBox(
        width: 192 * scale,
        height: 168 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0F7).withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6F0F7).withValues(alpha: 0.70),
                      blurRadius: 32 * scale,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 150 * scale,
              height: 150 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _homeworkResultTeal,
                  width: 9 * scale,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: GoogleFonts.andika(
                            color: _homeworkResultScoreGreen,
                            fontSize: 48 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: GoogleFonts.andika(
                            color: Colors.black,
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: GoogleFonts.andika(
                      color: _homeworkResultMuted,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkReviewCard extends StatelessWidget {
  const _HomeworkReviewCard({required this.scale, required this.reviewText});

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 161 * scale,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _homeworkResultCardBorder),
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: _homeworkResultInk.withValues(alpha: 0.05),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45 * scale,
            top: -45 * scale,
            child: Container(
              width: 96 * scale,
              height: 96 * scale,
              decoration: const BoxDecoration(
                color: _homeworkResultAiAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56 * scale,
                height: 56 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _homeworkResultMascotBorder,
                    width: 2 * scale,
                  ),
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.18,
                    child: Image.asset(
                      'assets/images/onboarding_splash_mascot.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.getText(AppKeys.numiAiReview),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.andika(
                                color: _homeworkResultInk,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w800,
                                height: 20 / 14,
                                letterSpacing: -0.1 * scale,
                              ),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: _homeworkResultTeal,
                            size: 15 * scale,
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        '"$reviewText"',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _homeworkResultMuted,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w400,
                          height: 19.5 / 12,
                          letterSpacing: -0.1 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeworkCloseButton extends StatelessWidget {
  const _HomeworkCloseButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          onTap: () => _closeHomeworkResult(context),
          borderRadius: BorderRadius.circular(20 * scale),
          child: Ink(
            width: 180 * scale,
            height: 57 * scale,
            decoration: BoxDecoration(
              color: _homeworkResultHeaderTeal,
              borderRadius: BorderRadius.circular(20 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 2 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Center(
              child: Text(
                context.getText(AppKeys.close),
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  height: 28 / 18,
                  letterSpacing: -0.2 * scale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

StudentHomeworkResultSummary studentHomeworkResultSummary({
  required ClassroomExerciseSubmissionResponse submission,
}) {
  final grading = submission.grading;
  return StudentHomeworkResultSummary(
    scoreText: _homeworkScoreText(grading),
    reviewText: _homeworkReviewText(grading),
  );
}

String _homeworkScoreText(ClassroomExerciseSubmissionGrading? grading) {
  final scorePercentage = grading?.scorePercentage;
  if (scorePercentage != null) {
    final scoreOutOf10 = (scorePercentage / 10).round().clamp(0, 10);
    return '$scoreOutOf10/10';
  }

  final correctNumber = grading?.correctNumber;
  final totalQuestions = grading?.totalQuestions;
  if (correctNumber != null && totalQuestions != null && totalQuestions > 0) {
    final scoreOutOf10 = (correctNumber / totalQuestions * 10).round();
    return '${scoreOutOf10.clamp(0, 10)}/10';
  }

  return '--/10';
}

String _homeworkReviewText(ClassroomExerciseSubmissionGrading? grading) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}

void _closeHomeworkResult(BuildContext context) {
  HapticFeedback.mediumImpact();
  Navigator.of(context).pop(true);
}
