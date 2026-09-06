const classroomExercisePurposeHomework = 'HOMEWORK';
const classroomExercisePurposeQuiz = 'QUIZ';
const classroomExercisePurposeExam = 'EXAM';

class SubmitClassroomExerciseAnswer {
  const SubmitClassroomExerciseAnswer({
    required this.questionNumber,
    required this.label,
    this.answer,
    this.answerContent,
  });

  final int questionNumber;
  final String label;
  final String? answer;
  final String? answerContent;
}

class ClassroomExerciseSubmissionResponse {
  const ClassroomExerciseSubmissionResponse({
    required this.mstatus,
    this.grading,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final ClassroomExerciseSubmissionGrading? grading;
  final String? status;
  final String? mmessage;
  final String? debug;
}

class ClassroomExerciseSubmissionGrading {
  const ClassroomExerciseSubmissionGrading({
    this.aiReview,
    this.correctNumber,
    this.scorePercentage,
    this.totalQuestions,
  });

  final String? aiReview;
  final int? correctNumber;
  final int? scorePercentage;
  final int? totalQuestions;
}

class ClassroomExercise {
  const ClassroomExercise({
    this.id,
    this.exerciseId,
    this.classroomExerciseId,
    this.classroomId,
    this.profileId,
    this.programId,
    this.title,
    this.numQuestions,
    this.chapterName,
    this.lessonName,
    this.description,
    this.shortText,
    this.visibility,
    this.purpose,
    this.status,
    this.submissionStatus,
    this.startDate,
    this.endDate,
    this.createDt,
    this.modifyDt,
    this.metadata,
    this.questions = const <ClassroomExerciseQuestion>[],
  });

  final int? id;
  final int? exerciseId;
  final int? classroomExerciseId;
  final int? classroomId;
  final int? profileId;
  final int? programId;
  final String? title;
  final int? numQuestions;
  final String? chapterName;
  final String? lessonName;
  final String? description;
  final String? shortText;
  final String? visibility;
  final String? purpose;
  final String? status;
  final String? submissionStatus;
  final String? startDate;
  final String? endDate;
  final String? createDt;
  final String? modifyDt;
  final Map<String, dynamic>? metadata;
  final List<ClassroomExerciseQuestion> questions;

  int? get stableId => classroomExerciseId ?? exerciseId ?? id;

  ClassroomExercise copyWith({String? submissionStatus}) => ClassroomExercise(
    id: id,
    exerciseId: exerciseId,
    classroomExerciseId: classroomExerciseId,
    classroomId: classroomId,
    profileId: profileId,
    programId: programId,
    title: title,
    numQuestions: numQuestions,
    chapterName: chapterName,
    lessonName: lessonName,
    description: description,
    shortText: shortText,
    visibility: visibility,
    purpose: purpose,
    status: status,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    startDate: startDate,
    endDate: endDate,
    createDt: createDt,
    modifyDt: modifyDt,
    metadata: metadata,
    questions: questions,
  );
}

class ClassroomExerciseQuestion {
  const ClassroomExerciseQuestion({
    this.id,
    this.questionId,
    this.questionNumber,
    this.content,
    this.prompt,
    this.question,
    this.correctAnswer,
    this.answers = const <String>[],
  });

  final int? id;
  final int? questionId;
  final int? questionNumber;
  final String? content;
  final String? prompt;
  final String? question;
  final String? correctAnswer;
  final List<String> answers;

  String? get displayPrompt {
    for (final value in <String?>[content, prompt, question]) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
