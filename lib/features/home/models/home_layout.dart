import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/profile/models/profile.dart';

class HomeLayout {
  const HomeLayout({
    this.role,
    this.profile,
    this.parent,
    this.student,
    this.teacher,
    this.rooms = const <HomeLayoutClassroom>[],
    this.subProfiles = const <StudentProfile>[],
    this.tasks = const <HomeLayoutTask>[],
    this.messages = const <HomeLayoutMessage>[],
    this.quizzes = const <HomeLayoutQuiz>[],
  });

  final String? role;
  final StudentProfile? profile;
  final ParentHomeLayout? parent;
  final StudentHomeLayout? student;
  final TeacherHomeLayout? teacher;
  final List<HomeLayoutClassroom> rooms;
  final List<StudentProfile> subProfiles;
  final List<HomeLayoutTask> tasks;
  final List<HomeLayoutMessage> messages;
  final List<HomeLayoutQuiz> quizzes;
}

class HomeLayoutMessage {
  const HomeLayoutMessage({
    this.id,
    this.title,
    this.message,
    this.createdAt,
    this.sender,
    this.classroom,
  });

  final int? id;
  final String? title;
  final String? message;
  final String? createdAt;
  final StudentProfile? sender;
  final ClassroomModel? classroom;
}

class HomeLayoutQuiz {
  const HomeLayoutQuiz({
    this.quizId,
    this.createDt,
    this.purpose,
    this.quizStatus,
    this.scorePercentage,
    this.shortText,
    this.title,
    this.totalQuestions,
    this.typeOfQuiz,
    this.correctNumber,
  });

  final int? quizId;
  final String? createDt;
  final String? purpose;
  final String? quizStatus;
  final int? scorePercentage;
  final String? shortText;
  final String? title;
  final int? totalQuestions;
  final String? typeOfQuiz;
  final int? correctNumber;
}

class ParentHomeLayout {
  const ParentHomeLayout({
    this.children = const <StudentProfile>[],
    this.classrooms = const <HomeLayoutClassroom>[],
    this.pendingExercises = const <HomeLayoutPendingExercise>[],
    this.expiredExercises = const <HomeLayoutPendingExercise>[],
    this.recentCompletions = const <HomeLayoutRecentCompletion>[],
  });

  final List<StudentProfile> children;
  final List<HomeLayoutClassroom> classrooms;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutPendingExercise> expiredExercises;
  final List<HomeLayoutRecentCompletion> recentCompletions;
}

class StudentHomeLayout {
  const StudentHomeLayout({
    this.classrooms = const <HomeLayoutClassroom>[],
    this.pendingExercises = const <HomeLayoutPendingExercise>[],
    this.expiredExercises = const <HomeLayoutPendingExercise>[],
    this.recentCompletions = const <HomeLayoutRecentCompletion>[],
  });

  final List<HomeLayoutClassroom> classrooms;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutPendingExercise> expiredExercises;
  final List<HomeLayoutRecentCompletion> recentCompletions;
}

class TeacherHomeLayout {
  const TeacherHomeLayout({
    this.classrooms = const <HomeLayoutClassroom>[],
    this.assignedExercises = const <ClassroomExercise>[],
    this.expiredExercises = const <ClassroomExercise>[],
  });

  final List<HomeLayoutClassroom> classrooms;
  final List<ClassroomExercise> assignedExercises;
  final List<ClassroomExercise> expiredExercises;
}

class HomeLayoutTask {
  const HomeLayoutTask({
    this.taskType,
    this.child,
    this.classroom,
    this.exercise,
    this.submission,
  });

  final String? taskType;
  final StudentProfile? child;
  final ClassroomModel? classroom;
  final ClassroomExercise? exercise;
  final HomeLayoutTaskSubmission? submission;

  String get normalizedType => taskType?.trim().toUpperCase() ?? '';
  bool get isPending => normalizedType == 'PENDING';
  bool get isCompleted => normalizedType == 'COMPLETED';
  bool get isAssigned => normalizedType == 'ASSIGNED';
  bool get isExpired => normalizedType == 'EXPIRED';
}

class HomeLayoutTaskSubmission {
  const HomeLayoutTaskSubmission({
    this.classroomExerciseSubmissionId,
    this.correctNumber,
    this.gradedDt,
    this.scorePercentage,
    this.submissionStatus,
    this.submittedDt,
    this.totalQuestions,
  });

  final int? classroomExerciseSubmissionId;
  final int? correctNumber;
  final String? gradedDt;
  final int? scorePercentage;
  final String? submissionStatus;
  final String? submittedDt;
  final int? totalQuestions;
}

class HomeLayoutClassroom {
  const HomeLayoutClassroom({
    required this.classroom,
    this.memberProfileId,
    this.myRole,
  });

  final ClassroomModel classroom;
  final int? memberProfileId;
  final String? myRole;
}

class HomeLayoutPendingExercise {
  const HomeLayoutPendingExercise({
    this.child,
    this.classroom,
    this.classroomExerciseId,
    this.classroomId,
    this.exercise,
  });

  final StudentProfile? child;
  final ClassroomModel? classroom;
  final int? classroomExerciseId;
  final int? classroomId;
  final ClassroomExercise? exercise;
}

class HomeLayoutRecentCompletion {
  const HomeLayoutRecentCompletion({
    this.child,
    this.classroom,
    this.classroomExerciseId,
    this.classroomExerciseSubmissionId,
    this.classroomId,
    this.correctNumber,
    this.exercise,
    this.gradedDt,
    this.scorePercentage,
    this.submissionStatus,
    this.submittedDt,
    this.totalQuestions,
  });

  final StudentProfile? child;
  final ClassroomModel? classroom;
  final int? classroomExerciseId;
  final int? classroomExerciseSubmissionId;
  final int? classroomId;
  final int? correctNumber;
  final ClassroomExercise? exercise;
  final String? gradedDt;
  final int? scorePercentage;
  final String? submissionStatus;
  final String? submittedDt;
  final int? totalQuestions;
}
