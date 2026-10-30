import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Prepares and owns all question assets for the lifetime of one set.
class ExamImagePreloader extends ChangeNotifier {
  ExamImagePreloader({
    required this.load,
    this.isCached,
    this.retain,
    this.release,
  });

  final Future<void> Function(String url) load;
  final bool Function(String url)? isCached;
  final void Function(String url, int maxDimension)? retain;
  final Future<void> Function(String url)? release;
  static const maxConcurrent = 3;
  static const preparationTimeout = Duration(seconds: 15);
  static const decodedMemoryBudget = 32 * 1024 * 1024;

  final _inFlight = <String, Future<void>>{};
  final _finished = <String>{};
  final _queue = <String>[];
  Set<String> _desired = {};
  GeneratedExam? _lastExam;
  int? _lastIndex;
  Timer? _timer;
  bool _preparing = false;
  bool _disposed = false;

  bool get isPreparingSet => _preparing;

  void update(GeneratedExam? exam, int questionIndex) {
    if (_disposed ||
        (identical(exam, _lastExam) && questionIndex == _lastIndex)) {
      return;
    }
    final changedExam = !identical(exam, _lastExam);
    _lastExam = exam;
    _lastIndex = questionIndex;
    final questions = exam?.questions ?? const <ExamQuestion>[];
    final index = questions.isEmpty
        ? 0
        : questionIndex.clamp(0, questions.length - 1);
    final urls = <String>{
      for (var i = index; i < questions.length; i++)
        ..._questionUrls(questions[i]),
      for (var i = 0; i < index; i++) ..._questionUrls(questions[i]),
    };
    final previous = _desired;
    final dimension = dimensionForCount(urls.length);
    // Acquire first so images shared by adjacent sets never have zero owners.
    for (final url in urls.difference(previous)) {
      retain?.call(url, dimension);
    }
    _desired = urls;
    for (final url in previous.difference(urls)) {
      _release(url);
    }
    _finished.retainAll(urls);
    final cached = isCached;
    if (changedExam && cached != null) {
      _finished.removeWhere((url) => !cached(url));
      _finished.addAll(urls.where(cached));
    }
    _queue
      ..clear()
      ..addAll(
        urls.where(
          (url) => !_finished.contains(url) && !_inFlight.containsKey(url),
        ),
      );
    if (changedExam) {
      _timer?.cancel();
      final preparing = !_finished.containsAll(urls);
      if (preparing) _timer = Timer(preparationTimeout, _finishPreparing);
      if (_preparing != preparing) {
        _preparing = preparing;
        notifyListeners();
      }
    }
    _pump();
  }

  static int dimensionForCount(int count) => count <= 0
      ? 1024
      : math.sqrt(decodedMemoryBudget / (4 * count)).floor().clamp(1, 1024);

  void _pump() {
    while (!_disposed &&
        _inFlight.length < maxConcurrent &&
        _queue.isNotEmpty) {
      final url = _queue.removeAt(0);
      final task = Future<void>.sync(() => load(url))
          .catchError((Object error, StackTrace stackTrace) {})
          .whenComplete(() {
            _inFlight.remove(url);
            if (_disposed) return;
            if (_desired.contains(url)) _finished.add(url);
            if (_finished.containsAll(_desired)) _finishPreparing();
            _pump();
          });
      _inFlight[url] = task;
    }
  }

  void _finishPreparing() {
    _timer?.cancel();
    _timer = null;
    if (_disposed || !_preparing) return;
    _preparing = false;
    notifyListeners();
  }

  void _release(String url) {
    final remove = release;
    if (remove == null) return;
    unawaited(
      Future<void>.sync(() => remove(url))
          .catchError((Object error, StackTrace stackTrace) {}),
    );
  }

  static Iterable<String> _questionUrls(ExamQuestion question) sync* {
    final stemUrl = question.questionImageUrl;
    if (stemUrl != null && stemUrl.trim().isNotEmpty) yield stemUrl;
    for (final option in question.options) {
      final url = option.imageUrl;
      if (url != null && url.trim().isNotEmpty) yield url;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _queue.clear();
    for (final url in _desired) {
      _release(url);
    }
    _desired.clear();
    _finished.clear();
    super.dispose();
  }
}
