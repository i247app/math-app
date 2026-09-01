import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/presentation/widgets/sections/learning_streak/learning_streak.dart';

LearningStreakData parentLearningStreakContent(
  BuildContext context, {
  required bool hasCompletedAssessment,
}) {
  final labels = [
    context.getText(AppKeys.parentWeekdaySun),
    context.getText(AppKeys.parentWeekdayMon),
    context.getText(AppKeys.parentWeekdayTue),
    context.getText(AppKeys.parentWeekdayWed),
    context.getText(AppKeys.parentWeekdayThu),
    context.getText(AppKeys.parentWeekdayFri),
    context.getText(AppKeys.parentWeekdaySat),
  ];
  final states = hasCompletedAssessment
      ? const [
          LearningStreakDayState.done,
          LearningStreakDayState.done,
          LearningStreakDayState.done,
          LearningStreakDayState.current,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
        ]
      : const [
          LearningStreakDayState.current,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
          LearningStreakDayState.upcoming,
        ];

  return LearningStreakData(
    title: context.getText(AppKeys.parentLearningStreak),
    days: [
      for (var index = 0; index < labels.length; index++)
        LearningStreakDayData(label: labels[index], state: states[index]),
    ],
  );
}
