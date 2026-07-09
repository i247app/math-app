part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassDetailInfoCard extends StatelessWidget {
  const _TeacherClassDetailInfoCard({
    required this.scale,
    required this.classroom,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final double scale;
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
        _nonEmpty(classroom?.name) ??
        context.getText(AppKeys.teacherClassFallback);
    final grade = _classroomGradeLabel(context, classroom, grades);
    final program =
        _classroomProgramLabel(context, classroom, programs) ??
        context.getText(AppKeys.teacherProgramFallback);
    final schoolName = _classroomSchoolLabel(context, classroom, schools);
    final code = _classCode(classroom);
    final joinLink = 'numinumi.vn/join/$code';

    final radius = BorderRadius.circular(24 * scale);

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
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              15 * scale,
              16 * scale,
              8 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius,
              border: Border.all(color: const Color(0x80CCCCCC)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0D000000),
                  blurRadius: 10 * scale,
                  offset: Offset(3 * scale, 3 * scale),
                ),
              ],
            ),
            child: isLoading
                ? SizedBox(
                    height: 164 * scale,
                    child: const Center(
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
                        height: 67 * scale,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 71 * scale,
                              height: 64 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/images/teacher_class_graduation.svg',
                                width: 40 * scale,
                                height: 40 * scale,
                              ),
                            ),
                            SizedBox(width: 15 * scale),
                            Expanded(
                              child: SizedBox(
                                height: 64 * scale,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.andika(
                                          color: AppColors.textInkDark,
                                          fontSize: 20 * scale,
                                          fontWeight: FontWeight.w700,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _copyClassroomInfo(context, joinLink),
                                      borderRadius: BorderRadius.circular(
                                        8 * scale,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(4 * scale),
                                        child: Image.asset(
                                          'assets/images/teacher_class_share.png',
                                          width: 23 * scale,
                                          height: 23 * scale,
                                        ),
                                      ),
                                    ),
                                  ],
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
                            axisAlignment: -1.0,
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
                                  SizedBox(height: 12 * scale),
                                  SizedBox(
                                    height: 74 * scale,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _TeacherClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_grade.png',
                                          text: grade,
                                        ),
                                        SizedBox(height: 5 * scale),
                                        _TeacherClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_program.png',
                                          text: program,
                                        ),
                                        SizedBox(height: 5 * scale),
                                        _TeacherClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_description.png',
                                          text: schoolName,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                key: ValueKey('class-meta-collapsed'),
                              ),
                      ),
                      SizedBox(height: 14 * scale),
                      SizedBox(
                        height: 27 * scale,
                        child: Row(
                          children: [
                            _TeacherClassDetailCodeChip(
                              scale: scale,
                              code: code,
                              onCopy: () => _copyClassroomInfo(context, code),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/images/teacher_class_qr.png',
                              width: 18 * scale,
                              height: 18 * scale,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 11 * scale),
                      Container(
                        height: 38 * scale,
                        padding: EdgeInsets.symmetric(horizontal: 21 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.teacherMint,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: const Color(0xFFEFF6FF)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                joinLink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: const Color(0xFF1E3A5F),
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w400,
                                  height: 1.7,
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            InkWell(
                              onTap: () =>
                                  _copyClassroomInfo(context, joinLink),
                              borderRadius: BorderRadius.circular(8 * scale),
                              child: Padding(
                                padding: EdgeInsets.all(2 * scale),
                                child: SvgPicture.asset(
                                  'assets/images/teacher_class_copy.svg',
                                  width: 20 * scale,
                                  height: 20 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[
                        SizedBox(height: 16 * scale),
                        Center(
                          child: InkWell(
                            onTap: onToggleExpanded,
                            borderRadius: BorderRadius.circular(10 * scale),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 5 * scale,
                              ),
                              child: Text(
                                context.getText(AppKeys.teacherClassHideLess),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: AppColors.textCoolMuted,
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
