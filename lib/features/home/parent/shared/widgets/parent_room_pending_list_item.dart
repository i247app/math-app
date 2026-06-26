part of '../../../home_screen.dart';

class _ParentRoomPendingListItem extends StatelessWidget {
  const _ParentRoomPendingListItem({
    required this.pending,
    required this.onTap,
    this.isExpired = false,
  });

  final HomeLayoutPendingExercise pending;
  final VoidCallback onTap;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final exercise = pending.exercise;
    final title = _roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : homeProfileDisplayName(context, pending.child!);
    final classroomName = _roomClassName(context, pending.classroom);
    final accent = isExpired
        ? (
            color: const Color(0xFFFF7A1A),
            background: const Color(0xFFFFF0D8),
            icon: Icons.warning_amber_rounded,
            asset: null,
          )
        : _roomPurposeListAccent(exercise?.purpose);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _ParentRoomListIconBox(
              icon: accent.icon,
              asset: accent.asset,
              color: accent.color,
              backgroundColor: accent.background,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _ParentRoomBadgeRow(
                          childName: childName,
                          classroomName: classroomName,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ParentRoomListDateLabel(
                        date: _roomDateOnlyLabel(
                          exercise?.endDate ?? exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _ParentRoomListTitle(title: title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
