import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_logger.dart';

/// Associates the first rendered frame after a Home tab selection with that
/// selection. This is intentionally diagnostic-only and does not affect UI.
class HomeTabPerformanceMonitor {
  HomeTabPerformanceMonitor({void Function(String message)? log})
    : _log = log ?? ((message) => AppLogger.debug('PERF', message));

  final void Function(String message) _log;
  _PendingTabSwitch? _pendingTabSwitch;
  bool _isListening = false;
  int? _selectionFrameTimestampMicros;

  void beginTabSwitch({
    required String role,
    required int fromTab,
    required int toTab,
  }) {
    if ((!kDebugMode && !kProfileMode) || fromTab == toTab) {
      return;
    }

    // A timings callback may contain frames that were already rendered before
    // the callback reaches the framework. Keep the current frame's engine
    // timestamp so we can select only the next frame caused by this switch.
    _selectionFrameTimestampMicros =
        WidgetsBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
    _pendingTabSwitch = _PendingTabSwitch(
      role: role,
      fromTab: fromTab,
      toTab: toTab,
    );
    if (_isListening) {
      return;
    }

    _isListening = true;
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    final pendingTabSwitch = _pendingTabSwitch;
    if (pendingTabSwitch == null || timings.isEmpty) {
      return;
    }

    final selectionFrameTimestampMicros = _selectionFrameTimestampMicros;
    final targetFrame = timings.where((timing) {
      if (selectionFrameTimestampMicros == null) {
        return true;
      }
      return timing.timestampInMicroseconds(FramePhase.buildStart) >
          selectionFrameTimestampMicros;
    }).firstOrNull;
    if (targetFrame == null) {
      return;
    }

    final buildDelayMicros = selectionFrameTimestampMicros == null
        ? 0
        : targetFrame.timestampInMicroseconds(FramePhase.buildStart) -
              selectionFrameTimestampMicros;
    final rasterFinishDelayMicros = selectionFrameTimestampMicros == null
        ? 0
        : targetFrame.timestampInMicroseconds(FramePhase.rasterFinish) -
              selectionFrameTimestampMicros;
    _log(
      'home tab ${pendingTabSwitch.role} '
      '${pendingTabSwitch.fromTab} → ${pendingTabSwitch.toTab}: '
      'next build=${targetFrame.buildDuration.inMilliseconds}ms, '
      'raster=${targetFrame.rasterDuration.inMilliseconds}ms, '
      'selection→build=${buildDelayMicros ~/ 1000}ms, '
      'selection→raster=${rasterFinishDelayMicros ~/ 1000}ms',
    );
    _pendingTabSwitch = null;
    _selectionFrameTimestampMicros = null;
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    _isListening = false;
  }

  void dispose() {
    if (_isListening) {
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
      _isListening = false;
    }
    _pendingTabSwitch = null;
    _selectionFrameTimestampMicros = null;
  }
}

class _PendingTabSwitch {
  const _PendingTabSwitch({
    required this.role,
    required this.fromTab,
    required this.toTab,
  });

  final String role;
  final int fromTab;
  final int toTab;
}
