import 'dart:async';

import 'package:numi/features/exam/models/exam.dart';

/// Refresh signed image URLs without replacing selections or answer keys.
class ExamImageRefresher {
  ExamImageRefresher({
    required this.load,
    required this.isCurrent,
    required this.apply,
  });

  final Future<GeneratedExam> Function(GeneratedExam source) load;
  final bool Function(GeneratedExam source) isCurrent;
  final void Function(GeneratedExam exam) apply;
  Timer? _timer;
  bool _disposed = false;

  void schedule(GeneratedExam? source, {Duration? retryDelay}) {
    _timer?.cancel();
    if (_disposed || source == null || !source.hasImages) return;
    final age = DateTime.now().difference(
      source.imageUrlsFetchedAt ?? DateTime.now(),
    );
    final delay = retryDelay ?? const Duration(minutes: 50) - age;
    _timer = Timer(delay.isNegative ? Duration.zero : delay, () async {
      try {
        final fresh = await load(source);
        if (_disposed || !isCurrent(source)) return;
        final updated = source.withRefreshedImages(fresh);
        apply(updated);
        schedule(updated);
      } catch (_) {
        if (!_disposed && isCurrent(source)) {
          schedule(source, retryDelay: const Duration(minutes: 1));
        }
      }
    });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
  }
}
