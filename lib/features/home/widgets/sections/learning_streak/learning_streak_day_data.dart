import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_day_state.dart';

class LearningStreakDayData {
  const LearningStreakDayData({
    required this.label,
    required this.state,
    this.upcomingValue = '5',
  });

  final String label;
  final LearningStreakDayState state;
  final String upcomingValue;
}
