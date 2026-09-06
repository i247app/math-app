part of '../home_layout_api_models.dart';

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
