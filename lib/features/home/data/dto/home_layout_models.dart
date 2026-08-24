import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';

class HomeLayoutResponse {
  const HomeLayoutResponse({
    required this.mstatus,
    this.home,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final HomeLayout? home;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory HomeLayoutResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final homeValue = json['home'] ?? _nestedValue(data, 'home') ?? data;
    return HomeLayoutResponse(
      mstatus: _requiredIntFromJson(json['mstatus']),
      home: _objectFromJson(homeValue, HomeLayout.fromJson),
      status: _stringFromJson(json['status']),
      mmessage: _stringFromJson(json['mmessage']),
      debug: _stringFromJson(json['debug']),
    );
  }
}

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

  factory HomeLayout.fromJson(Map<String, dynamic> json) {
    final rooms = _listFromJson(json['rooms'], HomeLayoutClassroom.fromJson);
    final subProfiles = _listFromJson(
      json['sub_profiles'],
      StudentProfile.fromJson,
    );
    final tasks = _listFromJson(json['tasks'], HomeLayoutTask.fromJson);
    final parent = _objectFromJson(json['parent'], ParentHomeLayout.fromJson);
    final student = _objectFromJson(
      json['student'],
      StudentHomeLayout.fromJson,
    );
    final teacher = _objectFromJson(
      json['teacher'],
      TeacherHomeLayout.fromJson,
    );
    return HomeLayout(
      role: _stringFromJson(json['role']),
      profile: _objectFromJson(json['profile'], StudentProfile.fromJson),
      parent:
          parent ??
          _parentLayoutFromModernFields(
            subProfiles: subProfiles,
            rooms: rooms,
            tasks: tasks,
          ),
      student:
          student ?? _studentLayoutFromModernFields(rooms: rooms, tasks: tasks),
      teacher:
          teacher ?? _teacherLayoutFromModernFields(rooms: rooms, tasks: tasks),
      rooms: rooms,
      subProfiles: subProfiles,
      tasks: tasks,
      messages: _listFromJson(json['messages'], HomeLayoutMessage.fromJson),
      quizzes: _listFromJson(json['quizzes'], HomeLayoutQuiz.fromJson),
    );
  }
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

  factory HomeLayoutMessage.fromJson(Map<String, dynamic> json) {
    return HomeLayoutMessage(
      id: _intFromJson(json['id'] ?? json['message_id']),
      title: _stringFromJson(json['title']),
      message: _stringFromJson(
        json['message'] ?? json['content'] ?? json['body'] ?? json['text'],
      ),
      createdAt: _stringFromJson(
        json['created_at'] ?? json['create_dt'] ?? json['sent_dt'],
      ),
      sender: _objectFromJson(
        json['sender'] ?? json['profile'],
        StudentProfile.fromJson,
      ),
      classroom: _objectFromJson(json['classroom'], ClassroomModel.fromJson),
    );
  }
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

  factory HomeLayoutQuiz.fromJson(Map<String, dynamic> json) {
    return HomeLayoutQuiz(
      quizId: _intFromJson(json['quiz_id']),
      createDt: _stringFromJson(json['create_dt']),
      purpose: _stringFromJson(json['purpose']),
      quizStatus: _stringFromJson(json['quiz_status']),
      scorePercentage: _intFromJson(json['score_percentage']),
      shortText: _stringFromJson(json['short_text']),
      title: _stringFromJson(json['title']),
      totalQuestions: _intFromJson(json['total_questions']),
      typeOfQuiz: _stringFromJson(json['type_of_quiz']),
      correctNumber: _intFromJson(json['correct_number']),
    );
  }
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

  factory ParentHomeLayout.fromJson(Map<String, dynamic> json) {
    return ParentHomeLayout(
      children: _listFromJson(json['children'], StudentProfile.fromJson),
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroom.fromJson,
      ),
      pendingExercises: _listFromJson(
        json['pending_exercises'],
        HomeLayoutPendingExercise.fromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        HomeLayoutPendingExercise.fromJson,
      ),
      recentCompletions: _listFromJson(
        json['recent_completions'],
        HomeLayoutRecentCompletion.fromJson,
      ),
    );
  }
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

  factory StudentHomeLayout.fromJson(Map<String, dynamic> json) {
    return StudentHomeLayout(
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroom.fromJson,
      ),
      pendingExercises: _listFromJson(
        json['pending_exercises'],
        HomeLayoutPendingExercise.fromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        HomeLayoutPendingExercise.fromJson,
      ),
      recentCompletions: _listFromJson(
        json['recent_completions'],
        HomeLayoutRecentCompletion.fromJson,
      ),
    );
  }
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

  factory TeacherHomeLayout.fromJson(Map<String, dynamic> json) {
    return TeacherHomeLayout(
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroom.fromJson,
      ),
      assignedExercises: _listFromJson(
        json['assigned_exercises'],
        ClassroomExercise.fromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        ClassroomExercise.fromJson,
      ),
    );
  }
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

  factory HomeLayoutTask.fromJson(Map<String, dynamic> json) {
    return HomeLayoutTask(
      taskType: _stringFromJson(json['task_type']),
      child: _objectFromJson(json['child'], StudentProfile.fromJson),
      classroom: _objectFromJson(json['classroom'], ClassroomModel.fromJson),
      exercise: _exerciseFromJson(json['exercise']),
      submission: _objectFromJson(
        json['submission'],
        HomeLayoutTaskSubmission.fromJson,
      ),
    );
  }

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

  factory HomeLayoutTaskSubmission.fromJson(Map<String, dynamic> json) {
    return HomeLayoutTaskSubmission(
      classroomExerciseSubmissionId: _intFromJson(
        json['classroom_exercise_submission_id'],
      ),
      correctNumber: _intFromJson(json['correct_number']),
      gradedDt: _stringFromJson(json['graded_dt']),
      scorePercentage: _intFromJson(json['score_percentage']),
      submissionStatus: _stringFromJson(json['submission_status']),
      submittedDt: _stringFromJson(json['submitted_dt']),
      totalQuestions: _intFromJson(json['total_questions']),
    );
  }
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

  factory HomeLayoutClassroom.fromJson(Map<String, dynamic> json) {
    return HomeLayoutClassroom(
      classroom: ClassroomModel.fromJson(json),
      memberProfileId: _intFromJson(json['member_profile_id']),
      myRole: _stringFromJson(json['my_role']),
    );
  }
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

  factory HomeLayoutPendingExercise.fromJson(Map<String, dynamic> json) {
    return HomeLayoutPendingExercise(
      child: _objectFromJson(json['child'], StudentProfile.fromJson),
      classroom: _objectFromJson(json['classroom'], ClassroomModel.fromJson),
      classroomExerciseId: _intFromJson(json['classroom_exercise_id']),
      classroomId: _intFromJson(json['classroom_id']),
      exercise: _exerciseFromJson(json['exercise']),
    );
  }
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

  factory HomeLayoutRecentCompletion.fromJson(Map<String, dynamic> json) {
    return HomeLayoutRecentCompletion(
      child: _objectFromJson(json['child'], StudentProfile.fromJson),
      classroom: _objectFromJson(json['classroom'], ClassroomModel.fromJson),
      classroomExerciseId: _intFromJson(json['classroom_exercise_id']),
      classroomExerciseSubmissionId: _intFromJson(
        json['classroom_exercise_submission_id'],
      ),
      classroomId: _intFromJson(json['classroom_id']),
      correctNumber: _intFromJson(json['correct_number']),
      exercise: _exerciseFromJson(json['exercise']),
      gradedDt: _stringFromJson(json['graded_dt']),
      scorePercentage: _intFromJson(json['score_percentage']),
      submissionStatus: _stringFromJson(json['submission_status']),
      submittedDt: _stringFromJson(json['submitted_dt']),
      totalQuestions: _intFromJson(json['total_questions']),
    );
  }
}

ParentHomeLayout? _parentLayoutFromModernFields({
  required List<StudentProfile> subProfiles,
  required List<HomeLayoutClassroom> rooms,
  required List<HomeLayoutTask> tasks,
}) {
  if (subProfiles.isEmpty && rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return ParentHomeLayout(
    children: subProfiles,
    classrooms: rooms,
    pendingExercises: _pendingExercisesFromTasks(tasks, 'PENDING'),
    expiredExercises: _pendingExercisesFromTasks(tasks, 'EXPIRED'),
    recentCompletions: _recentCompletionsFromTasks(tasks),
  );
}

TeacherHomeLayout? _teacherLayoutFromModernFields({
  required List<HomeLayoutClassroom> rooms,
  required List<HomeLayoutTask> tasks,
}) {
  if (rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return TeacherHomeLayout(
    classrooms: rooms,
    assignedExercises: tasks
        .where((task) => task.isAssigned)
        .map((task) => task.exercise)
        .whereType<ClassroomExercise>()
        .toList(growable: false),
    expiredExercises: tasks
        .where((task) => task.isExpired)
        .map((task) => task.exercise)
        .whereType<ClassroomExercise>()
        .toList(growable: false),
  );
}

StudentHomeLayout? _studentLayoutFromModernFields({
  required List<HomeLayoutClassroom> rooms,
  required List<HomeLayoutTask> tasks,
}) {
  if (rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return StudentHomeLayout(
    classrooms: rooms,
    pendingExercises: _pendingExercisesFromTasks(tasks, 'PENDING'),
    expiredExercises: _pendingExercisesFromTasks(tasks, 'EXPIRED'),
    recentCompletions: _recentCompletionsFromTasks(tasks),
  );
}

List<HomeLayoutPendingExercise> _pendingExercisesFromTasks(
  List<HomeLayoutTask> tasks,
  String taskType,
) {
  return tasks
      .where((task) => task.normalizedType == taskType)
      .map(
        (task) => HomeLayoutPendingExercise(
          child: task.child,
          classroom: task.classroom,
          classroomExerciseId: task.exercise?.stableId,
          classroomId: task.classroom?.stableId ?? task.exercise?.classroomId,
          exercise: task.exercise,
        ),
      )
      .toList(growable: false);
}

List<HomeLayoutRecentCompletion> _recentCompletionsFromTasks(
  List<HomeLayoutTask> tasks,
) {
  return tasks
      .where((task) => task.isCompleted)
      .map((task) {
        final submission = task.submission;
        return HomeLayoutRecentCompletion(
          child: task.child,
          classroom: task.classroom,
          classroomExerciseId: task.exercise?.stableId,
          classroomExerciseSubmissionId:
              submission?.classroomExerciseSubmissionId,
          classroomId: task.classroom?.stableId ?? task.exercise?.classroomId,
          correctNumber: submission?.correctNumber,
          exercise: task.exercise,
          gradedDt: submission?.gradedDt,
          scorePercentage: submission?.scorePercentage,
          submissionStatus: submission?.submissionStatus,
          submittedDt: submission?.submittedDt,
          totalQuestions: submission?.totalQuestions,
        );
      })
      .toList(growable: false);
}

Object? _nestedValue(Object? value, String key) {
  if (value case final Map<String, dynamic> json) {
    return json[key];
  }
  if (value case final Map<Object?, Object?> json) {
    return json[key];
  }
  return null;
}

ClassroomExercise? _exerciseFromJson(Object? value) {
  if (value case final Map<String, dynamic> json) {
    return ClassroomExercise.fromJson(_normalizedExerciseJson(json));
  }
  if (value case final Map<Object?, Object?> json) {
    return ClassroomExercise.fromJson(
      _normalizedExerciseJson(Map<String, dynamic>.from(json)),
    );
  }
  return null;
}

Map<String, dynamic> _normalizedExerciseJson(Map<String, dynamic> json) {
  return <String, dynamic>{
    ...json,
    'num_questions': json['num_questions'] ?? json['total_questions'],
  };
}

T? _objectFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value case final Map<String, dynamic> json) {
    return fromJson(json);
  }
  if (value case final Map<Object?, Object?> json) {
    return fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}

List<T> _listFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }
  return value
      .map((item) => _objectFromJson(item, fromJson))
      .whereType<T>()
      .toList(growable: false);
}

int _requiredIntFromJson(Object? value) => _intFromJson(value) ?? 0;

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

String? _stringFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}
