import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_helpers.dart';
import 'package:numi_flutter/features/homework/widgets/student_result/student_homework_result_style.dart';
import 'package:numi_flutter/features/quiz/widgets/shared/quiz_header_icon_button.dart';

class StudentHomeworkResultHeader extends StatelessWidget {
  const StudentHomeworkResultHeader({super.key, required this.scale});

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
            child: QuizHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              color: homeworkResultHeaderTeal,
              scale: scale,
              size: 40,
              iconSize: 23,
              borderRadius: 12,
              onTap: () => closeStudentHomeworkResult(context),
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: homeworkResultHeaderTeal,
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
