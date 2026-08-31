import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/mappers/classroom_exercise_mapper.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/classroom/data/mappers/classroom_mapper.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/mappers/profile_mapper.dart';
import 'package:numi/features/profile/domain/models/profile.dart';

class HomeLayoutResponseDto {
  const HomeLayoutResponseDto({
    required this.mstatus,
    this.home,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final HomeLayoutDto? home;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory HomeLayoutResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final homeValue = json['home'] ?? _nestedValue(data, 'home') ?? data;
    return HomeLayoutResponseDto(
      mstatus: _requiredIntFromJson(json['mstatus']),
      home: _objectFromJson(homeValue, HomeLayoutDto.fromJson),
      status: _stringFromJson(json['status']),
      mmessage: _stringFromJson(json['mmessage']),
      debug: _stringFromJson(json['debug']),
    );
  }
}

class HomeLayoutDto {
  const HomeLayoutDto({
    this.role,
    this.profile,
    this.parent,
    this.student,
    this.teacher,
    this.rooms = const <HomeLayoutClassroomDto>[],
    this.subProfiles = const <StudentProfile>[],
    this.tasks = const <HomeLayoutTaskDto>[],
    this.messages = const <HomeLayoutMessageDto>[],
    this.quizzes = const <HomeLayoutQuizDto>[],
  });

  final String? role;
  final StudentProfile? profile;
  final ParentHomeLayoutDto? parent;
  final StudentHomeLayoutDto? student;
  final TeacherHomeLayoutDto? teacher;
  final List<HomeLayoutClassroomDto> rooms;
  final List<StudentProfile> subProfiles;
  final List<HomeLayoutTaskDto> tasks;
  final List<HomeLayoutMessageDto> messages;
  final List<HomeLayoutQuizDto> quizzes;

  factory HomeLayoutDto.fromJson(Map<String, dynamic> json) {
    final rooms = _listFromJson(json['rooms'], HomeLayoutClassroomDto.fromJson);
    final subProfiles = _listFromJson(
      json['sub_profiles'],
      _studentProfileFromJson,
    );
    final tasks = _listFromJson(json['tasks'], HomeLayoutTaskDto.fromJson);
    final parent = _objectFromJson(
      json['parent'],
      ParentHomeLayoutDto.fromJson,
    );
    final student = _objectFromJson(
      json['student'],
      StudentHomeLayoutDto.fromJson,
    );
    final teacher = _objectFromJson(
      json['teacher'],
      TeacherHomeLayoutDto.fromJson,
    );
    return HomeLayoutDto(
      role: _stringFromJson(json['role']),
      profile: _objectFromJson(json['profile'], _studentProfileFromJson),
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
      messages: _listFromJson(json['messages'], HomeLayoutMessageDto.fromJson),
      quizzes: _listFromJson(json['quizzes'], HomeLayoutQuizDto.fromJson),
    );
  }
}

class HomeLayoutMessageDto {
  const HomeLayoutMessageDto({
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

  factory HomeLayoutMessageDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutMessageDto(
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
        _studentProfileFromJson,
      ),
      classroom: _objectFromJson(json['classroom'], _classroomFromJson),
    );
  }
}

class HomeLayoutQuizDto {
  const HomeLayoutQuizDto({
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

  factory HomeLayoutQuizDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutQuizDto(
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

class ParentHomeLayoutDto {
  const ParentHomeLayoutDto({
    this.children = const <StudentProfile>[],
    this.classrooms = const <HomeLayoutClassroomDto>[],
    this.pendingExercises = const <HomeLayoutPendingExerciseDto>[],
    this.expiredExercises = const <HomeLayoutPendingExerciseDto>[],
    this.recentCompletions = const <HomeLayoutRecentCompletionDto>[],
  });

  final List<StudentProfile> children;
  final List<HomeLayoutClassroomDto> classrooms;
  final List<HomeLayoutPendingExerciseDto> pendingExercises;
  final List<HomeLayoutPendingExerciseDto> expiredExercises;
  final List<HomeLayoutRecentCompletionDto> recentCompletions;

  factory ParentHomeLayoutDto.fromJson(Map<String, dynamic> json) {
    return ParentHomeLayoutDto(
      children: _listFromJson(json['children'], _studentProfileFromJson),
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroomDto.fromJson,
      ),
      pendingExercises: _listFromJson(
        json['pending_exercises'],
        HomeLayoutPendingExerciseDto.fromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        HomeLayoutPendingExerciseDto.fromJson,
      ),
      recentCompletions: _listFromJson(
        json['recent_completions'],
        HomeLayoutRecentCompletionDto.fromJson,
      ),
    );
  }
}

class StudentHomeLayoutDto {
  const StudentHomeLayoutDto({
    this.classrooms = const <HomeLayoutClassroomDto>[],
    this.pendingExercises = const <HomeLayoutPendingExerciseDto>[],
    this.expiredExercises = const <HomeLayoutPendingExerciseDto>[],
    this.recentCompletions = const <HomeLayoutRecentCompletionDto>[],
  });

  final List<HomeLayoutClassroomDto> classrooms;
  final List<HomeLayoutPendingExerciseDto> pendingExercises;
  final List<HomeLayoutPendingExerciseDto> expiredExercises;
  final List<HomeLayoutRecentCompletionDto> recentCompletions;

  factory StudentHomeLayoutDto.fromJson(Map<String, dynamic> json) {
    return StudentHomeLayoutDto(
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroomDto.fromJson,
      ),
      pendingExercises: _listFromJson(
        json['pending_exercises'],
        HomeLayoutPendingExerciseDto.fromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        HomeLayoutPendingExerciseDto.fromJson,
      ),
      recentCompletions: _listFromJson(
        json['recent_completions'],
        HomeLayoutRecentCompletionDto.fromJson,
      ),
    );
  }
}

class TeacherHomeLayoutDto {
  const TeacherHomeLayoutDto({
    this.classrooms = const <HomeLayoutClassroomDto>[],
    this.assignedExercises = const <ClassroomExercise>[],
    this.expiredExercises = const <ClassroomExercise>[],
  });

  final List<HomeLayoutClassroomDto> classrooms;
  final List<ClassroomExercise> assignedExercises;
  final List<ClassroomExercise> expiredExercises;

  factory TeacherHomeLayoutDto.fromJson(Map<String, dynamic> json) {
    return TeacherHomeLayoutDto(
      classrooms: _listFromJson(
        json['classrooms'],
        HomeLayoutClassroomDto.fromJson,
      ),
      assignedExercises: _listFromJson(
        json['assigned_exercises'],
        _classroomExerciseFromJson,
      ),
      expiredExercises: _listFromJson(
        json['expired_exercises'],
        _classroomExerciseFromJson,
      ),
    );
  }
}

class HomeLayoutTaskDto {
  const HomeLayoutTaskDto({
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
  final HomeLayoutTaskSubmissionDto? submission;

  factory HomeLayoutTaskDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutTaskDto(
      taskType: _stringFromJson(json['task_type']),
      child: _objectFromJson(json['child'], _studentProfileFromJson),
      classroom: _objectFromJson(json['classroom'], _classroomFromJson),
      exercise: _exerciseFromJson(json['exercise']),
      submission: _objectFromJson(
        json['submission'],
        HomeLayoutTaskSubmissionDto.fromJson,
      ),
    );
  }

  String get normalizedType => taskType?.trim().toUpperCase() ?? '';

  bool get isPending => normalizedType == 'PENDING';

  bool get isCompleted => normalizedType == 'COMPLETED';

  bool get isAssigned => normalizedType == 'ASSIGNED';

  bool get isExpired => normalizedType == 'EXPIRED';
}

class HomeLayoutTaskSubmissionDto {
  const HomeLayoutTaskSubmissionDto({
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

  factory HomeLayoutTaskSubmissionDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutTaskSubmissionDto(
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

class HomeLayoutClassroomDto {
  const HomeLayoutClassroomDto({
    required this.classroom,
    this.memberProfileId,
    this.myRole,
  });

  final ClassroomModel classroom;
  final int? memberProfileId;
  final String? myRole;

  factory HomeLayoutClassroomDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutClassroomDto(
      classroom: _classroomFromJson(json),
      memberProfileId: _intFromJson(json['member_profile_id']),
      myRole: _stringFromJson(json['my_role']),
    );
  }
}

class HomeLayoutPendingExerciseDto {
  const HomeLayoutPendingExerciseDto({
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

  factory HomeLayoutPendingExerciseDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutPendingExerciseDto(
      child: _objectFromJson(json['child'], _studentProfileFromJson),
      classroom: _objectFromJson(json['classroom'], _classroomFromJson),
      classroomExerciseId: _intFromJson(json['classroom_exercise_id']),
      classroomId: _intFromJson(json['classroom_id']),
      exercise: _exerciseFromJson(json['exercise']),
    );
  }
}

class HomeLayoutRecentCompletionDto {
  const HomeLayoutRecentCompletionDto({
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

  factory HomeLayoutRecentCompletionDto.fromJson(Map<String, dynamic> json) {
    return HomeLayoutRecentCompletionDto(
      child: _objectFromJson(json['child'], _studentProfileFromJson),
      classroom: _objectFromJson(json['classroom'], _classroomFromJson),
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

ParentHomeLayoutDto? _parentLayoutFromModernFields({
  required List<StudentProfile> subProfiles,
  required List<HomeLayoutClassroomDto> rooms,
  required List<HomeLayoutTaskDto> tasks,
}) {
  if (subProfiles.isEmpty && rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return ParentHomeLayoutDto(
    children: subProfiles,
    classrooms: rooms,
    pendingExercises: _pendingExercisesFromTasks(tasks, 'PENDING'),
    expiredExercises: _pendingExercisesFromTasks(tasks, 'EXPIRED'),
    recentCompletions: _recentCompletionsFromTasks(tasks),
  );
}

TeacherHomeLayoutDto? _teacherLayoutFromModernFields({
  required List<HomeLayoutClassroomDto> rooms,
  required List<HomeLayoutTaskDto> tasks,
}) {
  if (rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return TeacherHomeLayoutDto(
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

StudentHomeLayoutDto? _studentLayoutFromModernFields({
  required List<HomeLayoutClassroomDto> rooms,
  required List<HomeLayoutTaskDto> tasks,
}) {
  if (rooms.isEmpty && tasks.isEmpty) {
    return null;
  }
  return StudentHomeLayoutDto(
    classrooms: rooms,
    pendingExercises: _pendingExercisesFromTasks(tasks, 'PENDING'),
    expiredExercises: _pendingExercisesFromTasks(tasks, 'EXPIRED'),
    recentCompletions: _recentCompletionsFromTasks(tasks),
  );
}

List<HomeLayoutPendingExerciseDto> _pendingExercisesFromTasks(
  List<HomeLayoutTaskDto> tasks,
  String taskType,
) {
  return tasks
      .where((task) => task.normalizedType == taskType)
      .map(
        (task) => HomeLayoutPendingExerciseDto(
          child: task.child,
          classroom: task.classroom,
          classroomExerciseId: task.exercise?.stableId,
          classroomId: task.classroom?.stableId ?? task.exercise?.classroomId,
          exercise: task.exercise,
        ),
      )
      .toList(growable: false);
}

List<HomeLayoutRecentCompletionDto> _recentCompletionsFromTasks(
  List<HomeLayoutTaskDto> tasks,
) {
  return tasks
      .where((task) => task.isCompleted)
      .map((task) {
        final submission = task.submission;
        return HomeLayoutRecentCompletionDto(
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
    return ClassroomExerciseDto.fromJson(
      _normalizedExerciseJson(json),
    ).toDomain();
  }
  if (value case final Map<Object?, Object?> json) {
    return ClassroomExerciseDto.fromJson(
      _normalizedExerciseJson(Map<String, dynamic>.from(json)),
    ).toDomain();
  }
  return null;
}

ClassroomExercise _classroomExerciseFromJson(Map<String, dynamic> json) {
  return ClassroomExerciseDto.fromJson(json).toDomain();
}

Map<String, dynamic> _normalizedExerciseJson(Map<String, dynamic> json) {
  return <String, dynamic>{
    ...json,
    'num_questions': json['num_questions'] ?? json['total_questions'],
  };
}

StudentProfile _studentProfileFromJson(Map<String, dynamic> json) {
  return StudentProfileDto.fromJson(json).toDomain();
}

ClassroomModel _classroomFromJson(Map<String, dynamic> json) {
  return ClassroomDto.fromJson(json).toDomain();
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
