part of '../../../home_screen.dart';

class _ParentRoomDetailShortcuts extends StatelessWidget {
  const _ParentRoomDetailShortcuts({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      padding: EdgeInsets.zero,
      children: [
        _ParentRoomShortcutTile(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFF0A2B67),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.studentClassAssignments),
          subtitle: context.formatText(
            AppKeys.studentClassAssignmentsCountFormat,
            {'count': pendingCount},
          ),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFFF6B4A),
          iconBg: const Color(0xFFFFEFE8),
          title: context.getText(AppKeys.studentClassGrades),
          subtitle: completedCount == 0
              ? context.getText(AppKeys.incomplete)
              : context.getText(AppKeys.completedResultTitle),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.campaign_outlined,
          iconColor: const Color(0xFF3265E6),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.navMembers),
          subtitle: context.getText(AppKeys.studentClassComingSoon),
        ),
        _ParentRoomShortcutTile(
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFFFF7A1A),
          iconBg: const Color(0xFFFFF0D8),
          title: context.getText(AppKeys.studentClassMaterials),
          subtitle: context.getText(AppKeys.studentClassMaterialsSubtitle),
        ),
      ],
    );
  }
}
