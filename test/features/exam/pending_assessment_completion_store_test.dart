import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/pending_assessment_completion_store.dart';
import 'package:numi/features/exam/helpers/pending_assessment_completion_reconciler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test(
    'secure store persists, replaces, and removes pending journeys',
    () async {
      const store = SecurePendingAssessmentCompletionStore();

      await store.markPending(userExamId: 91, profileId: 21);
      await store.markPending(userExamId: 92, profileId: 22);
      await store.markPending(userExamId: 91, profileId: 23);

      final stored = await store.readAll();
      expect(stored, hasLength(2));
      expect(stored[0].userExamId, 92);
      expect(stored[0].profileId, 22);
      expect(stored[1].userExamId, 91);
      expect(stored[1].profileId, 23);

      await store.remove(92);

      final remaining = await store.readAll();
      expect(remaining, hasLength(1));
      expect(remaining.single.userExamId, 91);
    },
  );

  test(
    'reconciler completes only journeys owned by restored profiles',
    () async {
      final store = _MemoryCompletionStore(<PendingAssessmentCompletion>[
        const PendingAssessmentCompletion(userExamId: 91, profileId: 21),
        const PendingAssessmentCompletion(userExamId: 92, profileId: 22),
      ]);
      final service = _RecordingExamService();

      await reconcilePendingAssessmentCompletions(
        examService: service,
        completionStore: store,
        allowedProfileIds: const <int>{21},
      );

      expect(service.completed, <(int, int?)>[(91, 21)]);
      expect(store.items.map((item) => item.userExamId), <int>[92]);
    },
  );

  test('reconciler keeps a pending journey when the API fails', () async {
    final store = _MemoryCompletionStore(<PendingAssessmentCompletion>[
      const PendingAssessmentCompletion(userExamId: 91, profileId: 21),
    ]);
    final service = _RecordingExamService(shouldFail: true);

    await reconcilePendingAssessmentCompletions(
      examService: service,
      completionStore: store,
      allowedProfileIds: const <int>{21},
    );

    expect(store.items.single.userExamId, 91);
  });
}

class _MemoryCompletionStore implements PendingAssessmentCompletionStore {
  _MemoryCompletionStore(List<PendingAssessmentCompletion> items)
    : items = List<PendingAssessmentCompletion>.from(items);

  final List<PendingAssessmentCompletion> items;

  @override
  Future<List<PendingAssessmentCompletion>> readAll() async =>
      List<PendingAssessmentCompletion>.from(items);

  @override
  Future<void> markPending({
    required int userExamId,
    required int profileId,
  }) async {
    items.removeWhere((item) => item.userExamId == userExamId);
    items.add(
      PendingAssessmentCompletion(userExamId: userExamId, profileId: profileId),
    );
  }

  @override
  Future<void> remove(int userExamId) async {
    items.removeWhere((item) => item.userExamId == userExamId);
  }
}

class _RecordingExamService implements ExamService {
  _RecordingExamService({this.shouldFail = false});

  final bool shouldFail;
  final List<(int, int?)> completed = <(int, int?)>[];

  @override
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {
    if (shouldFail) {
      throw StateError('offline');
    }
    expect(status, 'COMPLETE');
    completed.add((userExamId, profileId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
