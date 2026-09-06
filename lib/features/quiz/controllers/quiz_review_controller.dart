import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_exception.dart';

enum QuizReviewMode { retry, result }

class QuizReviewController extends ChangeNotifier {
  QuizReviewController({
    required this.quizId,
    required QuizDetailLoader loadDetail,
    GeneratedQuiz? initialQuiz,
    QuizReviewMode initialMode = QuizReviewMode.retry,
    Object? cacheKey,
  }) : _loadDetail = loadDetail,
       _cacheKey = cacheKey ?? quizId,
       _quiz = initialQuiz {
    _mode = initialMode;
    _seedSubmittedAnswers(initialQuiz);
    if (initialQuiz != null) {
      QuizCache.seedDetail(initialQuiz, fallbackCacheKey: _cacheKey);
    }
  }

  final int quizId;
  final QuizDetailLoader _loadDetail;
  final Object _cacheKey;

  GeneratedQuiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  int _loadRequestId = 0;
  bool _disposed = false;
  QuizReviewMode _mode = QuizReviewMode.retry;
  final Map<int, String> _submittedAnswers = <int, String>{};
  final Map<int, String> _retryAnswers = <int, String>{};

  GeneratedQuiz? get quiz => _quiz;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;
  QuizReviewMode get mode => _mode;
  Map<int, String> get submittedAnswers =>
      Map<int, String>.unmodifiable(_submittedAnswers);
  Map<int, String> get retryAnswers =>
      Map<int, String>.unmodifiable(_retryAnswers);

  Future<void> loadQuizDetail({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final cachedQuiz = QuizCache.peekDetail(_cacheKey);
    final initialQuizHasDetail = _quiz?.questions.isNotEmpty == true;
    final cachedQuizHasDetail = cachedQuiz?.questions.isNotEmpty == true;
    if (cachedQuiz != null && (!initialQuizHasDetail && cachedQuizHasDetail)) {
      _quiz = cachedQuiz;
      _seedSubmittedAnswers(cachedQuiz);
    }

    // A quiz from a list or navigation argument can contain only summary
    // metadata.  Do not treat that as loaded detail: otherwise the empty
    // questions state flashes while the detail request is still in flight.
    final hasVisibleDetail = _quiz?.questions.isNotEmpty == true;
    _isLoading = !hasVisibleDetail;
    _errorMessage = null;
    _notifyIfAlive();

    final shouldRefresh = forceRefresh || !QuizCache.isDetailFresh(_cacheKey);
    if (!shouldRefresh) {
      _isLoading = false;
      _notifyIfAlive();
      return;
    }

    try {
      final quiz = await QuizCache.loadDetail(
        loadDetail: _loadDetail,
        cacheKey: _cacheKey,
        serviceQuizId: quizId,
        forceRefresh: forceRefresh || hasVisibleDetail,
      );
      if (_disposed || requestId != _loadRequestId) {
        return;
      }

      _quiz = quiz;
      _seedSubmittedAnswers(quiz);
      _isLoading = false;
      if (_selectedIndex >= quiz.questions.length) {
        _selectedIndex = 0;
      }
      notifyListeners();
    } on QuizException catch (error) {
      _handleLoadFailure(requestId, error.message);
    } catch (_) {
      _handleLoadFailure(
        requestId,
        AppStrings.current(AppKeys.quizDetailLoadFailed),
      );
    }
  }

  bool selectQuestion(int index) {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
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

  bool selectMode(QuizReviewMode mode) {
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
    final lastIndex = (_quiz?.questions.length ?? 0) - 1;
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

  void _seedSubmittedAnswers(GeneratedQuiz? quiz) {
    if (quiz == null) {
      return;
    }
    _submittedAnswers.clear();
    if (quiz.answers.isEmpty) {
      return;
    }
    for (final answer in quiz.answers) {
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
