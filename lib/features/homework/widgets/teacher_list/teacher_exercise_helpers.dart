part of '../../../classroom/presentation/teacher_classroom_screens.dart';

void _showTeacherHomeworkSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.teacherCreateAssignmentSoon)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
}

String _teacherExerciseTitle(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise?.stableId;
  if (id != null) {
    return context.formatText(AppKeys.teacherAssignmentId, {'id': id});
  }
  return '';
}

String _teacherExerciseQuestionCount(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final count = exercise?.numQuestions ?? exercise?.questions.length;
  if (count != null && count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return '';
}

String _teacherExerciseDueDate(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  return _teacherExerciseDateTimeLabel(exercise?.endDate) ?? '';
}

String? _teacherExerciseDateTimeLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)} '
      '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
}

_TeacherExerciseDateParts _teacherExerciseDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return const _TeacherExerciseDateParts(day: '23', month: 'TH10');
  }
  final local = parsed.toLocal();
  return _TeacherExerciseDateParts(
    day: _twoDigits(local.day),
    month: 'TH${_twoDigits(local.month)}',
  );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class _TeacherExerciseDateParts {
  const _TeacherExerciseDateParts({required this.day, required this.month});

  final String day;
  final String month;
}
