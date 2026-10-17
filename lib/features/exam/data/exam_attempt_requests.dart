import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/practice_review_exam.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_attempt_state.dart';

class ExamAttemptRequestResult {
  const ExamAttemptRequestResult.success(this.exam) : errorMessage = null;
  const ExamAttemptRequestResult.failure(this.errorMessage) : exam = null;
  const ExamAttemptRequestResult.ignored() : exam = null, errorMessage = null;
  final GeneratedExam? exam;
  final String? errorMessage;
}

/// Owns the attempt's API work, successful submission reuse and cache writes.
/// Next-set generation only starts after the previous set has been submitted.
class ExamAttemptRequests {
  ExamAttemptRequests({
    required this.service,
    required this.examType,
    this.profileId,
  });
  final ExamService service;
  final String examType;
  final int? profileId;
  final _scope = SessionCacheScope.current;
  final Map<int, GeneratedExam> _submitted = {};
  final Map<int, Future<ExamAttemptRequestResult>> _pendingSubmissions = {};
  int _revision = 0;
  bool _disposed = false;

  bool get isActive => !_disposed && _scope.isCurrent;
  int? get latestUserExamId {
    for (final exam in _submitted.values.toList().reversed) {
      final id = exam.userExamId;
      if (id != null && id > 0) return id;
    }
    return null;
  }

  bool _current(int revision) => isActive && revision == _revision;

  void reset() {
    _revision++;
    _submitted.clear();
    _pendingSubmissions.clear();
  }

  Future<ExamAttemptRequestResult> generate({
    required String? gradeLabel,
    required int level,
    int? fallbackProfileId,
  }) async {
    if (!isActive) return const ExamAttemptRequestResult.ignored();
    final revision = _revision;
    try {
      final exam = await service.generateAssessmentExam(
        examType: examType,
        gradeLabel: gradeLabel,
        profileId: profileId ?? fallbackProfileId,
        level: level,
      );
      if (!_current(revision)) return const ExamAttemptRequestResult.ignored();
      ExamCache.seedDetail(exam);
      return ExamAttemptRequestResult.success(exam);
    } on ExamException catch (error) {
      return _current(revision)
          ? ExamAttemptRequestResult.failure(error.message)
          : const ExamAttemptRequestResult.ignored();
    } catch (_) {
      return _current(revision)
          ? ExamAttemptRequestResult.failure(
              AppStrings.current(AppKeys.createQuestionFailed),
            )
          : const ExamAttemptRequestResult.ignored();
    }
  }

  Future<ExamAttemptRequestResult> submit(
    GeneratedExam exam,
    List<SubmitExamAnswer> answers, {
    required ExamAttemptKind kind,
  }) {
    if (!isActive) {
      return Future.value(const ExamAttemptRequestResult.ignored());
    }
    final id = exam.examId;
    if (id == null) {
      return Future.value(
        ExamAttemptRequestResult.failure(
          AppStrings.current(AppKeys.missingExamToSubmit),
        ),
      );
    }
    final cached = _submitted[id];
    if (cached != null) {
      return Future.value(ExamAttemptRequestResult.success(cached));
    }
    final pending = _pendingSubmissions[id];
    if (pending != null) return pending;
    final request = _submit(
      exam,
      List<SubmitExamAnswer>.unmodifiable(answers),
      kind,
      _revision,
    );
    _pendingSubmissions[id] = request;
    return request.whenComplete(() {
      if (identical(_pendingSubmissions[id], request)) {
        _pendingSubmissions.remove(id);
      }
    });
  }

  Future<ExamAttemptRequestResult> _submit(
    GeneratedExam source,
    List<SubmitExamAnswer> answers,
    ExamAttemptKind kind,
    int revision,
  ) async {
    try {
      final submitted = await service.submitExam(
        examId: source.examId!,
        answers: answers,
        profileId: profileId ?? source.profileId,
      );
      if (!_current(revision)) return const ExamAttemptRequestResult.ignored();
      final review = kind == ExamAttemptKind.practice
          ? buildPracticeReviewExam(
              sourceExam: source,
              submittedExam: submitted,
              answers: answers,
            )
          : submitted;
      _submitted[source.examId!] = review;
      ExamCache.seedDetail(review);
      ExamCache.invalidateLists(
        profileId: profileId ?? review.profileId ?? source.profileId,
      );
      return ExamAttemptRequestResult.success(review);
    } on ExamException catch (error) {
      return _current(revision)
          ? ExamAttemptRequestResult.failure(error.message)
          : const ExamAttemptRequestResult.ignored();
    } catch (_) {
      return _current(revision)
          ? ExamAttemptRequestResult.failure(
              AppStrings.current(AppKeys.submitExamFailed),
            )
          : const ExamAttemptRequestResult.ignored();
    }
  }

  Future<ExamAttemptRequestResult> transition({
    required GeneratedExam source,
    required List<SubmitExamAnswer> answers,
    required ExamAttemptKind kind,
    required String? gradeLabel,
    required int level,
  }) async {
    if (!isActive) return const ExamAttemptRequestResult.ignored();
    final revision = _revision;
    final submitted = await submit(source, answers, kind: kind);
    if (!_current(revision)) return const ExamAttemptRequestResult.ignored();
    if (submitted.exam == null) return submitted;
    return generate(
      gradeLabel: gradeLabel,
      level: level,
      fallbackProfileId: source.profileId,
    );
  }

  Future<void> updateStatus({
    required int? userExamId,
    required String status,
    int? fallbackProfileId,
  }) => service.updateUserExamStatus(
    userExamId: userExamId,
    status: status,
    profileId: profileId ?? fallbackProfileId,
  );

  void dispose() {
    _disposed = true;
    reset();
  }
}
