import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/pending_assessment_completion_store.dart';
import 'package:numi/features/exam/helpers/assessment_journey_completion.dart';

Future<void> reconcilePendingAssessmentCompletions({
  required ExamService examService,
  required PendingAssessmentCompletionStore completionStore,
  required Set<int> allowedProfileIds,
}) async {
  if (allowedProfileIds.isEmpty) {
    return;
  }

  final List<PendingAssessmentCompletion> pending;
  try {
    pending = await completionStore.readAll();
  } catch (_) {
    return;
  }
  for (final item in pending) {
    if (!allowedProfileIds.contains(item.profileId)) {
      continue;
    }
    try {
      await completeAssessmentJourney(
        examService: examService,
        completionStore: completionStore,
        userExamId: item.userExamId,
        profileId: item.profileId,
      );
    } catch (_) {
      // Keep the entry so a later app start can retry it.
    }
  }
}
