import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_style.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_message_button.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_teacher_avatar.dart';

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
    final teacherName = studentClassNonEmpty(classroom?.teacherName) ??
        studentClassNonEmpty(classroom?.owner?.name) ??
        context.getText(AppKeys.teacherFallback);
    final teacherAvatarUrl = studentClassTeacherAvatarUrl(classroom);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001741).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 56,
              child: Center(
                child: CircularProgressIndicator(color: studentClassTeal),
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
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.getText(AppKeys.studentClassTeacherRole),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: studentClassMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: studentClassInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StudentClassMessageButton(
                  onTap: () => showStudentClassComingSoon(context),
                ),
              ],
            ),
    );
  }
}
