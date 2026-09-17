import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';

enum ExamReviewMode { retry, result }

class ExamReviewController extends ChangeNotifier {
  ExamReviewController({
    required this.examId,
    required ExamDetailLoader loadDetail,
    GeneratedExam? initialExam,
    ExamReviewMode initialMode = ExamReviewMode.retry,
    Object? cacheKey,
  }) : _loadDetail = loadDetail,
       _cacheKey = cacheKey ?? examId,
       _exam = initialExam {
    _mode = initialMode;
    _seedSubmittedAnswers(initialExam);
    if (initialExam != null) {
      ExamCache.seedDetail(initialExam, fallbackCacheKey: _cacheKey);
    }
  }

  final int examId;
  final ExamDetailLoader _loadDetail;
  final Object _cacheKey;

  GeneratedExam? _exam;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  int _loadRequestId = 0;
  bool _disposed = false;
  ExamReviewMode _mode = ExamReviewMode.retry;
  final Map<int, String> _submittedAnswers = <int, String>{};
  final Map<int, String> _retryAnswers = <int, String>{};

  GeneratedExam? get exam => _exam;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;
  ExamReviewMode get mode => _mode;
  Map<int, String> get submittedAnswers =>
      Map<int, String>.unmodifiable(_submittedAnswers);
  Map<int, String> get retryAnswers =>
      Map<int, String>.unmodifiable(_retryAnswers);

  Future<void> loadExamDetail({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final cachedExam = ExamCache.peekDetail(_cacheKey);
    final initialExamHasDetail = _exam?.questions.isNotEmpty == true;
    final cachedExamHasDetail = cachedExam?.questions.isNotEmpty == true;
    if (cachedExam != null && (!initialExamHasDetail && cachedExamHasDetail)) {
      _exam = cachedExam;
      _seedSubmittedAnswers(cachedExam);
    }

    // A exam from a list or navigation argument can contain only summary
    // metadata.  Do not treat that as loaded detail: otherwise the empty
    // questions state flashes while the detail request is still in flight.
    final hasVisibleDetail = _exam?.questions.isNotEmpty == true;
    _isLoading = !hasVisibleDetail;
    _errorMessage = null;
    _notifyIfAlive();

    final shouldRefresh = forceRefresh || !ExamCache.isDetailFresh(_cacheKey);
    if (!shouldRefresh) {
      _isLoading = false;
      _notifyIfAlive();
      return;
    }

    try {
      final exam = await ExamCache.loadDetail(
        loadDetail: _loadDetail,
        cacheKey: _cacheKey,
        serviceExamId: examId,
        forceRefresh: forceRefresh || hasVisibleDetail,
      );
      if (_disposed || requestId != _loadRequestId) {
        return;
      }

      _exam = exam;
      _seedSubmittedAnswers(exam);
      _isLoading = false;
      if (_selectedIndex >= exam.questions.length) {
        _selectedIndex = 0;
      }
      notifyListeners();
    } on ExamException catch (error) {
      _handleLoadFailure(requestId, error.message);
    } catch (_) {
      _handleLoadFailure(
        requestId,
        AppStrings.current(AppKeys.examDetailLoadFailed),
      );
    }
  }

  bool selectQuestion(int index) {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (questions.isEmpty || index < 0 || index >= questions.length) {
      return false;
    }
    if (_selectedIndex == index) {
      return false;
    }

    _selectedIndex = index;
    notifyListeners();
    return true;
  }

  bool selectMode(ExamReviewMode mode) {
    if (_mode == mode) {
      return false;
    }

    _mode = mode;
    notifyListeners();
    return true;
  }

  void selectAnswer(int questionNumber, String label) {
    _retryAnswers[questionNumber] = label.trim().toUpperCase();
    notifyListeners();
  }

  bool goToPreviousQuestion() {
    if (_selectedIndex <= 0) {
      return false;
    }
    return selectQuestion(_selectedIndex - 1);
  }

  bool goToNextQuestion() {
    final lastIndex = (_exam?.questions.length ?? 0) - 1;
    if (_selectedIndex >= lastIndex) {
      return false;
    }
    return selectQuestion(_selectedIndex + 1);
  }

  void _handleLoadFailure(int requestId, String message) {
    if (_disposed || requestId != _loadRequestId) {
      return;
    }

    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _seedSubmittedAnswers(GeneratedExam? exam) {
    if (exam == null) {
      return;
    }
    _submittedAnswers.clear();
    if (exam.answers.isEmpty) {
      return;
    }
    for (final answer in exam.answers) {
      final label = answer.label.trim().toUpperCase();
      if (label.isNotEmpty) {
        _submittedAnswers[answer.questionNumber] = label;
      }
    }
  }

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
