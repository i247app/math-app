import 'package:flutter/foundation.dart';
import 'dart:async';

import '../repositories/quiz_repository.dart';
import '../responses/quiz/generate_quiz_response.dart';
import '../responses/quiz/submit_quiz_response.dart';

class QuizProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final QuizRepository _quizRepository = QuizRepository();

  final List<List<QuizQuestion>> _allQuizzes = [];
  int _currentQuizIndex = 0;
  QuizResultData? _result;
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  final Map<String, String> _allSelectedAnswers = {};
  int _remainingTime = 300;

  List<QuizQuestion>? get questions =>
      _allQuizzes.isNotEmpty && _currentQuizIndex < _allQuizzes.length
      ? _allQuizzes[_currentQuizIndex]
      : null;
  QuizResultData? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get allSelectedAnswers => _allSelectedAnswers;
  int get remainingTime => _remainingTime;
  bool get isQuizCompleted => _result != null;
  int get totalQuestions => questions?.length ?? 0;
  int get currentQuizIndex => _currentQuizIndex;
  int get totalQuizzes => _allQuizzes.length;
  bool get isLastQuiz => _currentQuizIndex == _allQuizzes.length - 1;
  QuizQuestion? get currentQuestion =>
      questions != null && _currentQuestionIndex < questions!.length
      ? questions![_currentQuestionIndex]
      : null;

  Future<bool> generateQuiz(
    String uid, {
    String? gradeId,
    String? semesterId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _quizRepository.generateQuiz(
        uid,
        gradeId: gradeId,
        semesterId: semesterId,
      );

      if (response.isSuccess &&
          response.result != null &&
          response.result!.data.isNotEmpty) {
        _allQuizzes.add(response.result!.data);
        _currentQuizIndex = _allQuizzes.length - 1;
        _currentQuestionIndex = 0;
        _remainingTime = 300;

        return true;
      } else {
        _error =
            response.error ?? response.message ?? 'Failed to generate quiz';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generatePractice(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _quizRepository.generatePractice(uid);

      if (response.isSuccess &&
          response.result != null &&
          response.result!.data.isNotEmpty) {
        _allQuizzes.add(response.result!.data);
        _currentQuizIndex = _allQuizzes.length - 1;
        _currentQuestionIndex = 0;
        _remainingTime = 300;

        return true;
      } else {
        _error =
            response.error ??
            response.message ??
            'Failed to generate practice quiz';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadNextQuiz(
    String uid, {
    String? gradeId,
    String? semesterId,
  }) async {
    _saveCurrentQuizAnswers();

    return await generateQuiz(uid, gradeId: gradeId, semesterId: semesterId);
  }

  void loadPreviousQuiz() {
    if (_currentQuizIndex > 0) {
      _currentQuizIndex--;
      _currentQuestionIndex = 0;
      notifyListeners();
    }
  }

  void _saveCurrentQuizAnswers() {
    if (_allQuizzes.isEmpty || _currentQuizIndex >= _allQuizzes.length) return;

    final currentQuiz = _allQuizzes[_currentQuizIndex];
    final quizId = 'quiz_$_currentQuizIndex';

    final answersMap = <int, String>{};
    for (final question in currentQuiz) {
      final answer =
          _allSelectedAnswers['${quizId}_${question.questionNumber}'];
      if (answer != null) {
        answersMap[question.questionNumber!] = answer;
      }
    }

    _allSelectedAnswers[quizId] = answersMap.toString();
  }

  Future<bool> submitQuiz(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _saveCurrentQuizAnswers();

      final allAnswers = getAllAnswers();

      final response = await _quizRepository.submitQuiz(uid, allAnswers);

      if (response.isSuccess) {
        _result = response.result!.data;
        return true;
      } else {
        _error = response.error ?? response.message ?? 'Failed to submit quiz';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getAllAnswers() {
    final allAnswers = <Map<String, dynamic>>[];

    for (int quizIndex = 0; quizIndex < _allQuizzes.length; quizIndex++) {
      final quizId = 'quiz_$quizIndex';
      final quiz = _allQuizzes[quizIndex];

      for (final question in quiz) {
        final answer =
            _allSelectedAnswers['${quizId}_${question.questionNumber}'];
        if (answer != null && answer.isNotEmpty) {
          allAnswers.add({
            'question_number': question.questionNumber,
            'answer': answer,
          });
        }
      }
    }

    return allAnswers;
  }

  void selectAnswer(int questionNumber, String answerLabel) {
    if (_allQuizzes.isEmpty || _currentQuizIndex >= _allQuizzes.length) return;

    final quizId = 'quiz_$_currentQuizIndex';
    _allSelectedAnswers['${quizId}_$questionNumber'] = answerLabel;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < (questions?.length ?? 0) - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void updateTimer(int remainingTime) {
    _remainingTime = remainingTime;
    if (_remainingTime <= 0) {}
    notifyListeners();
  }

  void resetQuiz() {
    _allQuizzes.clear();
    _currentQuizIndex = 0;
    _result = null;
    _currentQuestionIndex = 0;
    _allSelectedAnswers.clear();
    _remainingTime = 300;
    _error = null;
    notifyListeners();
  }

  bool get isAllQuestionsAnsweredInCurrentQuiz {
    if (_allQuizzes.isEmpty || _currentQuizIndex >= _allQuizzes.length) {
      return false;
    }
    final quizId = 'quiz_$_currentQuizIndex';
    final currentQuiz = _allQuizzes[_currentQuizIndex];
    for (final question in currentQuiz) {
      final answer =
          _allSelectedAnswers['${quizId}_${question.questionNumber}'];
      if (answer == null || answer.isEmpty) return false;
    }
    return true;
  }

  String? getSelectedAnswerForCurrentQuestion() {
    if (_allQuizzes.isEmpty ||
        _currentQuizIndex >= _allQuizzes.length ||
        _currentQuestionIndex >= _allQuizzes[_currentQuizIndex].length) {
      return null;
    }

    final quizId = 'quiz_$_currentQuizIndex';
    final questionNumber =
        _allQuizzes[_currentQuizIndex][_currentQuestionIndex].questionNumber;
    return _allSelectedAnswers['${quizId}_$questionNumber'];
  }
}
