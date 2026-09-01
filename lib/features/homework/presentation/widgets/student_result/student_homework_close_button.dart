import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/presentation/widgets/student_result/student_homework_result_helpers.dart';
import 'package:numi/core/theme/app_colors.dart';

class StudentHomeworkCloseButton extends StatelessWidget {
  const StudentHomeworkCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => closeStudentHomeworkResult(context),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            width: 180,
            height: 57,
            decoration: BoxDecoration(
              color: AppColors.teal500,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                context.getText(AppKeys.close),
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w800,
                  height: 28 / 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
