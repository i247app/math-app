import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_class_meta.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_helpers.dart';

class CreateHomeworkClassSummary extends StatelessWidget {
  const CreateHomeworkClassSummary({
    super.key,
    required this.classroom,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.isLoading,
  });

  final ClassroomModel? classroom;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 15, 25, 15),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: isLoading
          ? SizedBox(
              height: 108,
              child: Center(
                child: CircularProgressIndicator(color: colors.brandStrong),
              ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 71,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/teacher_class_graduation.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        createHomeworkStudentCount(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.brandStrong,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 29),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        createHomeworkClassSummaryName(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 32 / 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_grade.png',
                        label: createHomeworkGradeName(
                          context,
                          classroom,
                          grades,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_program.png',
                        label: createHomeworkProgramName(
                          context,
                          classroom,
                          programs,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CreateHomeworkClassMeta(
                        iconAsset:
                            'assets/images/teacher_class_description.png',
                        label: createHomeworkSchoolName(
                          context,
                          classroom,
                          schools,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
