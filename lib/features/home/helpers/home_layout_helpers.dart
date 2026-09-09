import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';

List<GeneratedExam> examsFromLayoutExams(List<HomeLayoutExam> exams) {
  return <GeneratedExam>[
    for (final exam in exams)
      GeneratedExam(
        id: exam.examId,
        examId: exam.examId,
        examStatus: exam.examStatus,
        purpose: exam.purpose,
        type: exam.purpose,
        typeOfExam: exam.typeOfExam,
        title: exam.title,
        shortText: exam.shortText,
        createDt: exam.createDt,
        modifyDt: exam.createDt,
        grading: ExamGrading(
          correctNumber: exam.correctNumber,
          scorePercentage: exam.scorePercentage,
          totalQuestions: exam.totalQuestions,
        ),
        questions: const <ExamQuestion>[],
      ),
  ]..sort((a, b) => examDate(b).compareTo(examDate(a)));
}

GeneratedExam examFromRecentCompletion(HomeLayoutRecentCompletion completion) {
  final exercise = completion.exercise;
  final exerciseId =
      completion.classroomExerciseId ??
      exercise?.classroomExerciseId ??
      exercise?.exerciseId ??
      exercise?.id;
  final totalQuestions = completion.totalQuestions ?? exercise?.numQuestions;
  return GeneratedExam(
    id: exerciseId,
    examId: exerciseId,
    profileId: layoutChildId(completion.child),
    examStatus: completion.submissionStatus,
    purpose: exercise?.purpose,
    type: exercise?.purpose,
    title: exercise?.title,
    shortText: exercise?.shortText ?? exercise?.description,
    createDt: completion.submittedDt ?? exercise?.createDt,
    modifyDt:
        completion.gradedDt ?? completion.submittedDt ?? exercise?.modifyDt,
    grading: ExamGrading(
      correctNumber: completion.correctNumber,
      scorePercentage: completion.scorePercentage,
      totalQuestions: totalQuestions,
    ),
    questions: const <ExamQuestion>[],
  );
}

int? layoutChildId(StudentProfile? child) {
  return child == null ? null : profileStableId(child);
}
