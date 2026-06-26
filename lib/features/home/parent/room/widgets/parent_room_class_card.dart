part of '../../../home_screen.dart';

class _ParentRoomClassCard extends StatelessWidget {
  const _ParentRoomClassCard({
    required this.entry,
    required this.index,
    required this.onTap,
  });

  final _ParentRoomEntry entry;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlue = index.isOdd;
    final childName = homeProfileDisplayName(context, entry.child);
    final className = _roomClassName(context, entry.classroom);
    final teacherName = _roomTeacherName(context, entry);
    final fg = isBlue ? const Color(0xFF006CB6) : const Color(0xFF276C6B);
    final bg = isBlue ? const Color(0xFFEAF3FA) : const Color(0xFFE7F6F5);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBlue ? const Color(0xFFD1DFE9) : const Color(0xFFCBE6E4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                teacherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
