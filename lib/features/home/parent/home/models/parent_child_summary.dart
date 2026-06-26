part of '../../../home_screen.dart';

class _ParentChildSummary {
  const _ParentChildSummary({
    required this.profile,
    this.classroom,
    this.assessments = const <GeneratedQuiz>[],
  });

  final StudentProfile profile;
  final ClassroomModel? classroom;
  final List<GeneratedQuiz> assessments;
}
