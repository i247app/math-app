import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:numi/features/games/models/star_game.dart';

enum StarGamePhase { countdown, question, feedback, result }

class StarGameRound extends ChangeNotifier {
  StarGameRound({required this.questions, required this.onFinish}) {
    _countDown();
  }

  final List<StarGameQuestion> questions;
  final ValueChanged<StarGameRecord> onFinish;
  final clock = ValueNotifier(Duration.zero);
  final _stopwatch = Stopwatch();

  Timer? _phaseTimer;
  Timer? _clockTimer;
  StarGamePhase phase = StarGamePhase.countdown;
  bool paused = false;
  int countdown = 3;
  int index = 0;
  int correct = 0;
  int? selected;
  int _correctStreak = 0;
  bool _reduceFeedbackMotion = false;

  StarGameQuestion get question => questions[index];
  bool get streakCelebration => _correctStreak > 0 && _correctStreak % 3 == 0;
  bool get perfectRound => correct == questions.length;

  Duration get feedbackDuration {
    if (selected != question.answer) return const Duration(milliseconds: 1100);
    if (_reduceFeedbackMotion) return const Duration(milliseconds: 550);
    if (perfectRound) return const Duration(milliseconds: 1040);
    if (streakCelebration) return const Duration(milliseconds: 910);
    return const Duration(milliseconds: 670);
  }

  bool answer(int choice, {bool reduceMotion = false}) {
    if (paused || phase != StarGamePhase.question) return false;
    _stopClock();
    selected = choice;
    _reduceFeedbackMotion = reduceMotion;
    if (choice == question.answer) {
      correct++;
      _correctStreak++;
    } else {
      _correctStreak = 0;
    }
    phase = StarGamePhase.feedback;
    _showFeedback();
    notifyListeners();
    return true;
  }

  void pause() {
    if (paused || phase == StarGamePhase.result) return;
    paused = true;
    _phaseTimer?.cancel();
    _stopClock();
    notifyListeners();
  }

  void resume() {
    if (!paused) return;
    paused = false;
    switch (phase) {
      case StarGamePhase.countdown:
        _countDown();
      case StarGamePhase.question:
        _startClock();
      case StarGamePhase.feedback:
        _showFeedback();
      case StarGamePhase.result:
        break;
    }
    notifyListeners();
  }

  void _countDown() {
    _phaseTimer = Timer(const Duration(seconds: 1), () {
      countdown--;
      if (countdown == 0) {
        phase = StarGamePhase.question;
        _startClock();
      } else {
        _countDown();
      }
      notifyListeners();
    });
  }

  void _showFeedback() {
    _phaseTimer = Timer(feedbackDuration, () {
      if (index + 1 == questions.length) {
        phase = StarGamePhase.result;
        onFinish(StarGameRecord(correct: correct, elapsed: _stopwatch.elapsed));
      } else {
        index++;
        selected = null;
        phase = StarGamePhase.question;
        _startClock();
      }
      notifyListeners();
    });
  }

  void _startClock() {
    _stopwatch.start();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      clock.value = _stopwatch.elapsed;
    });
  }

  void _stopClock() {
    _stopwatch.stop();
    _clockTimer?.cancel();
    clock.value = _stopwatch.elapsed;
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _clockTimer?.cancel();
    _stopwatch.stop();
    clock.dispose();
    super.dispose();
  }
}
