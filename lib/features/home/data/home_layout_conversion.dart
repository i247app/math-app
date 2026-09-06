import 'package:numi/features/home/data/home_layout_api_models.dart';
import 'package:numi/features/home/models/home_layout.dart';

extension HomeLayoutDtoConversion on HomeLayoutDto {
  HomeLayout toModel() => HomeLayout(
    role: role,
    profile: profile,
    parent: parent?.toModel(),
    student: student?.toModel(),
    teacher: teacher?.toModel(),
    rooms: rooms.map((room) => room.toModel()).toList(),
    subProfiles: subProfiles,
    tasks: tasks.map((task) => task.toModel()).toList(),
    messages: messages.map((message) => message.toModel()).toList(),
    quizzes: quizzes.map((quiz) => quiz.toModel()).toList(),
  );
}

extension HomeLayoutMessageDtoConversion on HomeLayoutMessageDto {
  HomeLayoutMessage toModel() => HomeLayoutMessage(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    sender: sender,
    classroom: classroom,
  );
}

extension HomeLayoutQuizDtoConversion on HomeLayoutQuizDto {
  HomeLayoutQuiz toModel() => HomeLayoutQuiz(
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

extension ParentHomeLayoutDtoConversion on ParentHomeLayoutDto {
  ParentHomeLayout toModel() => ParentHomeLayout(
    children: children,
    classrooms: classrooms.map((room) => room.toModel()).toList(),
    pendingExercises: pendingExercises.map((item) => item.toModel()).toList(),
    expiredExercises: expiredExercises.map((item) => item.toModel()).toList(),
    recentCompletions: recentCompletions.map((item) => item.toModel()).toList(),
  );
}

extension StudentHomeLayoutDtoConversion on StudentHomeLayoutDto {
  StudentHomeLayout toModel() => StudentHomeLayout(
    classrooms: classrooms.map((room) => room.toModel()).toList(),
    pendingExercises: pendingExercises.map((item) => item.toModel()).toList(),
    expiredExercises: expiredExercises.map((item) => item.toModel()).toList(),
    recentCompletions: recentCompletions.map((item) => item.toModel()).toList(),
  );
}

extension TeacherHomeLayoutDtoConversion on TeacherHomeLayoutDto {
  TeacherHomeLayout toModel() => TeacherHomeLayout(
    classrooms: classrooms.map((room) => room.toModel()).toList(),
    assignedExercises: assignedExercises,
    expiredExercises: expiredExercises,
  );
}

extension HomeLayoutTaskDtoConversion on HomeLayoutTaskDto {
  HomeLayoutTask toModel() => HomeLayoutTask(
    taskType: taskType,
    child: child,
    classroom: classroom,
    exercise: exercise,
    submission: submission?.toModel(),
  );
}

extension HomeLayoutTaskSubmissionDtoConversion on HomeLayoutTaskSubmissionDto {
  HomeLayoutTaskSubmission toModel() => HomeLayoutTaskSubmission(
    classroomExerciseSubmissionId: classroomExerciseSubmissionId,
    correctNumber: correctNumber,
    gradedDt: gradedDt,
    scorePercentage: scorePercentage,
    submissionStatus: submissionStatus,
    submittedDt: submittedDt,
    totalQuestions: totalQuestions,
  );
}

extension HomeLayoutClassroomDtoConversion on HomeLayoutClassroomDto {
  HomeLayoutClassroom toModel() => HomeLayoutClassroom(
    classroom: classroom,
    memberProfileId: memberProfileId,
    myRole: myRole,
  );
}

extension HomeLayoutPendingExerciseDtoConversion
    on HomeLayoutPendingExerciseDto {
  HomeLayoutPendingExercise toModel() => HomeLayoutPendingExercise(
    child: child,
    classroom: classroom,
    classroomExerciseId: classroomExerciseId,
    classroomId: classroomId,
    exercise: exercise,
  );
}

extension HomeLayoutRecentCompletionDtoConversion
    on HomeLayoutRecentCompletionDto {
  HomeLayoutRecentCompletion toModel() => HomeLayoutRecentCompletion(
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
