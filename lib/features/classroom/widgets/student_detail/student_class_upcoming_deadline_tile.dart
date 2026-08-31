import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class StudentClassUpcomingDeadlineTile extends StatelessWidget {
  const StudentClassUpcomingDeadlineTile({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 72,
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.magenta,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentClassHomeworkTitle(exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        studentClassHomeworkDueDate(context, exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontSize.xxs,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 28),
                child: SvgPicture.asset(
                  'assets/icons/student-class-chevron.svg',
                  width: 7,
                  height: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
