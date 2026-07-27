import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_small_coral_add_button.dart';
import 'package:numi/shared/widgets/app_section_header.dart';

class TeacherClassSectionHeader extends StatelessWidget {
  const TeacherClassSectionHeader({
    super.key,
    required this.showAddButton,
    required this.onAdd,
    this.onViewAll,
  });
  final bool showAddButton;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: context.getText(AppKeys.teacherYourClasses),
      actionLabel: context.getText(AppKeys.viewAll),
      actionIcon: Icons.chevron_right_rounded,
      onAction: onViewAll,
      useHaptic: false,
      titleStyle: TextStyle(
        color: context.themeColors.textPrimary,
        fontSize: FontSize.xl,
        fontWeight: FontWeight.w600,
      ),
      actionStyle: TextStyle(
        color: context.themeColors.info,
        fontSize: FontSize.caption,
        fontWeight: FontWeight.w800,
      ),
      bottom: showAddButton ? TeacherSmallCoralAddButton(onTap: onAdd) : null,
      bottomSpacing: 8,
    );
  }
}
