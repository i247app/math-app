import 'dart:ui';

import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_answer_option.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_detail_helpers.dart';

class TeacherQuestionCard extends StatelessWidget {
  const TeacherQuestionCard({
    super.key,
    required this.questionNumber,
    this.question,
  });

  final int questionNumber;
  final ClassroomExerciseQuestion? question;

  @override
  Widget build(BuildContext context) {
    final prompt =
        question?.displayPrompt ??
        context.getText(AppKeys.teacherAssignmentEquationPrompt);
    final answers = question?.answers ?? const <String>[];
    final colors = context.themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(21, 6, 21, 21),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.formatText(AppKeys.teacherAssignmentQuestionNumber, {
                  'number': questionNumber,
                }),
                style: GoogleFonts.andika(
                  color: colors.brandStrong,
                  fontSize: FontSize.compact,
                  fontWeight: FontWeight.w700,
                  height: 24 / 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  prompt,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                    height: 24 / 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  spacing: 8,
                  children: List.generate(
                    answers.length,
                    (index) => TeacherAnswerOption(
                      letter: answerLetter(index),
                      text: answers[index],
                      selected: isCorrectAnswer(
                        question,
                        answers[index],
                        index,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
