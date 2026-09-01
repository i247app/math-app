import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/games/domain/models/numi_farm/numi_farm_data.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

part 'numi_farm/harvest_stage.dart';
part 'numi_farm/harvest_header_widgets.dart';
part 'numi_farm/harvest_field_widgets.dart';
part 'numi_farm/choice_stage.dart';
part 'numi_farm/choice_widgets.dart';
part 'numi_farm/result_widgets.dart';

const _farmGreen = Color(0xFF38898B);
const _farmDeepGreen = Color(0xFF176B55);
const _farmLeaf = Color(0xFF65B83C);
const _farmOrange = Color(0xFFF58B32);
const _farmInk = Color(0xFF253228);
const _farmMuted = Color(0xFF68746B);
const _farmCream = Color(0xFFFFFBEE);
const _farmSoil = Color(0xFF9B653D);
const _correctSound = 'sounds/effects/correct.wav';
const _incorrectSound = 'sounds/effects/incorrect.wav';

mixin _FarmSessionMixin<T extends StatefulWidget> on State<T> {
  final AudioPlayer _effectPlayer = AudioPlayer();
  final Stopwatch _stopwatch = Stopwatch();
  final GuardedExitController<bool> farmExitController =
      GuardedExitController<bool>();
  Timer? _clockTimer;
  Duration _elapsed = Duration.zero;

  Duration get elapsed => _elapsed;

  void startFarmSession() {
    _stopwatch.start();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = _stopwatch.elapsed);
      }
    });
  }

  void stopFarmSession() {
    _stopwatch.stop();
    _clockTimer?.cancel();
    _clockTimer = null;
    if (mounted) {
      setState(() => _elapsed = _stopwatch.elapsed);
    }
  }

  Future<void> playCorrectSound() => _playEffect(_correctSound);

  Future<void> playIncorrectSound() => _playEffect(_incorrectSound);

  Future<bool> confirmFarmExit(BuildContext context) async {
    stopFarmSession();
    final shouldExit = await showExitConfirmationDialog(
      context,
      titleKey: AppKeys.gamesExitTitle,
      messageKey: AppKeys.gamesExitMessage,
      stayActionKey: AppKeys.gamesKeepPlaying,
      exitActionKey: AppKeys.gamesFarmBackToMap,
    );
    if (!shouldExit && mounted) {
      startFarmSession();
    }
    return shouldExit;
  }

  Future<void> _playEffect(String assetPath) async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Audio feedback must never block the learning flow.
    }
  }

  void disposeFarmSession() {
    _clockTimer?.cancel();
    _stopwatch.stop();
    unawaited(_effectPlayer.dispose());
  }
}

String _formatElapsed(Duration duration) {
  final minutes = duration.inMinutes.remainder(100).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

int _starsForScore({required int correct, required int total}) {
  if (correct == total) {
    return 3;
  }
  if (correct * 10 >= total * 6) {
    return 2;
  }
  if (correct > 0) {
    return 1;
  }
  return 0;
}
