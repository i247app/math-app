import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/teacher_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';

void main() {
  const timeout = Duration(seconds: 1);

  test('student homework list request completes', () async {
    const exercise = ClassroomExercise(classroomExerciseId: 9101);
    final service = _FakeClassroomExerciseService(
      listResult: const <ClassroomExercise>[exercise],
    );

    final result = await StudentClassroomExerciseCache.loadList(
      service: service,
      classroomId: 9101,
      profileId: 9101,
      forceRefresh: true,
    ).timeout(timeout);

    expect(result, const <ClassroomExercise>[exercise]);
    expect(service.listCalls, 1);
  });

  test('student homework detail request completes', () async {
    const exercise = ClassroomExercise(
      classroomExerciseId: 9102,
      questions: <ClassroomExerciseQuestion>[
        ClassroomExerciseQuestion(
          questionNumber: 1,
          content: '1 + 1 = ?',
          answers: <String>['1', '2'],
        ),
      ],
    );
    final service = _FakeClassroomExerciseService(detailResult: exercise);

    final result = await StudentClassroomExerciseCache.loadDetail(
      service: service,
      exerciseId: 9102,
      profileId: 9102,
      forceRefresh: true,
    ).timeout(timeout);

    expect(result, exercise);
    expect(service.detailCalls, 1);
  });

  test('teacher homework list request completes', () async {
    const exercise = ClassroomExercise(classroomExerciseId: 9103);
    final service = _FakeClassroomExerciseService(
      listResult: const <ClassroomExercise>[exercise],
    );

    final result = await TeacherClassroomExerciseCache.loadList(
      service: service,
      classroomId: 9103,
      profileId: 9103,
      purpose: classroomExercisePurposeHomework,
      forceRefresh: true,
    ).timeout(timeout);

    expect(result, const <ClassroomExercise>[exercise]);
    expect(service.listCalls, 1);
  });

  test('teacher homework detail request completes', () async {
    const exercise = ClassroomExercise(classroomExerciseId: 9104);
    final service = _FakeClassroomExerciseService(detailResult: exercise);

    final result = await TeacherClassroomExerciseCache.loadDetail(
      service: service,
      exerciseId: 9104,
      profileId: 9104,
      forceRefresh: true,
    ).timeout(timeout);

    expect(result, exercise);
    expect(service.detailCalls, 1);
  });
}

class _FakeClassroomExerciseService implements ClassroomExerciseService {
  _FakeClassroomExerciseService({
    this.listResult = const <ClassroomExercise>[],
    this.detailResult,
  });

  final List<ClassroomExercise> listResult;
  final ClassroomExercise? detailResult;
  int listCalls = 0;
  int detailCalls = 0;

  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) async {
    listCalls++;
    return listResult;
  }

  @override
  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  }) async {
    detailCalls++;
    return detailResult;
  }

  @override
  Future<ClassroomExercise?> createExercise({
    required int profileId,
    required int classroomId,
    required int programId,
    required String title,
    required String description,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
    String purpose = classroomExercisePurposeHomework,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ClassroomExerciseSubmissionResponse> submitExercise({
    required int profileId,
    required int classroomExerciseId,
    required List<SubmitClassroomExerciseAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
    String purpose = classroomExercisePurposeHomework,
  }) {
    throw UnimplementedError();
  }
}
