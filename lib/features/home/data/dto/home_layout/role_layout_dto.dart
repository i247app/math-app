part of '../home_layout_models.dart';

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
