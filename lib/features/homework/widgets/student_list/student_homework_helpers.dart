part of '../../presentation/student_homework_screen.dart';

String _studentHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  return id == null ? '' : 'ID: $id';
}

String _studentHomeworkQuestionCount(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final count = exercise.numQuestions ?? exercise.questions.length;
  if (count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return '';
}

String _studentHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentHomeworkDateLabel(exercise.endDate);
  if (date == null) {
    return '';
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String _studentHomeworkCreatedDate(ClassroomExercise exercise) {
  return _studentHomeworkDateLabel(exercise.createDt) ?? '';
}

String? _studentHomeworkDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_studentHomeworkTwoDigits(local.hour)}:'
      '${_studentHomeworkTwoDigits(local.minute)} '
      '${_studentHomeworkTwoDigits(local.day)}/'
      '${_studentHomeworkTwoDigits(local.month)}/${local.year}';
}

String _studentHomeworkTwoDigits(int value) => value.toString().padLeft(2, '0');

List<ClassroomExercise> _filteredExercises(
  List<ClassroomExercise> exercises,
  _StudentHomeworkFilter filter,
) {
  return exercises
      .where((exercise) {
        final submitted = _studentHomeworkIsSubmitted(exercise);
        final overdue = _studentHomeworkIsOverdue(exercise);
        return switch (filter) {
          _StudentHomeworkFilter.notSubmitted => !submitted && !overdue,
          _StudentHomeworkFilter.submitted => submitted,
          _StudentHomeworkFilter.overdue => overdue,
        };
      })
      .toList(growable: false);
}

bool _studentHomeworkIsSubmitted(ClassroomExercise exercise) {
  return exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

bool _studentHomeworkIsOverdue(ClassroomExercise exercise) {
  if (_studentHomeworkIsSubmitted(exercise)) {
    return false;
  }
  final parsed = DateTime.tryParse(exercise.endDate?.trim() ?? '');
  if (parsed == null) {
    return false;
  }
  return parsed.toLocal().isBefore(DateTime.now());
}
