import 'package:numi/features/classroom_exercise/data/classroom_exercise_api_models.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

extension SubmitClassroomExerciseAnswerConversion
    on SubmitClassroomExerciseAnswer {
  SubmitClassroomExerciseAnswerDto toDto() => SubmitClassroomExerciseAnswerDto(
    questionNumber: questionNumber,
    label: label,
    answer: answer,
    answerContent: answerContent,
  );
}

extension ClassroomExerciseSubmissionGradingDtoConversion
    on ClassroomExerciseSubmissionGradingDto {
  ClassroomExerciseSubmissionGrading toModel() =>
      ClassroomExerciseSubmissionGrading(
        aiReview: aiReview,
        correctNumber: correctNumber,
        scorePercentage: scorePercentage,
        totalQuestions: totalQuestions,
      );
}

extension ClassroomExerciseSubmissionResponseDtoConversion
    on ClassroomExerciseSubmissionResponseDto {
  ClassroomExerciseSubmissionResponse toModel() =>
      ClassroomExerciseSubmissionResponse(
        mstatus: mstatus,
        grading: grading?.toModel(),
        status: status,
        mmessage: mmessage,
        debug: debug,
      );
}

extension ClassroomExerciseQuestionDtoConversion
    on ClassroomExerciseQuestionDto {
  ClassroomExerciseQuestion toModel() => ClassroomExerciseQuestion(
    id: id,
    questionId: questionId,
    questionNumber: questionNumber,
    content: content,
    prompt: prompt,
    question: question,
    correctAnswer: correctAnswer,
    answers: answers,
  );
}

extension ClassroomExerciseDtoConversion on ClassroomExerciseDto {
  ClassroomExercise toModel() => ClassroomExercise(
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
    submissionStatus: submissionStatus,
    startDate: startDate,
    endDate: endDate,
    createDt: createDt,
    modifyDt: modifyDt,
    metadata: metadata,
    questions: questions.map((question) => question.toModel()).toList(),
  );
}
