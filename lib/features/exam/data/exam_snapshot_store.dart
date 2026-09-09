import 'package:numi/features/exam/models/exam.dart';

abstract interface class ExamSnapshotStore {
  void seedList({
    required List<GeneratedExam> exams,
    int? userId,
    int? profileId,
  });
}

class NoopExamSnapshotStore implements ExamSnapshotStore {
  const NoopExamSnapshotStore();

  @override
  void seedList({
    required List<GeneratedExam> exams,
    int? userId,
    int? profileId,
  }) {}
}
