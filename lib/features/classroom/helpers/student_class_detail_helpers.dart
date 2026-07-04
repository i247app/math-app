import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';

String? studentClassNonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String? studentClassTeacherAvatarUrl(ClassroomModel? classroom) {
  final values = <String?>[
    classroom?.owner?.avatarUrl,
    classroom?.owner?.imageUrl,
    classroom?.owner?.fileUrl,
    classroom?.avatarUrl,
    classroom?.imageUrl,
    classroom?.fileUrl,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

String studentClassTeacherInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.characters.first.toUpperCase();
}

List<ClassroomExercise> upcomingStudentHomeworkExercises(
  List<ClassroomExercise> exercises,
) {
  final now = DateTime.now();
  final upcoming = exercises
      .where((exercise) {
        final endDate = DateTime.tryParse(exercise.endDate?.trim() ?? '');
        return endDate != null && endDate.toLocal().isAfter(now);
      })
      .toList(growable: false);

  return upcoming..sort((first, second) {
    final firstEnd = DateTime.tryParse(first.endDate?.trim() ?? '');
    final secondEnd = DateTime.tryParse(second.endDate?.trim() ?? '');
    if (firstEnd == null && secondEnd == null) {
      return 0;
    }
    if (firstEnd == null) {
      return 1;
    }
    if (secondEnd == null) {
      return -1;
    }
    return firstEnd.compareTo(secondEnd);
  });
}

String studentClassHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  return id == null ? '' : 'ID: $id';
}

String studentClassHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = studentClassDateTimeLabel(exercise.endDate);
  if (date == null) {
    return '';
  }
  return context.formatText(AppKeys.studentHomeworkDueFormat, {'date': date});
}

bool studentClassHomeworkIsSubmitted(ClassroomExercise exercise) {
  return exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

String? studentClassDateTimeLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)} '
      '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
}

void showStudentClassComingSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.studentClassComingSoon)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
