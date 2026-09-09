import 'package:numi/features/exam/data/exam_snapshot_store.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/models/exam.dart';

class CachedExamSnapshotStore implements ExamSnapshotStore {
  const CachedExamSnapshotStore();

  @override
  void seedList({
    required List<GeneratedExam> exams,
    int? userId,
    int? profileId,
  }) {
    ExamCache.seedList(exams: exams, userId: userId, profileId: profileId);
  }
}
