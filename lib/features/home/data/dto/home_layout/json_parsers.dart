part of '../home_layout_models.dart';

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
    return _classroomExerciseFromJson(_normalizedExerciseJson(json));
  }
  if (value case final Map<Object?, Object?> json) {
    return _classroomExerciseFromJson(
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

StudentProfile _studentProfileFromJson(Map<String, dynamic> json) {
  return StudentProfile(
    id: _intFromJson(json['id']),
    profileId: _intFromJson(json['profile_id']),
    profileCode: _stringFromJson(json['profile_code']),
    userId: _intFromJson(json['user_id']),
    schoolId: _intFromJson(json['school_id']),
    school: _objectFromJson(json['school'], _schoolFromJson),
    name: _stringFromJson(json['name']),
    avatarKey: _stringFromJson(json['avatar_key']),
    avatarUrl: _stringFromJson(json['avatar_url']),
    dob: _stringFromJson(json['dob']),
    gradeId: _intFromJson(json['grade_id']),
    grade: _objectFromJson(json['grade'], _profileGradeFromJson),
    programId: _intFromJson(json['program_id']),
    program: _objectFromJson(json['program'], _programFromJson),
    semesterId: _intFromJson(json['semester_id']),
    semester: _objectFromJson(json['semester'], _semesterFromJson),
    isDefault: _boolFromJson(json['is_default']) ?? false,
    role: _stringFromJson(json['role']),
    profileStatus: _stringFromJson(json['profile_status']),
    idType: _stringFromJson(json['id_type']),
    studentId: _stringFromJson(json['student_id']),
    teacherId: _stringFromJson(json['teacher_id']),
    createDt: _stringFromJson(json['create_dt']),
    modifyDt: _stringFromJson(json['modify_dt']),
  );
}

ClassroomModel _classroomFromJson(Map<String, dynamic> json) {
  final studentsValue =
      json['students'] ?? json['members'] ?? json['student_profiles'];
  final students = _listFromJson(studentsValue, _classroomStudentFromJson);
  return ClassroomModel(
    id: _intFromJson(json['id']),
    classroomId: _intFromJson(json['classroom_id']),
    profileId: _intFromJson(json['profile_id']),
    name: _stringFromJson(json['name']),
    description: _stringFromJson(json['description']),
    programId: _intFromJson(json['program_id']),
    programIds: _intListFromJson(
      json['program_ids'] ??
          (json['program_id'] == null ? null : <Object?>[json['program_id']]),
    ),
    gradeId: _intFromJson(json['grade_id']),
    schoolId: _intFromJson(json['school_id']),
    classroomCode: _stringFromJson(
      json['classroom_code'] ?? json['invite_code'],
    ),
    owner: _objectFromJson(
      json['owner'] ?? json['teacher'],
      _classroomOwnerFromJson,
    ),
    ownerProfileId: _intFromJson(
      json['owner_profile_id'] ??
          _nestedValue(json['owner'], 'profile_id') ??
          _nestedValue(json['teacher'], 'profile_id'),
    ),
    relationship: _stringFromJson(json['relationship']),
    teacherName: _stringFromJson(
      json['teacher_name'] ??
          json['owner_name'] ??
          _nestedValue(json['owner'], 'name') ??
          _nestedValue(json['teacher'], 'name'),
    ),
    programName: _stringFromJson(
      json['program_name'] ??
          json['program_label'] ??
          _nestedValue(json['program'], 'label') ??
          _nestedValue(json['program'], 'name'),
    ),
    schoolName: _stringFromJson(
      json['school_name'] ?? _nestedValue(json['school'], 'name'),
    ),
    maxMembers: _intFromJson(json['max_members']),
    memberCount: _intFromJson(json['member_count'] ?? json['members_count']),
    studentCount:
        _intFromJson(json['student_count'] ?? json['students_count']) ??
        (students.isEmpty ? null : students.length),
    teacherCount: _intFromJson(json['teacher_count']),
    pendingRequestCount: _intFromJson(
      json['pending_request_count'] ??
          json['pending_requests_count'] ??
          json['join_request_count'] ??
          json['join_requests_count'],
    ),
    students: students,
    imageUrl: _stringFromJson(json['image_url']),
    avatarUrl: _stringFromJson(json['avatar_url']),
    fileUrl: _stringFromJson(json['file_url']),
    createDt: _stringFromJson(json['create_dt']),
    modifyDt: _stringFromJson(json['modify_dt']),
  );
}

ClassroomOwner _classroomOwnerFromJson(Map<String, dynamic> json) =>
    ClassroomOwner(
      profileId: _intFromJson(json['profile_id']),
      name: _stringFromJson(json['name']),
      role: _stringFromJson(json['role']),
      avatarUrl: _stringFromJson(json['avatar_url']),
      imageUrl: _stringFromJson(json['image_url']),
      fileUrl: _stringFromJson(json['file_url']),
    );

ClassroomStudent _classroomStudentFromJson(Map<String, dynamic> json) =>
    ClassroomStudent(
      id: _intFromJson(json['id'] ?? json['member_id']),
      profileId: _intFromJson(json['profile_id'] ?? json['student_profile_id']),
      name: _stringFromJson(json['name'] ?? json['student_name']),
      avatarKey: _stringFromJson(json['avatar_key']),
      avatarUrl: _stringFromJson(json['avatar_url']),
      joinedAt: _stringFromJson(json['joined_at'] ?? json['joined_dt']),
      status: _stringFromJson(json['status'] ?? json['member_status']),
      role: _stringFromJson(json['role'] ?? json['member_role']),
    );

ClassroomExercise _classroomExerciseFromJson(
  Map<String, dynamic> json,
) => ClassroomExercise(
  id: _intFromJson(json['id']),
  exerciseId: _intFromJson(json['exercise_id'] ?? json['assignment_id']),
  classroomExerciseId: _intFromJson(
    json['classroom_exercise_id'] ?? json['assignment_id'],
  ),
  classroomId: _intFromJson(json['classroom_id']),
  profileId: _intFromJson(json['profile_id'] ?? json['creator_profile_id']),
  programId: _intFromJson(json['program_id']),
  title: _stringFromJson(json['title']),
  numQuestions: _intFromJson(json['num_questions'] ?? json['total_questions']),
  chapterName: _stringFromJson(json['chapter_name']),
  lessonName: _stringFromJson(json['lesson_name']),
  description: _stringFromJson(
    json['description'] ??
        json['assignment_description'] ??
        json['exercise_description'] ??
        json['short_text'],
  ),
  shortText: _stringFromJson(json['short_text'] ?? json['short_description']),
  visibility: _stringFromJson(json['visibility']),
  purpose: _stringFromJson(json['purpose'] ?? json['type']),
  status: _stringFromJson(json['status'] ?? json['exercise_status']),
  submissionStatus: _stringFromJson(json['submission_status']),
  startDate: _stringFromJson(json['start_date']),
  endDate: _stringFromJson(json['end_date']),
  createDt: _stringFromJson(json['create_dt']),
  modifyDt: _stringFromJson(json['modify_dt']),
  metadata: json['metadata'] is Map
      ? Map<String, dynamic>.from(json['metadata'] as Map)
      : null,
  questions: _listFromJson(
    json['questions'] ?? json['exercise_questions'] ?? json['items'],
    _classroomExerciseQuestionFromJson,
  ),
);

ClassroomExerciseQuestion _classroomExerciseQuestionFromJson(
  Map<String, dynamic> json,
) => ClassroomExerciseQuestion(
  id: _intFromJson(json['id']),
  questionId: _intFromJson(json['question_id'] ?? json['id']),
  questionNumber: _intFromJson(json['question_number'] ?? json['number']),
  content: _stringFromJson(
    json['content'] ??
        json['question_content'] ??
        json['question_text'] ??
        json['question_name'] ??
        json['text'],
  ),
  prompt: _stringFromJson(json['prompt']),
  question: _stringFromJson(json['question']),
  correctAnswer: _stringFromJson(
    json['correct_answer'] ?? json['right_answer'] ?? json['answer'],
  ),
  answers: _stringListFromJson(
    json['answers'] ?? json['options'] ?? json['choices'],
  ),
);

ProfileGrade _profileGradeFromJson(Map<String, dynamic> json) => ProfileGrade(
  id: _intFromJson(json['id']),
  gradeId: _intFromJson(json['grade_id']),
  label: _stringFromJson(json['label']),
  description: _stringFromJson(json['description']),
  displayOrder: _intFromJson(json['display_order']),
  imageUrl: _stringFromJson(json['image_url']),
);

SchoolModel _schoolFromJson(Map<String, dynamic> json) => SchoolModel(
  id: _intFromJson(json['id']),
  schoolId: _intFromJson(json['school_id']),
  name: _stringFromJson(json['name']),
  imageUrl: _stringFromJson(json['image_url']),
  createDt: _stringFromJson(json['create_dt']),
  modifyDt: _stringFromJson(json['modify_dt']),
);

ProgramModel _programFromJson(Map<String, dynamic> json) => ProgramModel(
  id: _intFromJson(json['id']),
  programId: _intFromJson(json['program_id']),
  label: _stringFromJson(json['label'] ?? json['name']),
  description: _stringFromJson(json['description']),
  displayOrder: _intFromJson(json['display_order']),
  imageUrl: _stringFromJson(json['image_url']),
  createDt: _stringFromJson(json['create_dt']),
  modifyDt: _stringFromJson(json['modify_dt']),
);

SemesterModel _semesterFromJson(Map<String, dynamic> json) => SemesterModel(
  id: _intFromJson(json['id']),
  semesterId: _intFromJson(json['semester_id']),
  name: _stringFromJson(json['name']),
  description: _stringFromJson(json['description']),
  displayOrder: _intFromJson(json['display_order']),
  imageUrl: _stringFromJson(json['image_url']),
  createDt: _stringFromJson(json['create_dt']),
  modifyDt: _stringFromJson(json['modify_dt']),
);

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

bool? _boolFromJson(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' => true,
    'false' || '0' => false,
    _ => null,
  };
}

List<int> _intListFromJson(Object? value) {
  if (value is! List) {
    return const <int>[];
  }
  return value.map(_intFromJson).whereType<int>().toList(growable: false);
}

List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((item) {
        if (item is Map) {
          return _stringFromJson(
            item['content'] ?? item['value'] ?? item['label'],
          );
        }
        return _stringFromJson(item);
      })
      .whereType<String>()
      .toList(growable: false);
}

String? _stringFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}
