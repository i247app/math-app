import 'package:flutter/material.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_achievement_card.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_achievements_header.dart';

class StudentAchievementPanel extends StatelessWidget {
  const StudentAchievementPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('achievement_panel_content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudentAchievementsHeader(scale: scale),
        SizedBox(height: 20 * scale),
        StudentAchievementCard(scale: scale),
      ],
    );
  }
}
