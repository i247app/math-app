import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_session_data_cleaner.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/student_class_search_filter_cache.dart';
import 'package:numi/features/classroom/data/teacher_classroom_lookup_cache.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/teacher_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_history_classroom_exercise_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/parent_home_snapshot.dart';
import 'package:numi/features/home/data/teacher_home_snapshot.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/notifications/data/notification_cache.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/models/notification.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';
import 'package:numi/features/settings/data/settings_profile_form_service.dart';

const _cleaner = AppSessionDataCleaner();
const _examQuestions = [
  ExamQuestion(questionName: '1 + 1', questionNumber: 1, answers: []),
];
const _exerciseQuestions = [ClassroomExerciseQuestion(questionNumber: 1)];

void main() {
  setUp(_cleaner.clear);
  tearDown(_cleaner.clear);

  test(
    'clears all account caches, details, freshness and home snapshots',
    () async {
      final requests = _Requests();
      final pending = requests.load();
      requests.complete('old');
      await pending;
      final home = HomeProfileCache.instance;
      home.putParent(
        ParentHomeSnapshot(
          profileId: 7,
          homeLayout: const HomeLayout(),
          completedAssessments: const [],
          cachedAt: DateTime.now(),
        ),
      );
      home.putTeacher(
        TeacherHomeSnapshot(
          profileId: 7,
          layoutClassrooms: const [],
          recentAssignments: const [],
          cachedAt: DateTime.now(),
        ),
      );
      _expectCached('old');
      expect(home.getParent(7), isNotNull);
      expect(home.getTeacher(7), isNotNull);
      final oldScope = SessionCacheScope.current;

      _cleaner.clear();

      _expectEmpty();
      expect(home.getParent(7), isNull);
      expect(home.getTeacher(7), isNull);
      expect(oldScope.isCurrent, isFalse);
      expect(SessionCacheScope.current.isCurrent, isTrue);
    },
  );

  for (final oldCompletesFirst in [true, false]) {
    test('old responses cannot refill or overwrite new-session caches '
        '(old completes first: $oldCompletesFirst)', () async {
      final oldRequests = _Requests();
      final oldPending = oldRequests.load();
      // History first loads joined classrooms before requesting exercises.
      await Future<void>.delayed(Duration.zero);
      _cleaner.clear();
      final newRequests = _Requests();
      final newPending = newRequests.load();
      if (oldCompletesFirst) {
        oldRequests.complete('old');
        await oldPending;
        _expectEmpty();
        // The old request's completion must not detach the new pending entry.
        expect(
          ExamCache.loadList(
            service: _Exams(Completer()),
            userId: 7,
            profileId: 7,
          ),
          same(newRequests.examListRequest),
        );
      }
      newRequests.complete('new');
      await newPending;
      _expectCached('new');
      if (!oldCompletesFirst) {
        oldRequests.complete('old');
        await oldPending;
        _expectCached('new');
      }
    });
  }

  test(
    'home layout requests are detached without removing a newer request',
    () async {
      final old = Completer<HomeLayout>();
      final fresh = Completer<HomeLayout>();
      final home = HomeProfileCache.instance;
      final oldPending = home.loadLayout(
        profileId: 7,
        loader: () => old.future,
      );
      _cleaner.clear();
      final newPending = home.loadLayout(
        profileId: 7,
        loader: () => fresh.future,
      );
      old.complete(const HomeLayout(role: 'old'));
      await oldPending;
      expect(
        home.loadLayout(
          profileId: 7,
          loader: () => throw StateError('duplicate'),
        ),
        same(newPending),
      );
      fresh.complete(const HomeLayout(role: 'new'));
      expect((await newPending).role, 'new');
    },
  );

  test('does not retry empty exam details after the session ends', () async {
    final response = Completer<GeneratedExam>();
    var calls = 0;
    final pending = ExamCache.loadDetail(
      cacheKey: 42,
      serviceExamId: 42,
      loadDetail: (_) {
        calls++;
        return response.future;
      },
    );
    _cleaner.clear();
    response.complete(const GeneratedExam(examId: 42, questions: []));
    await pending;
    expect(calls, 1);
    expect(ExamCache.peekDetail(42), isNull);
  });
}

void _expectEmpty() {
  expect(ExamCache.peekList(userId: 7, profileId: 7), isNull);
  expect(ExamCache.peekDetail(42), isNull);
  expect(ExamCache.isListFresh(userId: 7, profileId: 7), isFalse);
  expect(ExamCache.isDetailFresh(42), isFalse);
  expect(
    StudentClassroomExerciseCache.peekList(classroomId: 9, profileId: 7),
    isNull,
  );
  expect(
    StudentClassroomExerciseCache.peekFullDetail(exerciseId: 42, profileId: 7),
    isNull,
  );
  expect(
    TeacherClassroomExerciseCache.peekList(
      classroomId: 9,
      profileId: 7,
      purpose: classroomExercisePurposeHomework,
    ),
    isNull,
  );
  expect(
    TeacherClassroomExerciseCache.peekDetail(exerciseId: 42, profileId: 7),
    isNull,
  );
  expect(
    ExamHistoryClassroomExerciseCache.peekSubmittedClassroomExercise(7),
    isNull,
  );
  expect(ExamHistoryClassroomExerciseCache.isFresh(7), isFalse);
  expect(TeacherClassroomLookupCache.shared.get(7), isNull);
  expect(StudentClassSearchFilterCache.shared.get(7), isNull);
  expect(ProfileOptionsCache.instance.readFresh(userId: 7), isNull);
  expect(NotificationCache.peek(), isNull);
}

void _expectCached(String title) {
  expect(ExamCache.peekList(userId: 7, profileId: 7)!.single.title, title);
  expect(ExamCache.peekDetail(42)!.title, title);
  expect(ExamCache.isListFresh(userId: 7, profileId: 7), isTrue);
  expect(ExamCache.isDetailFresh(42), isTrue);
  expect(
    StudentClassroomExerciseCache.peekList(
      classroomId: 9,
      profileId: 7,
    )!.single.title,
    title,
  );
  expect(
    StudentClassroomExerciseCache.peekFullDetail(
      exerciseId: 42,
      profileId: 7,
    )!.title,
    title,
  );
  expect(
    TeacherClassroomExerciseCache.peekList(
      classroomId: 9,
      profileId: 7,
      purpose: classroomExercisePurposeHomework,
    )!.single.title,
    title,
  );
  expect(
    TeacherClassroomExerciseCache.peekDetail(
      exerciseId: 42,
      profileId: 7,
    )!.title,
    title,
  );
  expect(
    ExamHistoryClassroomExerciseCache.peekSubmittedClassroomExercise(
      7,
    )!.single.title,
    title,
  );
  expect(ExamHistoryClassroomExerciseCache.isFresh(7), isTrue);
  final id = title == 'old' ? 1 : 2;
  expect(
    TeacherClassroomLookupCache.shared.get(7)!.schools.single.schoolId,
    id,
  );
  expect(
    StudentClassSearchFilterCache.shared.get(7)!.schools.single.schoolId,
    id,
  );
  expect(
    ProfileOptionsCache.instance.readFresh(userId: 7)!.schools.single.schoolId,
    id,
  );
  expect(NotificationCache.peek()!.single.title, title);
}

class _Requests {
  final examList = Completer<List<GeneratedExam>>();
  final examDetail = Completer<GeneratedExam>();
  final exerciseList = Completer<List<ClassroomExercise>>();
  final exerciseDetail = Completer<ClassroomExercise?>();
  final schools = Completer<List<SchoolModel>>();
  final notifications = Completer<List<NotificationModel>>();
  late Future<List<GeneratedExam>> examListRequest;

  Future<void> load() async {
    final exercises = _Exercises(exerciseList, exerciseDetail);
    final schoolService = _Schools(schools);
    final grades = _Grades();
    final profiles = _Profiles();
    examListRequest = ExamCache.loadList(
      service: _Exams(examList),
      userId: 7,
      profileId: 7,
    );
    await Future.wait<Object?>([
      examListRequest,
      ExamCache.loadDetail(
        loadDetail: (_) => examDetail.future,
        cacheKey: 42,
        serviceExamId: 42,
      ),
      StudentClassroomExerciseCache.loadList(
        service: exercises,
        classroomId: 9,
        profileId: 7,
      ),
      StudentClassroomExerciseCache.loadDetail(
        service: exercises,
        exerciseId: 42,
        profileId: 7,
      ),
      TeacherClassroomExerciseCache.loadList(
        service: exercises,
        classroomId: 9,
        profileId: 7,
        purpose: classroomExercisePurposeHomework,
      ),
      TeacherClassroomExerciseCache.loadDetail(
        service: exercises,
        exerciseId: 42,
        profileId: 7,
      ),
      ExamHistoryClassroomExerciseCache.loadSubmittedClassroomExercise(
        classroomService: _Classrooms(),
        assignmentService: exercises,
        profileId: 7,
      ),
      TeacherClassroomLookupCache.shared.load(
        userId: 7,
        gradeService: grades,
        profileService: profiles,
        schoolService: schoolService,
      ),
      StudentClassSearchFilterCache.shared.load(
        userId: 7,
        gradeService: grades,
        schoolService: schoolService,
      ),
      SettingsProfileFormService(
        profileService: profiles,
        gradeService: grades,
        schoolService: schoolService,
      ).loadOptions(7),
      NotificationCache.load(service: _Notifications(notifications)),
    ]);
  }

  void complete(String title) {
    final exam = GeneratedExam(
      examId: 42,
      title: title,
      questions: _examQuestions,
    );
    final exercise = ClassroomExercise(
      classroomExerciseId: 42,
      classroomId: 9,
      title: title,
      questions: _exerciseQuestions,
    );
    examList.complete([exam]);
    examDetail.complete(exam);
    exerciseList.complete([exercise]);
    exerciseDetail.complete(exercise);
    schools.complete([SchoolModel(schoolId: title == 'old' ? 1 : 2)]);
    notifications.complete([NotificationModel(title: title)]);
  }
}

class _Exams implements ExamService {
  _Exams(this.result);
  final Completer<List<GeneratedExam>> result;
  @override
  Future<List<GeneratedExam>> listExams({int? userId, int? profileId}) =>
      result.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Exercises implements ClassroomExerciseService {
  _Exercises(this.list, this.detail);
  final Completer<List<ClassroomExercise>> list;
  final Completer<ClassroomExercise?> detail;
  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) => list.future;
  @override
  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  }) => detail.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Classrooms implements ClassroomService {
  @override
  Future<List<ClassroomModel>> listMyJoinedClassrooms({
    required int profileId,
  }) async => const [ClassroomModel(classroomId: 9)];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Schools implements SchoolService {
  _Schools(this.result);
  final Completer<List<SchoolModel>> result;
  @override
  Future<List<SchoolModel>> listSchools() => result.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Grades implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profiles implements ProfileService {
  @override
  Future<List<ProgramModel>> listPrograms({required int userId}) async =>
      const [];
  @override
  Future<List<SemesterModel>> listSemesters({required int userId}) async =>
      const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notifications implements NotificationListService {
  _Notifications(this.result);
  final Completer<List<NotificationModel>> result;
  @override
  Future<List<NotificationModel>> listNotifications() => result.future;
}
