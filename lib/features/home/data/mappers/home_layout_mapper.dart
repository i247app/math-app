import 'package:numi/features/home/data/dto/home_layout_models.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';

extension HomeLayoutDtoMapper on HomeLayoutDto {
  HomeLayout toDomain() => HomeLayout(
    role: role,
    profile: profile,
    parent: parent?.toDomain(),
    student: student?.toDomain(),
    teacher: teacher?.toDomain(),
    rooms: rooms.map((room) => room.toDomain()).toList(),
    subProfiles: subProfiles,
    tasks: tasks.map((task) => task.toDomain()).toList(),
    messages: messages.map((message) => message.toDomain()).toList(),
    quizzes: quizzes.map((quiz) => quiz.toDomain()).toList(),
  );
}

extension HomeLayoutMessageDtoMapper on HomeLayoutMessageDto {
  HomeLayoutMessage toDomain() => HomeLayoutMessage(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    sender: sender,
    classroom: classroom,
  );
}

extension HomeLayoutQuizDtoMapper on HomeLayoutQuizDto {
  HomeLayoutQuiz toDomain() => HomeLayoutQuiz(
    quizId: quizId,
    createDt: createDt,
    purpose: purpose,
    quizStatus: quizStatus,
    scorePercentage: scorePercentage,
    shortText: shortText,
    title: title,
    totalQuestions: totalQuestions,
    typeOfQuiz: typeOfQuiz,
    correctNumber: correctNumber,
  );
}

extension ParentHomeLayoutDtoMapper on ParentHomeLayoutDto {
  ParentHomeLayout toDomain() => ParentHomeLayout(
    children: children,
    classrooms: classrooms.map((room) => room.toDomain()).toList(),
    pendingExercises: pendingExercises.map((item) => item.toDomain()).toList(),
    expiredExercises: expiredExercises.map((item) => item.toDomain()).toList(),
    recentCompletions: recentCompletions
        .map((item) => item.toDomain())
        .toList(),
  );
}

extension StudentHomeLayoutDtoMapper on StudentHomeLayoutDto {
  StudentHomeLayout toDomain() => StudentHomeLayout(
    classrooms: classrooms.map((room) => room.toDomain()).toList(),
    pendingExercises: pendingExercises.map((item) => item.toDomain()).toList(),
    expiredExercises: expiredExercises.map((item) => item.toDomain()).toList(),
    recentCompletions: recentCompletions
        .map((item) => item.toDomain())
        .toList(),
  );
}

extension TeacherHomeLayoutDtoMapper on TeacherHomeLayoutDto {
  TeacherHomeLayout toDomain() => TeacherHomeLayout(
    classrooms: classrooms.map((room) => room.toDomain()).toList(),
    assignedExercises: assignedExercises,
    expiredExercises: expiredExercises,
  );
}

extension HomeLayoutTaskDtoMapper on HomeLayoutTaskDto {
  HomeLayoutTask toDomain() => HomeLayoutTask(
    taskType: taskType,
    child: child,
    classroom: classroom,
    exercise: exercise,
    submission: submission?.toDomain(),
  );
}

extension HomeLayoutTaskSubmissionDtoMapper on HomeLayoutTaskSubmissionDto {
  HomeLayoutTaskSubmission toDomain() => HomeLayoutTaskSubmission(
    classroomExerciseSubmissionId: classroomExerciseSubmissionId,
    correctNumber: correctNumber,
    gradedDt: gradedDt,
    scorePercentage: scorePercentage,
    submissionStatus: submissionStatus,
    submittedDt: submittedDt,
    totalQuestions: totalQuestions,
  );
}

extension HomeLayoutClassroomDtoMapper on HomeLayoutClassroomDto {
  HomeLayoutClassroom toDomain() => HomeLayoutClassroom(
    classroom: classroom,
    memberProfileId: memberProfileId,
    myRole: myRole,
  );
}

extension HomeLayoutPendingExerciseDtoMapper on HomeLayoutPendingExerciseDto {
  HomeLayoutPendingExercise toDomain() => HomeLayoutPendingExercise(
    child: child,
    classroom: classroom,
    classroomExerciseId: classroomExerciseId,
    classroomId: classroomId,
    exercise: exercise,
  );
}

extension HomeLayoutRecentCompletionDtoMapper on HomeLayoutRecentCompletionDto {
  HomeLayoutRecentCompletion toDomain() => HomeLayoutRecentCompletion(
    child: child,
    classroom: classroom,
    classroomExerciseId: classroomExerciseId,
    classroomExerciseSubmissionId: classroomExerciseSubmissionId,
    classroomId: classroomId,
    correctNumber: correctNumber,
    exercise: exercise,
    gradedDt: gradedDt,
    scorePercentage: scorePercentage,
    submissionStatus: submissionStatus,
    submittedDt: submittedDt,
    totalQuestions: totalQuestions,
  );
}
