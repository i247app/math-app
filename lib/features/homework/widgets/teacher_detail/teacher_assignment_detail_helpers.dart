part of '../../../classroom/presentation/teacher_classroom_screens.dart';

List<_TeacherAssignmentLabeledValue> _exerciseInfoRows(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final rows = <_TeacherAssignmentLabeledValue>[];
  final chapter = exercise?.chapterName?.trim();
  final lesson = exercise?.lessonName?.trim();
  final description = exercise?.description?.trim();

  if (chapter != null && chapter.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentChapterLabel),
        chapter,
      ),
    );
  }
  if (lesson != null && lesson.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentLessonLabel),
        lesson,
      ),
    );
  }
  if (description != null && description.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentDescriptionLabel),
        description,
      ),
    );
  }

  return rows;
}

String _teacherExerciseClassLabel(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final classroomId = exercise?.classroomId;
  if (classroomId == null) {
    return '';
  }
  return context.formatText(AppKeys.teacherAssignmentId, {'id': classroomId});
}

String? _normalizeExerciseVisibility(String? value) {
  final normalized = value?.trim().toUpperCase();
  if (normalized == 'PUBLIC' || normalized == 'PRIVATE') {
    return normalized;
  }
  return null;
}

String _answerLetter(int index) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (index < 0 || index >= letters.length) {
    return '?';
  }
  return letters[index];
}

bool _isCorrectAnswer(
  ClassroomExerciseQuestion? question,
  String answer,
  int index,
) {
  final correct = question?.correctAnswer?.trim();
  if (correct == null || correct.isEmpty) {
    return false;
  }
  return correct == answer.trim() || correct == _answerLetter(index);
}
