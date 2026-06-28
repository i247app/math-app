part of '../../presentation/teacher_classroom_screens.dart';

class _MemberManagementCard extends StatelessWidget {
  const _MemberManagementCard({
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onTap,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 77 * scale),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: 21 * scale,
              vertical: 14 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Image.asset(
                    'assets/images/teacher_class_members.png',
                    width: 28 * scale,
                    height: 28 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.getText(AppKeys.teacherMemberManagement),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF1E3A5F),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.22,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        _teacherMemberSummaryText(
                          context,
                          members: memberCount,
                          requests: requestCount,
                        ),
                        maxLines: requestCount > 0 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/teacher_class_chevron.svg',
                  width: 20 * scale,
                  height: 20 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
