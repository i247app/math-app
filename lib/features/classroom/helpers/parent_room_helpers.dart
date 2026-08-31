import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/data/dto/home_layout_models.dart';
import 'package:numi/features/home/data/home_layout_mappers.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';

List<ParentRoomEntry> roomEntries(ParentHomeLayout? parent) {
  if (parent == null) {
    return const <ParentRoomEntry>[];
  }

  final childById = <int, StudentProfile>{
    for (final child in parent.children)
      if (ActiveProfileSession.profileStableId(child) != null)
        ActiveProfileSession.profileStableId(child)!: child,
  };

  final layoutClassroomById = <int, HomeLayoutClassroom>{
    for (final layoutClassroom in parent.classrooms)
      if (layoutClassroom.classroom.stableId != null)
        layoutClassroom.classroom.stableId!: layoutClassroom,
  };
  final entries = <ParentRoomEntry>[];
  final entryKeys = <String>{};

  void addEntry({
    required HomeLayoutClassroom layoutClassroom,
    required StudentProfile child,
    int? memberProfileId,
  }) {
    final classroomId = layoutClassroom.classroom.stableId;
    final childId =
        memberProfileId ?? ActiveProfileSession.profileStableId(child);
    if (classroomId == null || childId == null) {
      return;
    }
    final key = '$classroomId:$childId';
    if (!entryKeys.add(key)) {
      return;
    }
    entries.add(
      ParentRoomEntry(layoutClassroom: layoutClassroom, child: child),
    );
  }

  for (final layoutClassroom in parent.classrooms) {
    final memberProfileId = layoutClassroom.memberProfileId;
    final child = memberProfileId == null ? null : childById[memberProfileId];
    if (child != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: memberProfileId,
      );
    } else if (parent.children.length == 1) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: parent.children.first,
        memberProfileId: memberProfileId,
      );
    }
  }

  for (final pending in parent.pendingExercises) {
    final childId = layoutChildId(pending.child);
    final classroomId = pending.classroomId ?? pending.exercise?.classroomId;
    final child = childId == null ? null : childById[childId] ?? pending.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: pending.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  for (final expired in parent.expiredExercises) {
    final childId = layoutChildId(expired.child);
    final classroomId = expired.classroomId ?? expired.exercise?.classroomId;
    final child = childId == null ? null : childById[childId] ?? expired.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: expired.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  for (final completion in parent.recentCompletions) {
    final childId = layoutChildId(completion.child);
    final classroomId =
        completion.classroomId ?? completion.exercise?.classroomId;
    final child = childId == null
        ? null
        : childById[childId] ?? completion.child;
    if (child == null || classroomId == null) {
      continue;
    }
    final layoutClassroom = _layoutClassroomForChildClass(
      parent: parent,
      layoutClassroomById: layoutClassroomById,
      classroomId: classroomId,
      childId: childId!,
      fallbackClassroom: completion.classroom,
    );
    if (layoutClassroom != null) {
      addEntry(
        layoutClassroom: layoutClassroom,
        child: child,
        memberProfileId: childId,
      );
    }
  }

  return entries;
}

HomeLayoutClassroom? _layoutClassroomForChildClass({
  required ParentHomeLayout parent,
  required Map<int, HomeLayoutClassroom> layoutClassroomById,
  required int classroomId,
  required int childId,
  required ClassroomModel? fallbackClassroom,
}) {
  for (final layoutClassroom in parent.classrooms) {
    if (layoutClassroom.classroom.stableId == classroomId &&
        layoutClassroom.memberProfileId == childId) {
      return layoutClassroom;
    }
  }

  final sharedClassroom = layoutClassroomById[classroomId];
  if (sharedClassroom != null) {
    return HomeLayoutClassroom(
      classroom: sharedClassroom.classroom,
      memberProfileId: childId,
      myRole: sharedClassroom.myRole,
    );
  }

  if (fallbackClassroom != null) {
    return HomeLayoutClassroom(
      classroom: fallbackClassroom,
      memberProfileId: childId,
    );
  }

  return null;
}

List<HomeLayoutPendingExercise> pendingForRoomEntry(
  ParentHomeLayout? parent,
  ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.pendingExercises
      .where((pending) {
        return _sameRoom(
          classroomId: pending.classroomId ?? pending.exercise?.classroomId,
          childId: layoutChildId(pending.child),
          entry: entry,
        );
      })
      .toList(growable: false);
}

List<HomeLayoutPendingExercise> expiredForRoomEntry(
  ParentHomeLayout? parent,
  ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.expiredExercises
      .where((expired) {
        return _sameRoom(
          classroomId: expired.classroomId ?? expired.exercise?.classroomId,
          childId: layoutChildId(expired.child),
          entry: entry,
        );
      })
      .toList(growable: false);
}

List<HomeLayoutRecentCompletion> completionsForRoomEntry(
  ParentHomeLayout? parent,
  ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutRecentCompletion>[];
  }
  return parent.recentCompletions
      .where((completion) {
        return _sameRoom(
          classroomId:
              completion.classroomId ?? completion.exercise?.classroomId,
          childId: layoutChildId(completion.child),
          entry: entry,
        );
      })
      .toList(growable: false);
}

bool _sameRoom({
  required int? classroomId,
  required int? childId,
  required ParentRoomEntry entry,
}) {
  return classroomId != null &&
      classroomId == entry.classroomId &&
      childId != null &&
      childId == entry.memberProfileId;
}

String roomClassName(BuildContext context, ClassroomModel? classroom) {
  final name = classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return context.getText(AppKeys.teacherClassFallback);
}

String roomTeacherName(BuildContext context, ParentRoomEntry entry) {
  final values = <String?>[
    entry.classroom.teacherName,
    entry.classroom.owner?.name,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return context.getText(AppKeys.teacherFallback);
}

String roomExerciseTitle(BuildContext context, ClassroomExercise? exercise) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return context.getText(AppKeys.studentHomework);
}

String roomPurposeLabel(BuildContext context, String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return context.getText(AppKeys.test);
  }
  return context.getText(AppKeys.studentHomework);
}

({Color color, Color badge}) roomPurposeAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (color: const Color(0xFFBD1C21), badge: const Color(0xFFFFDDE6));
  }
  return (color: const Color(0xFF147A8F), badge: const Color(0xFFDDF4F8));
}

({Color color, Color background, IconData icon, String? asset})
roomPurposeListAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (
      color: const Color(0xFFBD1C21),
      background: const Color(0xFFFFEFF1),
      icon: Icons.analytics_outlined,
      asset: 'assets/icons/parent-room-assessment.svg',
    );
  }
  return (
    color: const Color(0xFF147A8F),
    background: const Color(0xFFEAF6FF),
    icon: Icons.menu_book_outlined,
    asset: null,
  );
}

Color roomScoreAccent(int? scorePercentage) {
  final score = ((scorePercentage ?? 0) / 10).round();
  if (score >= 8) {
    return const Color(0xFF087D47);
  }
  return const Color(0xFFFF6B17);
}

String roomExerciseCreatedDate(ClassroomExercise? exercise) {
  return roomDateLabel(exercise?.createDt ?? exercise?.startDate);
}

String roomExerciseDueLabel(BuildContext context, ClassroomExercise? exercise) {
  final date = roomDateLabel(exercise?.endDate);
  if (date == '--/--/----') {
    return context.getText(AppKeys.teacherAssignmentDueLabel);
  }
  return context.formatText(AppKeys.studentHomeworkDueFormat, {'date': date});
}

String roomDateOnlyLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

bool roomExerciseDueSoon(ClassroomExercise? exercise) {
  final endDate = DateTime.tryParse(exercise?.endDate?.trim() ?? '')?.toLocal();
  if (endDate == null) {
    return false;
  }
  final remaining = endDate.difference(DateTime.now());
  return !remaining.isNegative && remaining <= const Duration(days: 2);
}

String roomDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)} '
      '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

void showExpiredExerciseMessage(BuildContext context) {
  HapticFeedback.selectionClick();
  context.showErrorDialog(context.getText(AppKeys.homeworkExpiredCannotSubmit));
}

void parentRoomShowComingSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  context.showInfoDialog(context.getText(AppKeys.studentClassComingSoon));
}
