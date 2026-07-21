import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/helpers/classroom_display_helpers.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class StudentClassroomCard extends StatelessWidget {
  const StudentClassroomCard({super.key, required this.classroom});
  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final title = classroomDisplayName(context, classroom);
    final description = classroom.description?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: homeTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.school_rounded, color: homeTeal, size: 27),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: homeDeepInk,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    description != null && description.isNotEmpty
                        ? description
                        : context.formatText(AppKeys.teacherStudentCount, {
                            'count': classroom.displayStudentCount,
                          }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grayText,
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: homeTeal, size: 26),
        ],
      ),
    );
  }
}
