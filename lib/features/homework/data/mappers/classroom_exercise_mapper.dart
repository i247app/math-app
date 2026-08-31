import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

extension SubmitClassroomExerciseAnswerMapper on SubmitClassroomExerciseAnswer {
  SubmitClassroomExerciseAnswerDto toDto() => SubmitClassroomExerciseAnswerDto(
    questionNumber: questionNumber,
    label: label,
    answer: answer,
    answerContent: answerContent,
  );
}

extension ClassroomExerciseSubmissionGradingDtoMapper
    on ClassroomExerciseSubmissionGradingDto {
  ClassroomExerciseSubmissionGrading toDomain() =>
      ClassroomExerciseSubmissionGrading(
        aiReview: aiReview,
        correctNumber: correctNumber,
        scorePercentage: scorePercentage,
        totalQuestions: totalQuestions,
      );
}

extension ClassroomExerciseSubmissionResponseDtoMapper
    on ClassroomExerciseSubmissionResponseDto {
  ClassroomExerciseSubmissionResponse toDomain() =>
      ClassroomExerciseSubmissionResponse(
        mstatus: mstatus,
        grading: grading?.toDomain(),
        status: status,
        mmessage: mmessage,
        debug: debug,
      );
}

extension ClassroomExerciseQuestionDtoMapper on ClassroomExerciseQuestionDto {
  ClassroomExerciseQuestion toDomain() => ClassroomExerciseQuestion(
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

extension ClassroomExerciseDtoMapper on ClassroomExerciseDto {
  ClassroomExercise toDomain() => ClassroomExercise(
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
    questions: questions.map((question) => question.toDomain()).toList(),
  );
}
