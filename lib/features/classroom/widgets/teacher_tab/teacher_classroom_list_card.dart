import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_number_badge.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_number_helpers.dart';

class TeacherClassroomListCard extends StatelessWidget {
  const TeacherClassroomListCard({
    super.key,
    required this.classroom,
    required this.onTap,
  });
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title =
        classroom.name ?? context.getText(AppKeys.teacherClassFallback);
    final code = classroom.classroomCode ?? classroom.id?.toString() ?? '--';
    final memberCount = classroom.displayStudentCount;
    final classNumber = teacherClassroomNumber(classroom);
    final numberPalette = teacherClassroomNumberPalette(classroom);
    final colors = context.themeColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeacherClassroomNumberBadge(
                  number: classNumber,
                  palette: numberPalette,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontSize.xl,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        Text(
                          'ID: $code',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 7,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: colors.textSecondary,
                  size: 17,
                ),
                Flexible(
                  child: Text(
                    context.formatText(AppKeys.teacherStudentCount, {
                      'count': memberCount,
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
