import 'dart:math' as math;

import 'package:flutter/material.dart';

class QuizWaveLoader extends StatefulWidget {
  const QuizWaveLoader({
    super.key,
    required this.letterStyle,
    this.message,
    this.messageStyle,
    this.messageHorizontalPadding = 32,
    this.leading,
    this.leadingSpacing = 22,
  });
  final TextStyle letterStyle;
  final String? message;
  final TextStyle? messageStyle;
  final double messageHorizontalPadding;
  final Widget? leading;
  final double leadingSpacing;

  @override
  State<QuizWaveLoader> createState() => _QuizWaveLoaderState();
}

class _QuizWaveLoaderState extends State<QuizWaveLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['n', 'u', 'm', 'i', 'n', 'u', 'm', 'i'];

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: widget.leadingSpacing),
                  child: widget.leading!,
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (controller.value - (index * 0.075)) % 1.0;
                  final lift = delayedProgress <= 0.20
                      ? -34 * math.sin(delayedProgress / 0.20 * math.pi)
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, lift),
                    child: Text(letters[index], style: widget.letterStyle),
                  );
                }),
              ),
              if (widget.message != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.messageHorizontalPadding,
                    18,
                    widget.messageHorizontalPadding,
                    0,
                  ),
                  child: Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: widget.messageStyle,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
