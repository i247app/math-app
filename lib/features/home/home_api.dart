import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/network_client.dart';
import 'package:numi_flutter/core/network/profile_models.dart';

class HomeLayoutException implements Exception {
  const HomeLayoutException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class HomeLayoutService {
  Future<HomeLayout> getLayout({required int profileId});
}

class HomeLayoutApi implements HomeLayoutService {
  HomeLayoutApi({
    String? baseUrl,
    NetworkClient? networkClient,
  }) : _networkClient = networkClient ?? NetworkClient(baseUrl: baseUrl);

  final NetworkClient _networkClient;

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    try {
      final json = await _networkClient.postJson(
        '/home/layout',
        <String, dynamic>{'profile_id': profileId},
      );
      final response = HomeLayoutResponse.fromJson(json);
      if (response.mstatus != 200) {
        throw HomeLayoutException(
          response.mmessage ??
              response.debug ??
              response.status ??
              'Request failed.',
          status: response.mstatus,
        );
      }
      final home = response.home;
      if (home == null) {
        throw const HomeLayoutException('Home layout is empty.');
      }
      return home;
    } on NetworkException catch (error) {
      throw HomeLayoutException(error.message, status: error.status);
    }
  }
}

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
    this.quizzes = const <HomeLayoutQuiz>[],
  });

  final String? role;
  final StudentProfile? profile;
  final ParentHomeLayout? parent;
  final List<HomeLayoutQuiz> quizzes;

  factory HomeLayout.fromJson(Map<String, dynamic> json) {
    return HomeLayout(
      role: _stringFromJson(json['role']),
      profile: _objectFromJson(json['profile'], StudentProfile.fromJson),
      parent: _objectFromJson(json['parent'], ParentHomeLayout.fromJson),
      quizzes: _listFromJson(json['quizzes'], HomeLayoutQuiz.fromJson),
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
