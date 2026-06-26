part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherTopBar extends StatelessWidget {
  const _TeacherTopBar({
    required this.profile,
    required this.topPadding,
    required this.scale,
  });

  final StudentProfile? profile;
  final double topPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final name = _displayTeacherName(profile);
    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topPadding + 16 * scale,
        18 * scale,
        14 * scale,
      ),
      decoration: const BoxDecoration(color: _teacherMint),
      child: Row(
        children: [
          _TeacherAvatar(profile: profile, size: 48 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.teacherWelcomeBack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherBlue.withValues(alpha: 0.60),
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                  ),
                ),
                Text(
                  '$name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherBlue,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4DC4C6D2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: _teacherBlue,
              size: 22 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
