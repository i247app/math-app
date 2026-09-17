import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_day_data.dart';

class LearningStreakData {
  const LearningStreakData({required this.title, required this.days});

  final String title;
  final List<LearningStreakDayData> days;
}
