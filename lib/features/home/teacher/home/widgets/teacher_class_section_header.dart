import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';

class TeacherClassSectionHeader extends StatelessWidget {
  const TeacherClassSectionHeader({
    super.key,
    required this.scale,
    required this.hasClasses,
    required this.onAdd,
    this.onViewAll,
  });

  final double scale;
  final bool hasClasses;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.getText(AppKeys.teacherYourClasses),
                style: GoogleFonts.andika(
                  color: Colors.black,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                context.getText(AppKeys.viewAllUpper),
                style: GoogleFonts.andika(
                  color: AppColors.textInkDark,
                  fontSize: FontSize.small * scale,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        if (hasClasses) ...[
          SizedBox(height: 8 * scale),
          TeacherSmallCoralAddButton(scale: scale, onTap: onAdd),
        ],
      ],
    );
  }
}
