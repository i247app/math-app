part of '../home_layout_api_models.dart';

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
