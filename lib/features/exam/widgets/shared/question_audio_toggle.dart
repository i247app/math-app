import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/data/exam_question_audio_settings.dart';

class QuestionAudioToggle extends StatefulWidget {
  const QuestionAudioToggle({super.key});

  @override
  State<QuestionAudioToggle> createState() => _QuestionAudioToggleState();
}

class _QuestionAudioToggleState extends State<QuestionAudioToggle> {
  final _settings = const ExamQuestionAudioSettings();
  bool _enabled = true;
  bool _ready = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _settings.readEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _ready = true;
    });
  }

  Future<void> _toggle() async {
    if (!_ready || _saving) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enabled = !_enabled;
      _saving = true;
    });
    try {
      await _settings.saveEnabled(_enabled);
    } catch (_) {
      if (mounted) setState(() => _enabled = !_enabled);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: _enabled,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          tooltip: context.getText(
            _enabled ? AppKeys.examMuteAutoplay : AppKeys.examEnableAutoplay,
          ),
          onPressed: _ready && !_saving ? _toggle : null,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFF8A24),
            disabledBackgroundColor: const Color(0xFFFF8A24),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 3),
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          icon: Icon(
            _enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            size: 25,
          ),
        ),
      ),
    );
  }
}
