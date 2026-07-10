import 'dart:ui' show FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Associates the first rendered frame after a Home tab selection with that
/// selection. This is intentionally diagnostic-only and does not affect UI.
class HomeTabPerformanceMonitor {
  HomeTabPerformanceMonitor({void Function(String message)? log})
    : _log = log ?? debugPrint;

  final void Function(String message) _log;
  _PendingTabSwitch? _pendingTabSwitch;
  bool _isListening = false;

  void beginTabSwitch({
    required String role,
    required int fromTab,
    required int toTab,
  }) {
    if (!kDebugMode || fromTab == toTab) {
      return;
    }

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

    final timing = timings.last;
    _log(
      '[Home tab] ${pendingTabSwitch.role} '
      '${pendingTabSwitch.fromTab} → ${pendingTabSwitch.toTab}: '
      'build=${timing.buildDuration.inMilliseconds}ms, '
      'raster=${timing.rasterDuration.inMilliseconds}ms',
    );
    _pendingTabSwitch = null;
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    _isListening = false;
  }

  void dispose() {
    if (_isListening) {
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
      _isListening = false;
    }
    _pendingTabSwitch = null;
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
