import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_helpers.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_style.dart';

class StudentHomeworkCloseButton extends StatelessWidget {
  const StudentHomeworkCloseButton({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          onTap: () => closeStudentHomeworkResult(context),
          borderRadius: BorderRadius.circular(20 * scale),
          child: Ink(
            width: 180 * scale,
            height: 57 * scale,
            decoration: BoxDecoration(
              color: homeworkResultHeaderTeal,
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
