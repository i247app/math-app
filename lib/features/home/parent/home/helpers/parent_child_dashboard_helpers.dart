import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/profile/active_profile_session.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';

ParentChildSummary? parentPrimarySummary(
  List<ParentChildSummary> summaries,
) {
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

List<GeneratedQuiz> quizzesFromLayoutQuizzes(List<HomeLayoutQuiz> quizzes) {
  return <GeneratedQuiz>[
    for (final quiz in quizzes)
      GeneratedQuiz(
        id: quiz.quizId,
        quizId: quiz.quizId,
        quizStatus: quiz.quizStatus,
        purpose: quiz.purpose,
        type: quiz.purpose,
        typeOfQuiz: quiz.typeOfQuiz,
        title: quiz.title,
        shortText: quiz.shortText,
        createDt: quiz.createDt,
        modifyDt: quiz.createDt,
        grading: QuizGrading(
          correctNumber: quiz.correctNumber,
          scorePercentage: quiz.scorePercentage,
          totalQuestions: quiz.totalQuestions,
        ),
        questions: const <QuizQuestion>[],
      ),
  ]..sort((a, b) => quizDate(b).compareTo(quizDate(a)));
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

GeneratedQuiz quizFromRecentCompletion(HomeLayoutRecentCompletion completion) {
  final exercise = completion.exercise;
  final exerciseId =
      completion.classroomExerciseId ??
      exercise?.classroomExerciseId ??
      exercise?.exerciseId ??
      exercise?.id;
  final totalQuestions = completion.totalQuestions ?? exercise?.numQuestions;
  return GeneratedQuiz(
    id: exerciseId,
    quizId: exerciseId,
    profileId: layoutChildId(completion.child),
    quizStatus: completion.submissionStatus,
    purpose: exercise?.purpose,
    type: exercise?.purpose,
    title: exercise?.title,
    shortText: exercise?.shortText ?? exercise?.description,
    createDt: completion.submittedDt ?? exercise?.createDt,
    modifyDt:
        completion.gradedDt ?? completion.submittedDt ?? exercise?.modifyDt,
    grading: QuizGrading(
      correctNumber: completion.correctNumber,
      scorePercentage: completion.scorePercentage,
      totalQuestions: totalQuestions,
    ),
    questions: const <QuizQuestion>[],
  );
}

int? layoutChildId(StudentProfile? child) {
  return child == null ? null : ActiveProfileSession.profileStableId(child);
}