part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherRecentAssignmentCard extends StatelessWidget {
  const _TeacherRecentAssignmentCard({
    required this.scale,
    required this.assignment,
    required this.onTap,
  });

  final double scale;
  final ClassroomExercise assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateParts = _teacherExerciseDateParts(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    final timeLabel = _teacherExerciseDateTimeLabel(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(18 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58 * scale,
                  height: 42 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateParts.day,
                        style: GoogleFonts.andika(
                          color: _teacherBlue,
                          fontSize: FontSize.large * scale,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      Text(
                        dateParts.month,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: FontSize.caption * 0.7 * scale,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _teacherExerciseTitle(context, assignment),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  timeLabel ??
                      _teacherExerciseQuestionCount(context, assignment),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherMuted,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
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
