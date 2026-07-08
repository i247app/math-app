part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkClassSummary extends StatelessWidget {
  const _CreateHomeworkClassSummary({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 15, 25, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 108,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.teal520),
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
                        _createHomeworkStudentCount(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: AppColors.navy900,
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
                        _createHomeworkClassSummaryName(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: AppColors.textInkDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 32 / 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_grade.png',
                        label: _createHomeworkGradeName(
                          context,
                          classroom,
                          grades,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_program.png',
                        label: _createHomeworkProgramName(
                          context,
                          classroom,
                          programs,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset:
                            'assets/images/teacher_class_description.png',
                        label: _createHomeworkSchoolName(
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
