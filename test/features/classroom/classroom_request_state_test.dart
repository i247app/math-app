import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/controllers/parent_room_controller.dart';
import 'package:numi/features/classroom/controllers/student_class_exercises_controller.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/models/home_layout.dart';

void main() {
  group('Student exercises', () {
    late _Exercises service;
    late StudentClassExercisesController controller;
    setUp(() {
      service = _Exercises();
      controller = StudentClassExercisesController(exerciseService: service);
    });
    tearDown(() => controller.dispose());

    test(
      'initial failure differs from a successful empty response; retry recovers',
      () async {
        final failed = controller.load(profileId: 1, classroomId: 10);
        expect(controller.state.isInitialLoading, isTrue);
        service.requests[0].completeError(StateError('offline'));
        await failed;
        expect(controller.state.phase, AsyncPhase.failure);
        expect(controller.state.hasData, isFalse);
        expect(controller.state.data, isNull);
        final retry = controller.load(profileId: 1, classroomId: 10);
        service.requests[1].complete([]);
        await retry;
        expect(controller.state.phase, AsyncPhase.ready);
        expect(controller.state.hasData, isTrue);
        expect(controller.state.data, isEmpty);
        expect(controller.state.failure, isNull);
        expect(service.visibility, everyElement('PUBLIC'));
      },
    );

    test('refresh failure preserves successful data', () async {
      final load = controller.load(profileId: 1, classroomId: 10);
      const exercise = ClassroomExercise(id: 20, title: 'Homework');
      service.requests[0].complete([exercise]);
      await load;
      final refresh = controller.load(profileId: 1, classroomId: 10);
      expect(controller.state.isRefreshing, isTrue);
      expect(controller.state.data, [exercise]);
      service.requests[1].completeError(StateError('offline'));
      await refresh;
      expect(controller.state.phase, AsyncPhase.failure);
      expect(controller.state.data, [exercise]);
      expect(controller.state.hasData, isTrue);
      expect(controller.state.isRefreshing, isFalse);
    });

    for (final failOld in [false, true]) {
      test(
        'older ${failOld ? 'error' : 'success'} cannot overwrite a newer response',
        () async {
          final old = controller.load(profileId: 1, classroomId: 10);
          final fresh = controller.load(profileId: 1, classroomId: 10);
          const latest = ClassroomExercise(id: 2);
          service.requests[1].complete([latest]);
          await fresh;
          if (failOld) {
            service.requests[0].completeError(StateError('old error'));
          } else {
            service.requests[0].complete([const ClassroomExercise(id: 1)]);
          }
          await old;
          expect(controller.state.data, [latest]);
          expect(controller.state.failure, isNull);
        },
      );
    }

    test('changing profile or classroom discards the previous data', () async {
      final old = controller.load(profileId: 1, classroomId: 10);
      service.requests[0].complete([const ClassroomExercise(id: 1)]);
      await old;
      final changed = controller.load(profileId: 2, classroomId: 10);
      expect(controller.state.isInitialLoading, isTrue);
      expect(controller.state.data, isNull);
      service.requests[1].complete([]);
      await changed;
      final newClass = controller.load(profileId: 2, classroomId: 11);
      expect(controller.state.hasData, isFalse);
      service.requests[2].completeError(StateError('offline'));
      await newClass;
      expect(controller.state.data, isNull);
    });

    test('ending the session ignores completion', () async {
      final load = controller.load(profileId: 1, classroomId: 10);
      final before = controller.state;
      SessionCacheScope.reset();
      service.requests[0].complete([]);
      await load;
      expect(controller.state, same(before));
    });

    test('disposed controller ignores both success and error', () async {
      final disposed = StudentClassExercisesController(
        exerciseService: service,
      );
      final old = disposed.load(profileId: 1, classroomId: 10);
      final fresh = disposed.load(profileId: 1, classroomId: 10);
      disposed.dispose();
      service.requests[0].complete([]);
      service.requests[1].completeError(StateError('offline'));
      await Future.wait([old, fresh]);
    });
  });

  group('ClassroomCubit', () {
    late _Classrooms service;
    late ClassroomCubit cubit;
    setUp(() {
      service = _Classrooms();
      cubit = ClassroomCubit(classroomService: service);
    });
    tearDown(() async {
      if (!cubit.isClosed) await cubit.close();
    });

    test(
      'shares in-flight collection loads and caches successful empty data',
      () async {
        final a = cubit.loadOwned(1);
        final b = cubit.loadOwned(1, forceRefresh: true);
        expect(service.collections, hasLength(1));
        service.collections[0].complete([]);
        await Future.wait([a, b]);
        expect(cubit.owned(1).hasLoaded, isTrue);
        expect(cubit.owned(1).classrooms, isEmpty);
        await cubit.loadOwned(1);
        expect(service.collections, hasLength(1));
      },
    );

    test('initial failure is retryable without force refresh', () async {
      final a = cubit.loadJoined(1);
      service.collections[0].completeError(const ClassroomException('offline'));
      await a;
      expect(cubit.joined(1).hasLoaded, isFalse);
      expect(cubit.joined(1).errorMessage, 'offline');
      final retry = cubit.loadJoined(1);
      service.collections[1].complete([]);
      await retry;
      expect(cubit.joined(1).hasLoaded, isTrue);
      expect(cubit.joined(1).errorMessage, isNull);
    });

    test(
      'refresh failure retains loaded collection and allows another retry',
      () async {
        const classroom = ClassroomModel(id: 10);
        final load = cubit.loadOwned(1);
        service.collections[0].complete([classroom]);
        await load;
        final refresh = cubit.loadOwned(1, forceRefresh: true);
        service.collections[1].completeError(StateError('offline'));
        await refresh;
        expect(cubit.owned(1).classrooms, [classroom]);
        expect(cubit.owned(1).hasLoaded, isTrue);
        final retry = cubit.loadOwned(1);
        service.collections[2].complete([]);
        await retry;
        expect(cubit.owned(1).errorMessage, isNull);
      },
    );

    for (final failOld in [false, true]) {
      test(
        'invalidated collection ignores old ${failOld ? 'error' : 'success'}',
        () async {
          final old = cubit.loadOwned(1);
          cubit.invalidateOwned(1);
          final fresh = cubit.loadOwned(1);
          expect(service.collections, hasLength(2));
          const latest = ClassroomModel(id: 2);
          service.collections[1].complete([latest]);
          await fresh;
          if (failOld) {
            service.collections[0].completeError(StateError('old error'));
          } else {
            service.collections[0].complete([const ClassroomModel(id: 1)]);
          }
          await old;
          expect(cubit.owned(1).classrooms, [latest]);
          expect(cubit.owned(1).errorMessage, isNull);
        },
      );
    }

    test('invalidating detail detaches the old pending request', () async {
      final old = cubit.loadDetail(profileId: 1, classroomId: 10);
      cubit.invalidateClassroomData(
        profileId: 1,
        classroomId: 10,
        members: false,
      );
      final fresh = cubit.loadDetail(profileId: 1, classroomId: 10);
      const latest = ClassroomModel(id: 10, name: 'Latest');
      service.details[1].complete(latest);
      await fresh;
      service.details[0].completeError(StateError('old error'));
      await old;
      expect(
        cubit.detail(profileId: 1, classroomId: 10).classroom,
        same(latest),
      );
      expect(cubit.detail(profileId: 1, classroomId: 10).errorMessage, isNull);
    });

    test('detail failure retains the initial classroom and retries', () async {
      const initial = ClassroomModel(id: 10);
      final load = cubit.loadDetail(
        profileId: 1,
        classroomId: 10,
        initialClassroom: initial,
      );
      service.details[0].completeError(StateError('offline'));
      await load;
      expect(
        cubit.detail(profileId: 1, classroomId: 10).classroom,
        same(initial),
      );
      expect(cubit.detail(profileId: 1, classroomId: 10).hasLoaded, isFalse);
      final retry = cubit.loadDetail(profileId: 1, classroomId: 10);
      service.details[1].complete(initial);
      await retry;
      expect(cubit.detail(profileId: 1, classroomId: 10).errorMessage, isNull);
    });

    test(
      'invalidating members ignores older success; refresh failure retains members',
      () async {
        final old = cubit.loadMembers(profileId: 1, classroomId: 10);
        cubit.invalidateClassroomData(
          profileId: 1,
          classroomId: 10,
          detail: false,
        );
        final fresh = cubit.loadMembers(profileId: 1, classroomId: 10);
        const member = ClassroomStudent(profileId: 2);
        service.students[1].complete([member]);
        await fresh;
        service.students[0].complete([]);
        await old;
        expect(cubit.members(profileId: 1, classroomId: 10).members, [member]);
        final refresh = cubit.loadMembers(
          profileId: 1,
          classroomId: 10,
          forceRefresh: true,
        );
        service.students[2].completeError(StateError('offline'));
        await refresh;
        expect(cubit.members(profileId: 1, classroomId: 10).members, [member]);
        expect(
          cubit.members(profileId: 1, classroomId: 10).errorMessage,
          isNotNull,
        );
      },
    );

    test(
      'invalidating one profile leaves the other profile request valid',
      () async {
        final a = cubit.loadJoined(1);
        final b = cubit.loadJoined(2);
        cubit.invalidateProfile(1);
        service.collections[0].complete([const ClassroomModel(id: 1)]);
        service.collections[1].complete([const ClassroomModel(id: 2)]);
        await Future.wait([a, b]);
        expect(cubit.joined(1).hasLoaded, isFalse);
        expect(cubit.joined(2).classrooms.single.id, 2);
      },
    );

    test('clear and close ignore late completion for every resource', () async {
      final a = cubit.loadOwned(1);
      final b = cubit.loadDetail(profileId: 1, classroomId: 10);
      final c = cubit.loadMembers(profileId: 1, classroomId: 10);
      cubit.clear();
      await cubit.close();
      service.collections[0].complete([]);
      service.details[0].completeError(StateError('offline'));
      service.students[0].complete([]);
      await Future.wait<Object>([a, b, c]);
      expect(cubit.state.ownedByProfile, isEmpty);
      expect(cubit.state.detailByClassroom, isEmpty);
      expect(cubit.state.membersByClassroom, isEmpty);
    });
  });

  group('Parent Room', () {
    late List<Completer<HomeLayout>> requests;
    late ParentRoomController controller;
    setUp(() {
      HomeProfileCache.instance.invalidateAll();
      requests = [];
      controller = ParentRoomController(
        loadLayout: (_) {
          final request = Completer<HomeLayout>();
          requests.add(request);
          return request.future;
        },
      );
    });
    tearDown(() {
      controller.dispose();
      HomeProfileCache.instance.invalidateAll();
    });

    test(
      'initial failure and successful empty layout remain distinct',
      () async {
        final load = controller.load(profileId: 1);
        expect(controller.state.isInitialLoading, isTrue);
        requests[0].completeError(StateError('offline'));
        await load;
        expect(controller.state.hasData, isFalse);
        expect(controller.state.phase, AsyncPhase.failure);
        final retry = controller.load(profileId: 1);
        requests[1].complete(const HomeLayout());
        await retry;
        expect(controller.state.hasData, isTrue);
        expect(controller.state.phase, AsyncPhase.ready);
      },
    );

    test('refresh failure keeps the layout and cached snapshot', () async {
      const layout = HomeLayout(role: 'PARENT');
      final load = controller.load(profileId: 1);
      requests[0].complete(layout);
      await load;
      final refresh = controller.load(profileId: 1, forceRefresh: true);
      expect(controller.state.isRefreshing, isTrue);
      requests[1].completeError(StateError('offline'));
      await refresh;
      expect(controller.state.data, same(layout));
      expect(controller.state.failure, isNotNull);
      expect(HomeProfileCache.instance.getParent(1)!.homeLayout, same(layout));
    });

    for (final failOld in [false, true]) {
      test(
        'profile switch ignores the old ${failOld ? 'error' : 'success'}',
        () async {
          final old = controller.load(profileId: 1);
          final fresh = controller.load(profileId: 2);
          const latest = HomeLayout(role: 'PARENT');
          requests[1].complete(latest);
          await fresh;
          if (failOld) {
            requests[0].completeError(StateError('old error'));
          } else {
            requests[0].complete(const HomeLayout());
          }
          await old;
          expect(controller.state.data, same(latest));
          expect(controller.state.failure, isNull);
          expect(HomeProfileCache.instance.getParent(1), isNull);
        },
      );
    }

    test(
      'selecting another profile offstage clears data and cancels its refresh',
      () async {
        final load = controller.load(profileId: 1);
        requests[0].complete(const HomeLayout());
        await load;
        final refresh = controller.load(profileId: 1, forceRefresh: true);
        controller.selectProfile(2);
        expect(controller.state.phase, AsyncPhase.idle);
        expect(controller.state.hasData, isFalse);
        requests[1].completeError(StateError('old error'));
        await refresh;
        expect(controller.state.phase, AsyncPhase.idle);
      },
    );

    test('fresh snapshot skips the endpoint', () async {
      final load = controller.load(profileId: 1);
      requests[0].complete(const HomeLayout());
      await load;
      controller.selectProfile(2);
      await controller.load(profileId: 1);
      expect(requests, hasLength(1));
      expect(controller.state.hasData, isTrue);
    });

    test(
      'no profile produces empty data without requesting a service',
      () async {
        await controller.load(profileId: null);
        expect(controller.state.data!.rooms, isEmpty);
        expect(controller.state.failure, isNull);
        expect(requests, isEmpty);
      },
    );

    test('session end prevents state updates and cache writes', () async {
      final load = controller.load(profileId: 1);
      final before = controller.state;
      SessionCacheScope.reset();
      requests[0].complete(const HomeLayout());
      await load;
      expect(controller.state, same(before));
      expect(HomeProfileCache.instance.getParent(1), isNull);
    });

    test('dispose prevents cache writes and notifications', () async {
      final request = Completer<HomeLayout>();
      final disposed = ParentRoomController(loadLayout: (_) => request.future);
      final load = disposed.load(profileId: 1);
      disposed.dispose();
      request.complete(const HomeLayout());
      await load;
      expect(HomeProfileCache.instance.getParent(1), isNull);
    });
  });
}

class _Exercises implements ClassroomExerciseService {
  final requests = <Completer<List<ClassroomExercise>>>[];
  final visibility = <String?>[];
  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) {
    this.visibility.add(visibility);
    final request = Completer<List<ClassroomExercise>>();
    requests.add(request);
    return request.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Classrooms implements ClassroomService {
  final collections = <Completer<List<ClassroomModel>>>[];
  final details = <Completer<ClassroomModel?>>[];
  final students = <Completer<List<ClassroomStudent>>>[];
  @override
  Future<List<ClassroomModel>> listClassrooms({required int profileId}) {
    final request = Completer<List<ClassroomModel>>();
    collections.add(request);
    return request.future;
  }

  @override
  Future<List<ClassroomModel>> listMyJoinedClassrooms({
    required int profileId,
  }) => listClassrooms(profileId: profileId);
  @override
  Future<ClassroomModel?> getClassroomDetail({
    required int classroomId,
    required int profileId,
  }) {
    final request = Completer<ClassroomModel?>();
    details.add(request);
    return request.future;
  }

  @override
  Future<List<ClassroomStudent>> listJoinRequests({
    required int profileId,
    required int classroomId,
  }) async => [];
  @override
  Future<List<ClassroomStudent>> listStudents({
    required int profileId,
    required int classroomId,
  }) {
    final request = Completer<List<ClassroomStudent>>();
    students.add(request);
    return request.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
