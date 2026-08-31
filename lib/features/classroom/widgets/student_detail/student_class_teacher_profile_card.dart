import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_message_button.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_teacher_avatar.dart';

class StudentClassTeacherProfileCard extends StatelessWidget {
  const StudentClassTeacherProfileCard({
    super.key,
    required this.classroom,
    required this.isLoading,
  });

  final ClassroomModel? classroom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final teacherName =
        studentClassNonEmpty(classroom?.teacherName) ??
        studentClassNonEmpty(classroom?.owner?.name) ??
        context.getText(AppKeys.teacherFallback);
    final teacherAvatarUrl = studentClassTeacherAvatarUrl(classroom);
    final colors = context.themeColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? SizedBox(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(color: colors.brandStrong),
              ),
            )
          : Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    StudentClassTeacherAvatar(
                      name: teacherName,
                      imageUrl: teacherAvatarUrl,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getText(AppKeys.studentClassTeacherRole),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: FontSize.xxxs,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          teacherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StudentClassMessageButton(
                  onTap: () => showStudentClassComingSoon(context),
                ),
              ],
            ),
    );
  }
}
