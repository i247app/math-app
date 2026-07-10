import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';
import 'package:numi/features/auth/widgets/passcode/passcode_action_button.dart';
import 'package:numi/features/auth/widgets/passcode/passcode_input_row.dart';

enum PasscodeScreenMode { setup, unlock, verify }

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({
    super.key,
    required this.mode,
    required this.onBack,
    required this.onSubmit,
    this.onSkip,
    this.titleKey,
    this.primaryLabelKey,
    this.isBusy = false,
    this.errorText,
    this.errorId = 0,
  });

  final PasscodeScreenMode mode;
  final VoidCallback onBack;
  final Future<String?> Function(String passcode) onSubmit;
  final VoidCallback? onSkip;
  final String? titleKey;
  final String? primaryLabelKey;
  final bool isBusy;
  final String? errorText;
  final int errorId;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  static const passcodeLength = 4;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final ValueNotifier<int> _digitRevision;
  String? _firstPasscode;
  String? _localError;
  int _lastErrorId = 0;

  static const _backIconAsset = 'assets/images/pin_figma_back.svg';

  bool get _isConfirmingSetup =>
      widget.mode == PasscodeScreenMode.setup && _firstPasscode != null;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      passcodeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(passcodeLength, (_) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _digitRevision = ValueNotifier(0);
    _lastErrorId = widget.errorId;
    _requestPasscodeFocus();
  }

  @override
  void didUpdateWidget(covariant PasscodeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorId != _lastErrorId && widget.errorText != null) {
      _lastErrorId = widget.errorId;
      _showError(widget.errorText!);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _digitRevision.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateDigit(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      _clearLocalErrorOrNotify();
      return;
    }

    var nextIndex = index;
    for (final digit in digits.split('')) {
      if (nextIndex >= _controllers.length) {
        break;
      }
      _controllers[nextIndex].text = digit;
      _controllers[nextIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      nextIndex++;
    }

    if (nextIndex < _focusNodes.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
    _clearLocalErrorOrNotify();
  }

  void _handleEmptyBackspace(int index) {
    if (index == 0) {
      return;
    }
    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    _clearLocalErrorOrNotify();
  }

  void _clearLocalErrorOrNotify() {
    if (_localError != null) {
      setState(() => _localError = null);
      return;
    }
    _digitRevision.value++;
  }

  Future<void> _handleSubmit() async {
    final passcode = _enteredPasscode;
    if (passcode.length < passcodeLength || widget.isBusy) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    if (widget.mode == PasscodeScreenMode.setup && !_isConfirmingSetup) {
      setState(() => _firstPasscode = passcode);
      _clearDigits(focusFirst: true);
      return;
    }

    if (_isConfirmingSetup && passcode != _firstPasscode) {
      _firstPasscode = null;
      _showError(context.getText(AppKeys.passcodeMismatch));
      return;
    }

    final error = await widget.onSubmit(passcode);
    if (error != null && mounted) {
      _showError(error);
    }
  }

  String get _enteredPasscode =>
      _controllers.map((controller) => controller.text).join();

  void _showError(String message) {
    HapticFeedback.mediumImpact();
    setState(() => _localError = message);
    _clearDigits(focusFirst: true);
    _shakeController.forward(from: 0);
  }

  void _clearDigits({bool focusFirst = false}) {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (focusFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNodes.first.requestFocus();
        }
      });
    }
  }

  void _requestPasscodeFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final errorText = _localError ?? widget.errorText;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: AuthLayout(
        onBack: widget.onBack,
        title: _titleText(context),
        horizontalPadding: 0,
        compactBodyGap: 46,
        regularBodyGap: 54,
        mascotShape: BoxShape.rectangle,
        mascotShadowAlpha: 0.10,
        mascotShadowBlur: 24,
        mascotShadowOffset: const Offset(0, 16),
        backIconAsset: _backIconAsset,
        bodyBuilder: (context, compact) {
          return ValueListenableBuilder<int>(
            valueListenable: _digitRevision,
            builder: (context, _, child) {
              final isFull = _controllers.every(
                (controller) => controller.text.isNotEmpty,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final offset =
                            math.sin(_shakeController.value * math.pi * 6) *
                            9 *
                            (1 - _shakeController.value);
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: PasscodeInputRow(
                        controllers: _controllers,
                        focusNodes: _focusNodes,
                        hasError: errorText != null,
                        onChanged: _updateDigit,
                        onEmptyBackspace: _handleEmptyBackspace,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 26),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: errorText == null
                            ? Text(
                                context.getText(_subtitleKey),
                                key: ValueKey(_subtitleKey),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.andika(
                                  color: colors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                  letterSpacing: 0,
                                ),
                              )
                            : Text(
                                errorText,
                                key: ValueKey(errorText),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.andika(
                                  color: colors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: compact ? 30 : 36),
                    SizedBox(
                      width: 230,
                      height: 58,
                      child: PasscodeActionButton(
                        label: context.getText(_primaryLabelKey),
                        onPressed: isFull && !widget.isBusy
                            ? _handleSubmit
                            : null,
                        isBusy: widget.isBusy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PasscodeTextAction(
                      label: context.getText(_secondaryLabelKey),
                      onPressed: widget.isBusy ? null : _secondaryAction,
                    ),
                    SizedBox(height: compact ? 28 : 44),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  VoidCallback? get _secondaryAction {
    if (widget.mode == PasscodeScreenMode.unlock) {
      return widget.onBack;
    }
    return widget.onSkip;
  }

  String get _secondaryLabelKey {
    if (widget.mode == PasscodeScreenMode.unlock) {
      return AppKeys.passcodeLoginWithPhone;
    }
    return AppKeys.passcodeSkip;
  }

  String _titleText(BuildContext context) {
    if (widget.mode == PasscodeScreenMode.unlock) {
      return 'PIN';
    }
    return context.getText(_titleKey);
  }

  String get _titleKey {
    final explicit = widget.titleKey;
    if (explicit != null) {
      return explicit;
    }
    if (_isConfirmingSetup) {
      return AppKeys.confirmPasscodeTitle;
    }
    return switch (widget.mode) {
      PasscodeScreenMode.setup => AppKeys.createPasscodeTitle,
      PasscodeScreenMode.unlock => AppKeys.unlockPasscodeTitle,
      PasscodeScreenMode.verify => AppKeys.verifyPasscodeTitle,
    };
  }

  String get _primaryLabelKey {
    final explicit = widget.primaryLabelKey;
    if (explicit != null) {
      return explicit;
    }
    return switch (widget.mode) {
      PasscodeScreenMode.setup => AppKeys.passcodeContinue,
      PasscodeScreenMode.unlock => AppKeys.passcodeLogin,
      PasscodeScreenMode.verify => AppKeys.passcodeContinue,
    };
  }

  String get _subtitleKey {
    if (_isConfirmingSetup) {
      return AppKeys.confirmPasscodeSubtitle;
    }
    return switch (widget.mode) {
      PasscodeScreenMode.setup => AppKeys.createPasscodeSubtitle,
      PasscodeScreenMode.unlock => AppKeys.unlockPasscodeSubtitle,
      PasscodeScreenMode.verify => AppKeys.verifyPasscodeSubtitle,
    };
  }
}

class _PasscodeTextAction extends StatelessWidget {
  const _PasscodeTextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final color = onPressed == null
        ? colors.textPrimary.withValues(alpha: 0.45)
        : colors.textPrimary;

    return Center(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 20 / 16,
              decoration: TextDecoration.underline,
              decorationColor: color,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
