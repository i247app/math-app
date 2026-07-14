part of 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

String _historyHomeworkTitle(BuildContext context, ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  if (id != null) {
    return '${context.getText(AppKeys.studentHomework)} #$id';
  }
  return context.getText(AppKeys.studentHomework);
}
