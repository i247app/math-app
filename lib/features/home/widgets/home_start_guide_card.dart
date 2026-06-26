part of '../home_screen.dart';

class _HomeStartGuideCard extends StatelessWidget {
  const _HomeStartGuideCard({
    required this.onAssessmentTap,
    required this.onRoadmapTap,
    required this.onClassroomTap,
  });

  final VoidCallback onAssessmentTap;
  final VoidCallback onRoadmapTap;
  final VoidCallback onClassroomTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E1E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _HomeGuideItem(
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF069C95),
            title: context.getText(AppKeys.parentAssessmentTitle),
            subtitle: context.getText(AppKeys.parentAssessmentSubtitle),
            onTap: onAssessmentTap,
          ),
          const SizedBox(height: 10),
          _HomeGuideItem(
            icon: Icons.sports_esports_rounded,
            color: const Color(0xFFFF6636),
            title: context.getText(AppKeys.parentRoadmapTitle),
            subtitle: context.getText(AppKeys.parentRoadmapSubtitle),
            onTap: onRoadmapTap,
          ),
          const SizedBox(height: 10),
          _HomeGuideItem(
            icon: Icons.meeting_room_rounded,
            color: const Color(0xFF6451A6),
            title: context.getText(AppKeys.parentJoinRoomTitle),
            subtitle: context.getText(AppKeys.parentJoinRoomSubtitle),
            onTap: onClassroomTap,
          ),
        ],
      ),
    );
  }
}
