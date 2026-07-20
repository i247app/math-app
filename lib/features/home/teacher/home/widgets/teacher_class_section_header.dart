import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_small_coral_add_button.dart';
import 'package:numi/shared/widgets/app_section_header.dart';

class TeacherClassSectionHeader extends StatelessWidget {
  const TeacherClassSectionHeader({
    super.key,
    required this.hasClasses,
    required this.onAdd,
    this.onViewAll,
  });
  final bool hasClasses;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: context.getText(AppKeys.teacherYourClasses),
      actionLabel: context.getText(AppKeys.viewAllUpper),
      onAction: onViewAll,
      useHaptic: false,
      titleStyle: GoogleFonts.andika(
        color: Colors.black,
        fontSize: FontSize.large,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
      actionStyle: GoogleFonts.andika(
        color: AppColors.textInkDark,
        fontSize: FontSize.small,
        fontWeight: FontWeight.w800,
        decoration: TextDecoration.underline,
        height: 1.25,
      ),
      bottom: hasClasses ? TeacherSmallCoralAddButton(onTap: onAdd) : null,
      bottomSpacing: 8,
    );
  }
}
