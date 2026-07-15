import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/data/home_api.dart';
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
        final assessments = <GeneratedQuiz>[
          for (final completion
              in parent?.recentCompletions ??
                  const <HomeLayoutRecentCompletion>[])
            if (layoutChildId(completion.child) == childId)
              quizFromRecentCompletion(completion),
        ]..sort((a, b) => quizDate(b).compareTo(quizDate(a)));

        return ParentChildSummary(
          profile: child,
          classroom: _classroomForLayoutChild(parent, child),
          assessments: assessments,
        );
      })
      .toList(growable: false);
}

ClassroomModel? _classroomForLayoutChild(
  ParentHomeLayout? parent,
  StudentProfile child,
) {
  if (parent == null) {
    return null;
  }

  final childId = ActiveProfileSession.profileStableId(child);
  for (final classroom in parent.classrooms) {
    if (classroom.memberProfileId == childId) {
      return classroom.classroom;
    }
  }

  if (parent.children.length == 1 && parent.classrooms.length == 1) {
    return parent.classrooms.first.classroom;
  }

  for (final completion in parent.recentCompletions) {
    if (layoutChildId(completion.child) == childId &&
        completion.classroom != null) {
      final classroomId =
          completion.classroomId ?? completion.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return completion.classroom;
    }
  }

  for (final pending in parent.pendingExercises) {
    if (layoutChildId(pending.child) == childId && pending.classroom != null) {
      final classroomId = pending.classroomId ?? pending.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return pending.classroom;
    }
  }

  for (final expired in parent.expiredExercises) {
    if (layoutChildId(expired.child) == childId && expired.classroom != null) {
      final classroomId = expired.classroomId ?? expired.exercise?.classroomId;
      final matchingClassroom = _layoutClassroomById(parent, classroomId);
      if (matchingClassroom != null) {
        return matchingClassroom;
      }
      return expired.classroom;
    }
  }

  return null;
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
