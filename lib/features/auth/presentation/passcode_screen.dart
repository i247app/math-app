import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

enum PasscodeScreenMode {
  setup,
  unlock,
  verify,
}

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
  String? _firstPasscode;
  String? _localError;
  int _lastErrorId = 0;

  static const _mascotAsset = 'assets/images/pin_figma_mascot.png';
  static const _backIconAsset = 'assets/images/pin_figma_back.svg';
  static const _arrowIconAsset = 'assets/images/pin_figma_arrow.svg';

  bool get _isConfirmingSetup =>
      widget.mode == PasscodeScreenMode.setup && _firstPasscode != null;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(passcodeLength, (_) => TextEditingController());
    _focusNodes = List.generate(passcodeLength, (_) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _lastErrorId = widget.errorId;
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
      setState(() => _localError = null);
      return;
    }

    var nextIndex = index;
    for (final digit in digits.split('')) {
      if (nextIndex >= _controllers.length) {
        break;
      }
      _controllers[nextIndex].text = digit;
      _controllers[nextIndex].selection =
          const TextSelection.collapsed(offset: 1);
      nextIndex++;
    }

    if (nextIndex < _focusNodes.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
    setState(() => _localError = null);
  }

  void _handleEmptyBackspace(int index) {
    if (index == 0) {
      return;
    }
    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    setState(() => _localError = null);
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

  @override
  Widget build(BuildContext context) {
    final isFull = _controllers.every((controller) => controller.text != '');
    final errorText = _localError ?? widget.errorText;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            const Positioned.fill(
                              child: ColoredBox(color: Colors.white),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    Positioned(
                                      left: 20,
                                      top: 28,
                                      width: 44,
                                      height: 44,
                                      child: _PasscodeBackButton(
                                        iconAsset: _backIconAsset,
                                        onPressed: widget.onBack,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 90,
                                      height: 198,
                                      child: Center(
                                        child: SizedBox(
                                          width: 220,
                                          height: 198,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 25,
                                                  offset: const Offset(0, 25),
                                                ),
                                              ],
                                            ),
                                            child: ClipRect(
                                              child: Image.asset(
                                                _mascotAsset,
                                                width: 220,
                                                height: 198,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 279,
                                      child: Center(
                                        child: SizedBox(
                                          width: 280,
                                          child: Text(
                                            context.getText(_titleKey),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.andika(
                                              color: const Color(0xFF001741),
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                              height: 36 / 30,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 333,
                                      child: Center(
                                        child: SizedBox(
                                          width: 294,
                                          child: Text(
                                            context.getText(_subtitleKey),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.andika(
                                              color: const Color(0xFF001741),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              height: 24.75 / 18,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 411,
                                      child: AnimatedBuilder(
                                        animation: _shakeController,
                                        builder: (context, child) {
                                          final offset = math.sin(
                                                _shakeController.value *
                                                    math.pi *
                                                    6,
                                              ) *
                                              9 *
                                              (1 - _shakeController.value);
                                          return Transform.translate(
                                            offset: Offset(offset, 0),
                                            child: child,
                                          );
                                        },
                                        child: _PasscodeInputRow(
                                          controllers: _controllers,
                                          focusNodes: _focusNodes,
                                          hasError: errorText != null,
                                          onChanged: _updateDigit,
                                          onEmptyBackspace:
                                              _handleEmptyBackspace,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 34,
                                      right: 34,
                                      top: 491,
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        child: errorText == null
                                            ? const SizedBox(height: 24)
                                            : Text(
                                                errorText,
                                                key: ValueKey(errorText),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.andika(
                                                  color:
                                                      const Color(0xFFD9534F),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.25,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 542,
                                      height: 58,
                                      child: Center(
                                        child: SizedBox(
                                          width: 230,
                                          height: 58,
                                          child: _PasscodeActionButton(
                                            label: context
                                                .getText(_primaryLabelKey),
                                            onPressed: isFull && !widget.isBusy
                                                ? _handleSubmit
                                                : null,
                                            isBusy: widget.isBusy,
                                            arrowAsset: _arrowIconAsset,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (widget.onSkip != null)
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        top: 626,
                                        child: _PasscodeSkipButton(
                                          label: context
                                              .getText(AppKeys.passcodeSkip),
                                          onPressed: widget.isBusy
                                              ? null
                                              : widget.onSkip,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String get _titleKey {
    if (_isConfirmingSetup) {
      return AppKeys.confirmPasscodeTitle;
    }
    final explicit = widget.titleKey;
    if (explicit != null) {
      return explicit;
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
      PasscodeScreenMode.unlock => AppKeys.passcodeUnlock,
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

class _PasscodeBackButton extends StatelessWidget {
  const _PasscodeBackButton({
    required this.iconAsset,
    required this.onPressed,
  });

  final String iconAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }
}

class _PasscodeInputRow extends StatelessWidget {
  const _PasscodeInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
    required this.onEmptyBackspace,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onEmptyBackspace;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
          child: SizedBox(
            width: 64,
            height: 70,
            child: _PasscodeDigitBox(
              controller: controllers[index],
              focusNode: focusNodes[index],
              autofocus: index == 0,
              textInputAction:
                  index == 3 ? TextInputAction.done : TextInputAction.next,
              hasError: hasError,
              onChanged: (value) => onChanged(index, value),
              onEmptyBackspace: () => onEmptyBackspace(index),
            ),
          ),
        );
      }),
    );
  }
}

class _PasscodeDigitBox extends StatelessWidget {
  const _PasscodeDigitBox({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.textInputAction,
    required this.hasError,
    required this.onChanged,
    required this.onEmptyBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmptyBackspace;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onEmptyBackspace();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? const Color(0xFFD9534F) : const Color(0xFF6E7474),
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDCBFC8),
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            textInputAction: textInputAction,
            obscureText: true,
            obscuringCharacter: '•',
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            onTap: () {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            },
            style: GoogleFonts.andika(
              color: AppColors.ink,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class _PasscodeActionButton extends StatelessWidget {
  const _PasscodeActionButton({
    required this.label,
    required this.onPressed,
    required this.arrowAsset,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String arrowAsset;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 230,
        height: 58,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38898D),
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFB5BFC2),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: GoogleFonts.andika(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      arrowAsset,
                      width: 13.33,
                      height: 13.33,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PasscodeSkipButton extends StatelessWidget {
  const _PasscodeSkipButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: onPressed == null
                  ? const Color(0xFF001741).withValues(alpha: 0.45)
                  : const Color(0xFF001741),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 20 / 16,
              decoration: TextDecoration.underline,
              decorationColor: onPressed == null
                  ? const Color(0xFF001741).withValues(alpha: 0.45)
                  : const Color(0xFF001741),
            ),
          ),
        ),
      ),
    );
  }
}
