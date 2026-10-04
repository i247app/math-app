import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/pending_assessment_completion_store.dart';

const assessmentCompletedStatus = 'COMPLETE';

Future<void> completeAssessmentJourney({
  required ExamService examService,
  PendingAssessmentCompletionStore? completionStore,
  required int? userExamId,
  int? profileId,
  bool? esessFlag,
}) async {
  if (userExamId == null || userExamId <= 0) {
    throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
  }
  final cacheScope = SessionCacheScope.current;
  await examService.updateUserExamStatus(
    userExamId: userExamId,
    status: assessmentCompletedStatus,
    profileId: profileId,
    esessFlag: esessFlag,
  );
  if (cacheScope.isCurrent) ExamCache.invalidateLists(profileId: profileId);
  try {
    await completionStore?.remove(userExamId);
  } catch (_) {
    // The server is already complete. A stale local marker is safe to retry.
  }
}
