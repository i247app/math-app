part of '../../../home_screen.dart';

List<_ParentRoomEntry> _roomEntries(ParentHomeLayout? parent) {
  if (parent == null) {
    return const <_ParentRoomEntry>[];
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
  final entries = <_ParentRoomEntry>[];
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
      _ParentRoomEntry(layoutClassroom: layoutClassroom, child: child),
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
    final childId = _layoutChildId(pending.child);
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
    final childId = _layoutChildId(expired.child);
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
    final childId = _layoutChildId(completion.child);
    final classroomId =
        completion.classroomId ?? completion.exercise?.classroomId;
    final child =
        childId == null ? null : childById[childId] ?? completion.child;
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

List<HomeLayoutPendingExercise> _pendingForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.pendingExercises.where((pending) {
    return _sameRoom(
      classroomId: pending.classroomId ?? pending.exercise?.classroomId,
      childId: _layoutChildId(pending.child),
      entry: entry,
    );
  }).toList(growable: false);
}

List<HomeLayoutPendingExercise> _expiredForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutPendingExercise>[];
  }
  return parent.expiredExercises.where((expired) {
    return _sameRoom(
      classroomId: expired.classroomId ?? expired.exercise?.classroomId,
      childId: _layoutChildId(expired.child),
      entry: entry,
    );
  }).toList(growable: false);
}

List<HomeLayoutRecentCompletion> _completionsForRoomEntry(
  ParentHomeLayout? parent,
  _ParentRoomEntry entry,
) {
  if (parent == null) {
    return const <HomeLayoutRecentCompletion>[];
  }
  return parent.recentCompletions.where((completion) {
    return _sameRoom(
      classroomId: completion.classroomId ?? completion.exercise?.classroomId,
      childId: _layoutChildId(completion.child),
      entry: entry,
    );
  }).toList(growable: false);
}

bool _sameRoom({
  required int? classroomId,
  required int? childId,
  required _ParentRoomEntry entry,
}) {
  return classroomId != null &&
      classroomId == entry.classroomId &&
      childId != null &&
      childId == entry.memberProfileId;
}

String _roomClassName(BuildContext context, ClassroomModel? classroom) {
  final name = classroom?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return context.getText(AppKeys.teacherClassFallback);
}

String _roomTeacherName(BuildContext context, _ParentRoomEntry entry) {
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

String _roomExerciseTitle(BuildContext context, ClassroomExercise? exercise) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return context.getText(AppKeys.studentHomework);
}

String _roomPurposeLabel(BuildContext context, String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return context.getText(AppKeys.test);
  }
  return context.getText(AppKeys.studentHomework);
}

({Color color, Color badge}) _roomPurposeAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (color: const Color(0xFFBD1C21), badge: const Color(0xFFFFDDE6));
  }
  return (color: const Color(0xFF147A8F), badge: const Color(0xFFDDF4F8));
}

({Color color, Color background, IconData icon, String? asset})
    _roomPurposeListAccent(String? purpose) {
  final normalized = purpose?.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return (
      color: const Color(0xFFBD1C21),
      background: const Color(0xFFFFEFF1),
      icon: Icons.analytics_outlined,
      asset: 'assets/images/parent_room_assessment.svg',
    );
  }
  return (
    color: const Color(0xFF147A8F),
    background: const Color(0xFFEAF6FF),
    icon: Icons.menu_book_outlined,
    asset: null,
  );
}

Color _roomScoreAccent(int? scorePercentage) {
  final score = ((scorePercentage ?? 0) / 10).round();
  if (score >= 8) {
    return const Color(0xFF087D47);
  }
  return const Color(0xFFFF6B17);
}

String _roomExerciseCreatedDate(ClassroomExercise? exercise) {
  return _roomDateLabel(exercise?.createDt ?? exercise?.startDate);
}

String _roomExerciseDueLabel(
    BuildContext context, ClassroomExercise? exercise) {
  final date = _roomDateLabel(exercise?.endDate);
  if (date == '--/--/----') {
    return context.getText(AppKeys.teacherAssignmentDueLabel);
  }
  return context.formatText(AppKeys.studentHomeworkDueFormat, {'date': date});
}

String _roomDateOnlyLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

bool _roomExerciseDueSoon(ClassroomExercise? exercise) {
  final endDate = DateTime.tryParse(exercise?.endDate?.trim() ?? '')?.toLocal();
  if (endDate == null) {
    return false;
  }
  final remaining = endDate.difference(DateTime.now());
  return !remaining.isNegative && remaining <= const Duration(days: 2);
}

String _roomDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '')?.toLocal();
  if (parsed == null) {
    return '--/--/----';
  }
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)} '
      '${twoDigits(parsed.day)}/${twoDigits(parsed.month)}/${parsed.year}';
}

void _showExpiredExerciseMessage(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.homeworkExpiredCannotSubmit)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );
}

void _parentRoomShowComingSoon(BuildContext context) {
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
