part of '../../../home_screen.dart';

class _ParentRoomDetailHero extends StatelessWidget {
  const _ParentRoomDetailHero({required this.entry});

  final _ParentRoomEntry entry;

  @override
  Widget build(BuildContext context) {
    final className = _roomClassName(context, entry.classroom);
    final teacherName = _roomTeacherName(context, entry);
    final grade = entry.classroom.gradeId == null
        ? context.getText(AppKeys.grade)
        : context.formatText(AppKeys.studentGradeFilter, {
            'grade': entry.classroom.gradeId,
          });
    final description = entry.classroom.description?.trim();
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFFF5C9E),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.xxxl,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _parentRoomShowComingSoon(context),
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _ParentRoomDetailMeta(icon: Icons.groups_2_outlined, label: grade),
          const SizedBox(height: 7),
          _ParentRoomDetailMeta(
            icon: Icons.workspace_premium_outlined,
            label: teacherName,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 7),
            _ParentRoomDetailMeta(
              icon: Icons.notes_rounded,
              label: description,
            ),
          ],
        ],
      ),
    );
  }
}
