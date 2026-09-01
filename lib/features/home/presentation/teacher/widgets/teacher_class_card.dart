import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/classroom/application/read_models/classroom_display_read_model.dart';
import 'package:numi/features/home/presentation/teacher/widgets/shared/class_thumb.dart';
import 'package:numi/features/classroom/application/read_models/teacher_member_summary_read_model.dart';

class TeacherClassCard extends StatelessWidget {
  const TeacherClassCard({
    super.key,
    required this.classroom,
    required this.onTap,
  });
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = classroomDisplayName(context, classroom);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A002B6A),
            blurRadius: 20,
            spreadRadius: -4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ClassThumb(classroom: classroom),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: Colors.black,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Divider(color: Color(0x1AC4C6D2), height: 4),
                ),
                Flexible(
                  child: Text(
                    teacherMemberSummaryText(
                      context,
                      members: classroom.displayStudentCount,
                      requests: classroom.displayPendingRequestCount,
                    ),
                    maxLines: classroom.displayPendingRequestCount > 0 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: AppColors.navy900.withValues(alpha: 0.60),
                      fontSize: FontSize.xxxs,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    height: 16,
                    width: 69,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.teal450,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      context.getText(AppKeys.teacherEnterClass),
                      maxLines: 1,
                      style: GoogleFonts.andika(
                        color: Colors.white,
                        fontSize: FontSize.xxxs,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
