import 'package:flutter/material.dart';
import 'package:numi/features/home/student/home/widgets/student_achievement_card.dart';
import 'package:numi/features/home/student/home/widgets/student_achievements_header.dart';

class StudentAchievementPanel extends StatelessWidget {
  const StudentAchievementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('achievement_panel_content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [StudentAchievementsHeader(), StudentAchievementCard()],
    );
  }
}
