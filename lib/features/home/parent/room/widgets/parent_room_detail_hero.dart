part of '../../../home_screen.dart';

class _ParentRoomDetailHero extends StatelessWidget {
  const _ParentRoomDetailHero({required this.entry});

  final _ParentRoomEntry entry;

  @override
  Widget build(BuildContext context) {
    final className = _roomClassName(context, entry.classroom);
    final teacherName = _roomTeacherName(context, entry);
    final grade = entry.classroom.gradeId == null
        ? context.getText(AppKeys.teacherAssignmentClassGrade)
        : '${context.getText(AppKeys.teacherAssignmentClassGrade)} ${entry.classroom.gradeId}';
    final description = entry.classroom.description?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E8EA)),
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
                  style: const TextStyle(
                    color: Color(0xFF121B42),
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
