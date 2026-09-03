import 'package:flutter/foundation.dart';

/// A debug-only request counter with no request payload or header logging.
///
/// [DebugRequestMetricsInterceptor] is registered only in debug builds; this
/// class remains independently usable in tests to characterize its accounting.
class DebugRequestMetrics {
  DebugRequestMetrics({void Function(String message)? log}) : _log = log;

  static final DebugRequestMetrics instance = DebugRequestMetrics();

  final void Function(String message)? _log;
  int _started = 0;
  int _succeeded = 0;
  int _failed = 0;

  DebugRequestMetricsSnapshot get snapshot => DebugRequestMetricsSnapshot(
    started: _started,
    succeeded: _succeeded,
    failed: _failed,
  );

  int recordStarted({required String method, required String path}) {
    final requestNumber = ++_started;
    _log?.call('request #$requestNumber $method $path started');
    return requestNumber;
  }

  void recordCompleted({
    required int requestNumber,
    required String method,
    required String path,
    required Duration elapsed,
    int? statusCode,
    required bool failed,
  }) {
    if (failed) {
      _failed++;
    } else {
      _succeeded++;
    }

    final outcome = failed ? 'failed' : 'completed';
    final status = statusCode == null ? '' : ' status=$statusCode';
    _log?.call(
      'request #$requestNumber $method $path $outcome$status '
      'in ${elapsed.inMilliseconds}ms '
      '(started=$_started, succeeded=$_succeeded, failed=$_failed)',
    );
  }

  @visibleForTesting
  void reset() {
    _started = 0;
    _succeeded = 0;
    _failed = 0;
  }
}

class DebugRequestMetricsSnapshot {
  const DebugRequestMetricsSnapshot({
    required this.started,
    required this.succeeded,
    required this.failed,
  });

  final int started;
  final int succeeded;
  final int failed;
}
