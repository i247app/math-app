import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_class_meta.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_helpers.dart';

class CreateClassroomExerciseClassSummary extends StatelessWidget {
  const CreateClassroomExerciseClassSummary({
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
              spacing: 29,
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    spacing: 6,
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
                          'assets/icons/teacher-class-graduation.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Text(
                        createClassroomExerciseStudentCount(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.brandStrong,
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text(
                        createClassroomExerciseClassSummaryName(
                          context,
                          classroom,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textPrimary,
                          fontSize: FontSize.xl,
                          fontWeight: FontWeight.w700,
                          height: 32 / 20,
                        ),
                      ),
                      CreateClassroomExerciseClassMeta(
                        iconAsset: 'assets/icons/teacher-class-grade.png',
                        label: createClassroomExerciseGradeName(
                          context,
                          classroom,
                          grades,
                        ),
                      ),
                      CreateClassroomExerciseClassMeta(
                        iconAsset: 'assets/icons/teacher-class-program.png',
                        label: createClassroomExerciseProgramName(
                          context,
                          classroom,
                          programs,
                        ),
                      ),
                      CreateClassroomExerciseClassMeta(
                        iconAsset: 'assets/icons/teacher-class-description.png',
                        label: createClassroomExerciseSchoolName(
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
