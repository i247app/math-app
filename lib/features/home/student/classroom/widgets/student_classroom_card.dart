part of '../../../home_screen.dart';

class _StudentClassroomCard extends StatelessWidget {
  const _StudentClassroomCard({
    required this.scale,
    required this.classroom,
  });

  final double scale;
  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final description = classroom.description?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Icon(
              Icons.school_rounded,
              color: _teal,
              size: 27 * scale,
            ),
          ),
          SizedBox(width: 15 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description != null && description.isNotEmpty
                      ? description
                      : context.formatText(
                          AppKeys.teacherStudentCount,
                          {'count': classroom.displayStudentCount},
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Icon(
            Icons.chevron_right_rounded,
            color: _teal,
            size: 26 * scale,
          ),
        ],
      ),
    );
  }
}
