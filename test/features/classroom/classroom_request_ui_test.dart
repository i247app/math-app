import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/teacher_classroom_lookup_cache.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom/screens/student_class_detail_screen.dart';
import 'package:numi/features/classroom/screens/teacher_create_class_screen.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_empty_panel.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_learning_category_section.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_section.dart';
import 'package:numi/features/classroom/widgets/teacher_create/teacher_create_class_form.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';

import 'package:numi/features/classroom/screens/parent_room_tab.dart';
import 'package:numi/features/classroom/widgets/student_class_search_content.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_class_card.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_search_field.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/models/home_layout.dart';

void main() {
  late LingoProvider lingo;
  late ClassroomCubit cubit;
  late _Classrooms classrooms;
  setUp(() {
    lingo = LingoProvider();
    classrooms = _Classrooms();
    cubit = ClassroomCubit(classroomService: classrooms);
    TeacherClassroomLookupCache.shared.clear();
    HomeProfileCache.instance.invalidateAll();
  });
  tearDown(() async {
    await cubit.close();
    lingo.dispose();
    TeacherClassroomLookupCache.shared.clear();
    HomeProfileCache.instance.invalidateAll();
  });
  Widget app(Widget screen) => BlocProvider.value(
    value: cubit,
    child: LingoScope(
      lingo: lingo,
      child: MaterialApp(theme: AppTheme.light(), home: screen),
    ),
  );

  testWidgets(
    'exercise error displays retry without empty state or a zero count',
    (tester) async {
      final service = _Exercises();
      await tester.pumpWidget(
        app(
          StudentClassDetailScreen(
            profileId: 1,
            classroomId: 10,
            exerciseService: service,
          ),
        ),
      );
      service.requests[0].completeError(
        const ClassroomExerciseException('Exercise endpoint failed'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Exercise endpoint failed'), findsOneWidget);
      expect(find.byType(StudentClassEmptyPanel), findsNothing);
      expect(
        tester
            .widget<StudentClassLearningCategorySection>(
              find.byType(StudentClassLearningCategorySection),
            )
            .classroomExerciseCount,
        isNull,
      );
      final retry = tester.widget<AppRetryPanel>(
        find.byKey(const ValueKey('student-class-exercises-error')),
      );
      retry.onRetry();
      await tester.pump();
      service.requests[1].complete([]);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('student-class-exercises-error')),
        findsNothing,
      );
      expect(find.byType(StudentClassEmptyPanel), findsOneWidget);
      expect(
        tester
            .widget<StudentClassLearningCategorySection>(
              find.byType(StudentClassLearningCategorySection),
            )
            .classroomExerciseCount,
        0,
      );
    },
  );

  testWidgets(
    'unexpected refresh error shows localized retry while retaining exercises',
    (tester) async {
      final service = _Exercises();
      await tester.pumpWidget(
        app(
          StudentClassDetailScreen(
            profileId: 1,
            classroomId: 10,
            exerciseService: service,
          ),
        ),
      );
      const exercise = ClassroomExercise(id: 20, title: 'Homework');
      service.requests[0].complete([exercise]);
      await tester.pumpAndSettle();
      final refresh = tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      service.requests[1].completeError(StateError('technical details'));
      await refresh;
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('student-class-exercises-error')),
        findsOneWidget,
      );
      expect(find.textContaining('technical details'), findsNothing);
      expect(
        tester
            .widget<StudentClassUpcomingDeadlineSection>(
              find.byType(StudentClassUpcomingDeadlineSection),
            )
            .exercises,
        [exercise],
      );
      expect(
        tester
            .widget<StudentClassLearningCategorySection>(
              find.byType(StudentClassLearningCategorySection),
            )
            .classroomExerciseCount,
        1,
      );
    },
  );

  testWidgets(
    'changing classroom ignores a late error from the old classroom',
    (tester) async {
      final service = _Exercises();
      await tester.pumpWidget(
        app(
          StudentClassDetailScreen(
            profileId: 1,
            classroomId: 10,
            exerciseService: service,
          ),
        ),
      );
      await tester.pumpWidget(
        app(
          StudentClassDetailScreen(
            profileId: 1,
            classroomId: 11,
            exerciseService: service,
          ),
        ),
      );
      service.requests[1].complete([]);
      await tester.pumpAndSettle();
      service.requests[0].completeError(
        const ClassroomExerciseException('Old class failed'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Old class failed'), findsNothing);
      expect(find.byType(StudentClassEmptyPanel), findsOneWidget);
      expect(
        tester
            .widget<StudentClassLearningCategorySection>(
              find.byType(StudentClassLearningCategorySection),
            )
            .classroomId,
        11,
      );
    },
  );

  Widget search(_Lookups lookups, {int profileId = 1, VoidCallback? onJoin}) =>
      app(
        Scaffold(
          body: SingleChildScrollView(
            child: StudentClassSearchContent(
              profileId: profileId,
              classroomService: classrooms,
              gradeService: lookups,
              schoolService: lookups,
              onJoinRequested: onJoin,
            ),
          ),
        ),
      );
  Future<void> findJoinCard(WidgetTester tester) async {
    final field = tester.widget<StudentJoinSearchField>(
      find.byType(StudentJoinSearchField),
    );
    field.controller.text = 'CODE';
    field.onSubmitted('CODE');
    await tester.pumpAndSettle();
  }

  testWidgets(
    'joining invalidates cached joined classes before triggering refresh',
    (tester) async {
      await cubit.loadJoined(1);
      expect(cubit.joined(1).hasLoaded, isTrue);
      bool? loadedWhenRefreshTriggered;
      await tester.pumpWidget(
        search(
          _Lookups(),
          onJoin: () {
            loadedWhenRefreshTriggered = cubit.joined(1).hasLoaded;
          },
        ),
      );
      await findJoinCard(tester);
      tester
          .widget<StudentJoinClassCard>(find.byType(StudentJoinClassCard))
          .onJoin();
      classrooms.join.complete();
      await tester.pumpAndSettle();
      expect(loadedWhenRefreshTriggered, isFalse);
    },
  );

  testWidgets('profile change ignores an old join error', (tester) async {
    final lookups = _Lookups();
    await tester.pumpWidget(search(lookups));
    await findJoinCard(tester);
    final join = tester
        .widget<StudentJoinClassCard>(find.byType(StudentJoinClassCard))
        .onJoin;
    join();
    join();
    expect(classrooms.joins, 1);
    await tester.pumpWidget(search(lookups, profileId: 2));
    classrooms.join.completeError(StateError('old join failure'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(StudentJoinClassCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Parent Room retains cached classes on refresh error and drops them offstage on profile change',
    (tester) async {
      final service = _Layouts();
      Widget room({int profileId = 1, bool active = true, int tick = 0}) =>
          RepositoryProvider<HomeLayoutService>.value(
            value: service,
            child: app(
              Scaffold(
                body: ParentRoomTab(
                  profiles: const [UserProfile(id: 3, role: 'STUDENT')],
                  activeProfile: UserProfile(id: profileId),
                  isActive: active,
                  activeRefreshTick: tick,
                  assignmentService: _Exercises(),
                  onRefreshProfiles: () async {},
                  onOpenClassroomTab: () {},
                  onOpenProfileMenu: () {},
                  bottomPadding: 30,
                  onOpenExamReview: (_, _) async {},
                  onCreateStudentProfile: (_) async {},
                ),
              ),
            ),
          );
      await tester.pumpWidget(room());
      service.requests[0].complete(
        const HomeLayout(
          parent: ParentHomeLayout(
            children: [UserProfile(id: 3, role: 'STUDENT')],
            classrooms: [
              HomeLayoutClassroom(
                memberProfileId: 3,
                classroom: ClassroomModel(id: 10, name: 'Cached class'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cached class'), findsOneWidget);
      await tester.pumpWidget(room(tick: 1));
      service.requests[1].completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Cached class'), findsOneWidget);
      expect(find.byType(AppRetryPanel), findsOneWidget);
      await tester.pumpWidget(room(profileId: 2, active: false, tick: 1));
      await tester.pump();
      expect(find.text('Cached class'), findsNothing);
      expect(service.requests, hasLength(2));
      expect(find.byType(AppRetryPanel), findsNothing);
    },
  );

  Widget create(_Lookups lookups, {int userId = 1, int profileId = 1}) => app(
    TeacherCreateClassScreen(
      user: LoginUser(id: userId),
      activeProfile: UserProfile(id: profileId),
      classroomService: classrooms,
      gradeService: lookups,
      profileService: lookups,
      schoolService: lookups,
    ),
  );
  TeacherCreateClassForm form(WidgetTester tester) =>
      tester.widget(find.byType(TeacherCreateClassForm));
  Future<void> cacheOptions(_Lookups lookups) =>
      TeacherClassroomLookupCache.shared.load(
        userId: 1,
        gradeService: lookups,
        profileService: lookups,
        schoolService: lookups,
      );

  testWidgets(
    'cached options remain editable and refresh failure retains the draft',
    (tester) async {
      final lookups = _Lookups();
      await cacheOptions(lookups);
      final refresh = Completer<List<GradeModel>>();
      lookups.pendingGrades.add(refresh);
      await tester.pumpWidget(create(lookups));
      expect(find.byType(TeacherCreateClassForm), findsOneWidget);
      form(tester).nameController.text = 'My draft';
      form(tester).onProgramsChanged([_Lookups.program]);
      await tester.pump();
      refresh.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.byType(AppRetryPanel), findsOneWidget);
      expect(form(tester).nameController.text, 'My draft');
      expect(form(tester).selectedPrograms, [_Lookups.program]);
      tester.widget<AppRetryPanel>(find.byType(AppRetryPanel)).onRetry();
      await tester.pumpAndSettle();
      expect(find.byType(AppRetryPanel), findsNothing);
      expect(form(tester).nameController.text, 'My draft');
      expect(form(tester).selectedPrograms, [_Lookups.program]);
    },
  );

  testWidgets(
    'changing identity ignores old option failure and clears the old draft',
    (tester) async {
      final lookups = _Lookups();
      await cacheOptions(lookups);
      final old = Completer<List<GradeModel>>();
      lookups.pendingGrades.add(old);
      await tester.pumpWidget(create(lookups));
      form(tester).nameController.text = 'Old draft';
      await tester.pumpWidget(create(lookups, userId: 2, profileId: 2));
      await tester.pumpAndSettle();
      old.completeError(StateError('old failure'));
      await tester.pumpAndSettle();
      expect(find.byType(AppRetryPanel), findsNothing);
      expect(form(tester).nameController.text, isEmpty);
      expect(form(tester).isSubmitting, isFalse);
    },
  );

  testWidgets(
    'duplicate submit is suppressed and late completion after dispose is ignored',
    (tester) async {
      final lookups = _Lookups();
      await tester.pumpWidget(create(lookups));
      await tester.pumpAndSettle();
      form(tester).nameController.text = 'My class';
      form(tester).onProgramsChanged([_Lookups.program]);
      await tester.pump();
      final submit = form(tester).onSubmit;
      submit();
      submit();
      await tester.pump();
      expect(classrooms.creates, 1);
      expect(form(tester).isSubmitting, isTrue);
      await tester.pumpWidget(app(const SizedBox()));
      classrooms.create.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unexpected submit failure unlocks the form and preserves its draft',
    (tester) async {
      final lookups = _Lookups();
      await tester.pumpWidget(create(lookups));
      await tester.pumpAndSettle();
      form(tester).nameController.text = 'My class';
      form(tester).onProgramsChanged([_Lookups.program]);
      await tester.pump();
      form(tester).onSubmit();
      classrooms.create.completeError(StateError('technical details'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('technical details'), findsNothing);
      expect(form(tester).isSubmitting, isFalse);
      expect(form(tester).nameController.text, 'My class');
      expect(form(tester).selectedPrograms, [_Lookups.program]);
    },
  );
}

class _Exercises implements ClassroomExerciseService {
  final requests = <Completer<List<ClassroomExercise>>>[];
  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) {
    final request = Completer<List<ClassroomExercise>>();
    requests.add(request);
    return request.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Classrooms implements ClassroomService {
  int creates = 0;
  late final create = Completer<ClassroomModel?>();
  int joins = 0;
  late final join = Completer<void>();
  @override
  Future<void> joinClassroomByCode({
    required int profileId,
    required String classroomCode,
  }) {
    joins++;
    return join.future;
  }

  @override
  Future<List<ClassroomModel>> listMyJoinedClassrooms({
    required int profileId,
  }) async => [];
  @override
  Future<List<ClassroomModel>> searchClassrooms({
    required int profileId,
    String? search,
    List<int>? gradeIds,
    List<int>? schoolIds,
  }) async => [
    const ClassroomModel(
      id: 10,
      name: 'Join class',
      classroomCode: 'CODE',
      relationship: 'NONE',
    ),
  ];
  @override
  Future<ClassroomModel?> getClassroomDetail({
    required int classroomId,
    required int profileId,
  }) async => ClassroomModel(id: classroomId, name: 'Class $classroomId');
  @override
  Future<ClassroomModel?> createClassroom({
    required int profileId,
    required String name,
    required List<int> programIds,
    required int gradeId,
    required int schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  }) {
    creates++;
    return create.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Lookups implements GradeService, ProfileService, SchoolService {
  static const program = ProgramModel(id: 1, label: 'Math');
  final pendingGrades = <Completer<List<GradeModel>>>[];
  @override
  Future<List<GradeModel>> listGrades({required int userId}) =>
      pendingGrades.isNotEmpty
      ? pendingGrades.removeAt(0).future
      : Future.value([const GradeModel(id: 1, label: 'Grade 1')]);
  @override
  Future<List<ProgramModel>> listPrograms({required int userId}) async => [
    program,
  ];
  @override
  Future<List<SchoolModel>> listSchools() async => [
    const SchoolModel(id: 1, name: 'School'),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Layouts implements HomeLayoutService {
  final requests = <Completer<HomeLayout>>[];
  @override
  Future<HomeLayout> getLayout({required int profileId}) {
    final request = Completer<HomeLayout>();
    requests.add(request);
    return request.future;
  }
}
