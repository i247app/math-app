import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/data/dto/home_layout_models.dart';
import 'package:numi/features/home/data/home_layout_mappers.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';

ParentChildSummary? parentPrimarySummary(List<ParentChildSummary> summaries) {
  for (final summary in summaries) {
    if (summary.classroom != null) {
      return summary;
    }
  }
  return summaries.isEmpty ? null : summaries.first;
}

List<ParentChildSummary> summariesFromLayout(ParentHomeLayout? parent) {
  final children = parent?.children ?? const <StudentProfile>[];
  if (children.isEmpty) {
    return const <ParentChildSummary>[];
  }

  return children
      .map((child) {
        final childId = ActiveProfileSession.profileStableId(child);
        final classrooms = _classroomsForLayoutChild(parent, child);
        final assessments = <GeneratedQuiz>[
          for (final completion
              in parent?.recentCompletions ??
                  const <HomeLayoutRecentCompletion>[])
            if (layoutChildId(completion.child) == childId)
              quizFromRecentCompletion(completion),
        ]..sort((a, b) => quizDate(b).compareTo(quizDate(a)));

        return ParentChildSummary(
          profile: child,
          classroom: classrooms.isEmpty ? null : classrooms.first,
          classrooms: classrooms,
          assessments: assessments,
        );
      })
      .toList(growable: false);
}

List<ClassroomModel> _classroomsForLayoutChild(
  ParentHomeLayout? parent,
  StudentProfile child,
) {
  if (parent == null) {
    return const <ClassroomModel>[];
  }

  final childId = ActiveProfileSession.profileStableId(child);
  final classrooms = <ClassroomModel>[];

  for (final layoutClassroom in parent.classrooms) {
    if (layoutClassroom.memberProfileId == childId ||
        parent.children.length == 1) {
      _addClassroomIfMissing(classrooms, layoutClassroom.classroom);
    }
  }

  for (final completion in parent.recentCompletions) {
    if (layoutChildId(completion.child) == childId &&
        completion.classroom != null) {
      final classroomId =
          completion.classroomId ?? completion.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      _addClassroomIfMissing(
        classrooms,
        matchingClassroom ?? completion.classroom!,
      );
    }
  }

  for (final pending in parent.pendingExercises) {
    if (layoutChildId(pending.child) == childId && pending.classroom != null) {
      final classroomId = pending.classroomId ?? pending.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      _addClassroomIfMissing(
        classrooms,
        matchingClassroom ?? pending.classroom!,
      );
    }
  }

  for (final expired in parent.expiredExercises) {
    if (layoutChildId(expired.child) == childId && expired.classroom != null) {
      final classroomId = expired.classroomId ?? expired.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      _addClassroomIfMissing(
        classrooms,
        matchingClassroom ?? expired.classroom!,
      );
    }
  }

  return List<ClassroomModel>.unmodifiable(classrooms);
}

void _addClassroomIfMissing(
  List<ClassroomModel> classrooms,
  ClassroomModel classroom,
) {
  final stableId = classroom.stableId;
  final classroomCode = classroom.classroomCode?.trim();

  final alreadyAdded = classrooms.any((existing) {
    if (stableId != null && existing.stableId != null) {
      return stableId == existing.stableId;
    }
    if (classroomCode?.isNotEmpty == true) {
      return classroomCode == existing.classroomCode?.trim();
    }
    return classroom.name?.trim() == existing.name?.trim() &&
        classroom.teacherName?.trim() == existing.teacherName?.trim();
  });

  if (!alreadyAdded) {
    classrooms.add(classroom);
  }
}

ClassroomModel? _layoutClassroomById(
  ParentHomeLayout parent,
  int? classroomId,
) {
  if (classroomId == null) {
    return null;
  }
  for (final layoutClassroom in parent.classrooms) {
    if (layoutClassroom.classroom.stableId == classroomId) {
      return layoutClassroom.classroom;
    }
  }
  return null;
}
