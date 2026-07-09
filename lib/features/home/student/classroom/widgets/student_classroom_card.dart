import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';

class StudentClassroomCard extends StatelessWidget {
  const StudentClassroomCard({
    super.key,
    required this.scale,
    required this.classroom,
  });

  final double scale;
  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final description = classroom.description?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              color: homeTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Icon(
              Icons.school_rounded,
              color: homeTeal,
              size: 27 * scale,
            ),
          ),
          SizedBox(width: 15 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: homeDeepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description != null && description.isNotEmpty
                      ? description
                      : context.formatText(AppKeys.teacherStudentCount, {
                          'count': classroom.displayStudentCount,
                        }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Icon(Icons.chevron_right_rounded, color: homeTeal, size: 26 * scale),
        ],
      ),
    );
  }
}
