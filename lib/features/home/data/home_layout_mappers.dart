import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/quiz/parent/assessment/helpers/parent_assessment_quiz_helpers.dart';

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
