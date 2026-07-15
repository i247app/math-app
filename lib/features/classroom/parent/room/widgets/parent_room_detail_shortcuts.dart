import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_shortcut_tile.dart';

class ParentRoomDetailShortcuts extends StatelessWidget {
  const ParentRoomDetailShortcuts({
    super.key,
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
        ParentRoomShortcutTile(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFF0A2B67),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.studentClassAssignments),
          subtitle: context.formatText(
            AppKeys.studentClassAssignmentsCountFormat,
            {'count': pendingCount},
          ),
        ),
        ParentRoomShortcutTile(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFFF6B4A),
          iconBg: const Color(0xFFFFEFE8),
          title: context.getText(AppKeys.studentClassGrades),
          subtitle: completedCount == 0
              ? context.getText(AppKeys.incomplete)
              : context.getText(AppKeys.completedResultTitle),
        ),
        ParentRoomShortcutTile(
          icon: Icons.campaign_outlined,
          iconColor: const Color(0xFF3265E6),
          iconBg: const Color(0xFFEAF1FF),
          title: context.getText(AppKeys.navMembers),
          subtitle: context.getText(AppKeys.studentClassComingSoon),
        ),
        ParentRoomShortcutTile(
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
