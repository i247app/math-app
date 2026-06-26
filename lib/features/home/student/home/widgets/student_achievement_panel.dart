part of '../../../home_screen.dart';

class _StudentAchievementPanel extends StatelessWidget {
  const _StudentAchievementPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('achievement_panel_content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StudentAchievementsHeader(scale: scale),
        SizedBox(height: 20 * scale),
        _StudentAchievementCard(scale: scale),
      ],
    );
  }
}
