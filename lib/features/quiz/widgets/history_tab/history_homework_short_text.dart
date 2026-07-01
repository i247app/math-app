part of '../../history_tab.dart';

String? _historyHomeworkShortText(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final values = <String?>[
    exercise.shortText,
    exercise.description,
    exercise.lessonName,
    exercise.chapterName,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  final count = exercise.numQuestions ?? exercise.questions.length;
  if (count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return null;
}
