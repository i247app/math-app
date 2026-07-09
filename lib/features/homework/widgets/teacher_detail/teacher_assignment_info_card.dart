part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAssignmentInfoCard extends StatelessWidget {
  const _TeacherAssignmentInfoCard({
    required this.exercise,
    required this.visibility,
    required this.onVisibilityChanged,
  });

  final ClassroomExercise? exercise;
  final String? visibility;
  final ValueChanged<String> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/teacher_homework_detail_class.svg',
                    width: 17,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      teacherExerciseClassLabel(context, exercise),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 24 / 14,
                      ),
                    ),
                  ),
                  _TeacherAssignmentSwitch(
                    visibility: visibility,
                    onChanged: onVisibilityChanged,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                teacherExerciseTitle(context, exercise),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 36 / 18,
                ),
              ),
              if (_exerciseInfoRows(context, exercise).isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final row in _exerciseInfoRows(context, exercise))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _TeacherAssignmentInfoRow(row),
                  ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 19),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TeacherAssignmentStatDue(exercise)),
                    const SizedBox(width: 30),
                    Expanded(child: _TeacherAssignmentStatQuestions(exercise)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
