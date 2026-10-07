import 'package:flutter/foundation.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

/// A checkpoint resolved from server history and locally completed attempts.
@immutable
class GradeRoadmapLevelState {
  const GradeRoadmapLevelState({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    this.activeExam,
    this.completedExam,
  });

  final int level;
  final bool isUnlocked;
  final bool isCompleted;
  final GeneratedExam? activeExam;
  final GeneratedExam? completedExam;
}

/// Immutable snapshot consumed by the roadmap UI.
@immutable
class GradeRoadmapState {
  GradeRoadmapState({
    required this.selectedGrade,
    required this.currentLevel,
    required List<GradeRoadmapLevelState> levels,
    this.gradeLevels,
    this.isLoading = true,
    this.isOpeningExam = false,
    this.openingLevel,
    this.errorKey,
  }) : levels = List.unmodifiable(levels);

  final int selectedGrade;
  final int currentLevel;
  final GradeLevels? gradeLevels;
  final List<GradeRoadmapLevelState> levels;
  final bool isLoading;
  final bool isOpeningExam;
  final int? openingLevel;
  final String? errorKey;

  GradeRoadmapLevelState level(int apiLevel) => levels[apiLevel - 1];
}

enum GradeRoadmapExamDestination { attempt, review }

/// Captures the selected grade and attempt before the UI opens a route.
@immutable
class GradeRoadmapExamTarget {
  const GradeRoadmapExamTarget({
    required this.destination,
    required this.grade,
    required this.level,
    this.exam,
  });

  final GradeRoadmapExamDestination destination;
  final int grade;
  final int level;
  final GeneratedExam? exam;
}
