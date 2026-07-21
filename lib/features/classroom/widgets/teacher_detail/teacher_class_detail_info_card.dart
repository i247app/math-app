import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_code_chip.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_meta_row.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';

class TeacherClassDetailInfoCard extends StatelessWidget {
  const TeacherClassDetailInfoCard({
    super.key,
    required this.classroom,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggleExpanded,
  });
  final ClassroomModel? classroom;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final title =
        nonEmpty(classroom?.name) ??
        context.getText(AppKeys.teacherClassFallback);
    final grade = classroomGradeLabel(context, classroom, grades);
    final program =
        classroomProgramLabel(context, classroom, programs) ??
        context.getText(AppKeys.teacherProgramFallback);
    final schoolName = classroomSchoolLabel(context, classroom, schools);
    final code = classCode(classroom);
    final joinLink = 'numinumi.vn/join/$code';

    final radius = BorderRadius.circular(24);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading || isExpanded ? null : onToggleExpanded,
        borderRadius: radius,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius,
              border: Border.all(color: const Color(0x80CCCCCC)),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: isLoading
                ? const SizedBox(
                    height: 164,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.teal520,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 67,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 71,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/images/teacher_class_graduation.svg',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: SizedBox(
                                  height: 64,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textInkDark,
                                            fontSize: FontSize.xl,
                                            fontWeight: FontWeight.w700,
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => copyClassroomInfo(
                                          context,
                                          joinLink,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset(
                                            'assets/images/teacher_class_share.png',
                                            width: 23,
                                            height: 23,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            alignment: const AlignmentDirectional(-1, -1),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: isExpanded
                            ? Column(
                                key: const ValueKey('class-meta-expanded'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      height: 74,
                                      child: Column(
                                        spacing: 5,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TeacherClassDetailMetaRow(
                                            iconAsset:
                                                'assets/images/teacher_class_grade.png',
                                            text: grade,
                                          ),
                                          TeacherClassDetailMetaRow(
                                            iconAsset:
                                                'assets/images/teacher_class_program.png',
                                            text: program,
                                          ),
                                          TeacherClassDetailMetaRow(
                                            iconAsset:
                                                'assets/images/teacher_class_description.png',
                                            text: schoolName,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                key: ValueKey('class-meta-collapsed'),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: SizedBox(
                          height: 27,
                          child: Row(
                            children: [
                              TeacherClassDetailCodeChip(
                                code: code,
                                onCopy: () => copyClassroomInfo(context, code),
                              ),
                              const Spacer(),
                              Image.asset(
                                'assets/images/teacher_class_qr.png',
                                width: 18,
                                height: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 21),
                          decoration: BoxDecoration(
                            color: AppColors.teacherMint,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEFF6FF)),
                          ),
                          child: Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: Text(
                                  joinLink,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A5F),
                                    fontSize: FontSize.small,
                                    fontWeight: FontWeight.w400,
                                    height: 1.7,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    copyClassroomInfo(context, joinLink),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: SvgPicture.asset(
                                    'assets/images/teacher_class_copy.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 4),
                          child: Center(
                            child: InkWell(
                              onTap: onToggleExpanded,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                child: Text(
                                  context.getText(AppKeys.teacherClassHideLess),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textCoolMuted,
                                    fontSize: FontSize.xs,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
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
