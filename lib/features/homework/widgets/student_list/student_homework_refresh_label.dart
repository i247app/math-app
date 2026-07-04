import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_style.dart';

class StudentHomeworkRefreshLabel extends StatelessWidget {
  const StudentHomeworkRefreshLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        context.getText(AppKeys.loading),
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: studentHomeworkMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
