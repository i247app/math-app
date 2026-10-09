import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_service_scope.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_category_tile.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_learning_category_section.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_section.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/teacher_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/navigation/classroom_exercise_navigator.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_screen.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_attempt_screen.dart';
import 'package:numi/features/classroom_exercise/screens/teacher_classroom_exercise_screen.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    StudentClassroomExerciseCache.clear();
    TeacherClassroomExerciseCache.clear();
  });

  testWidgets(
    'Classroom category opens exercise list with the active profile and class',
    (tester) async {
      final service = _ExerciseService();
      await _pump(
        tester,
        service,
        const StudentClassLearningCategorySection(
          classroomId: 17,
          profileId: 29,
          classroomExerciseCount: 2,
          isLoadingClassroomExercise: false,
        ),
      );
      await tester.tap(find.byType(StudentClassCategoryTile).first);
      await tester.pumpAndSettle();
      final screen = tester.widget<StudentClassroomExerciseScreen>(
        find.byType(StudentClassroomExerciseScreen),
      );
      expect(screen.classroomId, 17);
      expect(screen.profileId, 29);
      expect(service.listRequests, [(17, 29, null)]);
      expect(tester.takeException(), isNull);
    },
  );

  for (final purpose in [
    classroomExercisePurposeHomework,
    classroomExercisePurposeExam,
  ]) {
    testWidgets(
      'teacher exercise route preserves $purpose and classroom context',
      (tester) async {
        final service = _ExerciseService();
        const classroom = ClassroomModel(classroomId: 17);
        late BuildContext sourceContext;
        await _pump(
          tester,
          service,
          Builder(
            builder: (context) {
              sourceContext = context;
              return TextButton(
                onPressed: () => context
                    .read<ClassroomExerciseNavigator>()
                    .openTeacherExercises(
                      context: context,
                      classroomId: 17,
                      profileId: 29,
                      userId: 41,
                      initialClassroom: classroom,
                      purpose: purpose,
                    ),
                child: const Text('Open exercises'),
              );
            },
          ),
        );
        await tester.tap(find.text('Open exercises'));
        await tester.pumpAndSettle();
        final screen = tester.widget<TeacherClassroomExerciseScreen>(
          find.byType(TeacherClassroomExerciseScreen),
        );
        expect(screen.classroomId, 17);
        expect(screen.profileId, 29);
        expect(screen.userId, 41);
        expect(screen.purpose, purpose);
        expect(screen.initialClassroom, same(classroom));
        expect(service.listRequests, [(17, 29, purpose)]);
        Navigator.of(sourceContext).pop();
        await tester.pumpAndSettle();
        expect(find.text('Open exercises'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  final exercises = <String, ClassroomExercise>{
    'available': const ClassroomExercise(
      exerciseId: 53,
      title: 'Upcoming exercise',
      endDate: '2100-01-01',
    ),
    'submitted': const ClassroomExercise(
      exerciseId: 53,
      title: 'Upcoming exercise',
      endDate: '2100-01-01',
      submissionStatus: 'SUBMITTED',
    ),
    'not yet open': const ClassroomExercise(
      exerciseId: 53,
      title: 'Upcoming exercise',
      startDate: '2099-01-01',
      endDate: '2100-01-01',
    ),
    'missing ID': const ClassroomExercise(
      title: 'Upcoming exercise',
      endDate: '2100-01-01',
    ),
  };
  for (final entry in exercises.entries) {
    testWidgets('deadline action keeps the exercise open guard: ${entry.key}', (
      tester,
    ) async {
      final service = _ExerciseService();
      await _pump(
        tester,
        service,
        StudentClassUpcomingDeadlineSection(
          profileId: 29,
          exercises: [entry.value],
          isLoading: false,
        ),
      );
      await tester.tap(find.text('Upcoming exercise'));
      await tester.pumpAndSettle();
      if (entry.key == 'available') {
        final screen = tester.widget<StudentClassroomExerciseAttemptScreen>(
          find.byType(StudentClassroomExerciseAttemptScreen),
        );
        expect(screen.profileId, 29);
        expect(screen.exerciseId, 53);
        expect(screen.initialExercise, same(entry.value));
        expect(service.detailRequests, isNotEmpty);
        expect(service.detailRequests, everyElement((53, 29)));
      } else {
        expect(
          find.byType(StudentClassroomExerciseAttemptScreen),
          findsNothing,
        );
        expect(service.detailRequests, isEmpty);
        expect(find.byType(Dialog), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pump(
  WidgetTester tester,
  _ExerciseService service,
  Widget child,
) async {
  final lingo = LingoProvider();
  addTearDown(lingo.dispose);
  await tester.pumpWidget(
    AppServiceScope(
      services: AppServices(classroomExerciseService: service),
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ExerciseService implements ClassroomExerciseService {
  final listRequests = <(int, int, String?)>[];
  final detailRequests = <(int, int)>[];
  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) async {
    listRequests.add((classroomId, profileId, purpose));
    return const [];
  }

  @override
  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  }) async {
    detailRequests.add((exerciseId, profileId));
    return ClassroomExercise(
      exerciseId: exerciseId,
      title: 'Upcoming exercise',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
