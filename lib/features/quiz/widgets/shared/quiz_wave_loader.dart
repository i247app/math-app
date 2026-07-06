import 'dart:math' as math;

import 'package:flutter/material.dart';

class QuizWaveLoader extends StatefulWidget {
  const QuizWaveLoader({
    super.key,
    required this.scale,
    required this.letterStyle,
    this.message,
    this.messageStyle,
    this.messageHorizontalPadding = 32,
    this.leading,
    this.leadingSpacing = 22,
  });

  final double scale;
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
                widget.leading!,
                SizedBox(height: widget.leadingSpacing * widget.scale),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (controller.value - (index * 0.075)) % 1.0;
                  final lift = delayedProgress <= 0.20
                      ? -34 *
                            widget.scale *
                            math.sin(delayedProgress / 0.20 * math.pi)
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, lift),
                    child: Text(letters[index], style: widget.letterStyle),
                  );
                }),
              ),
              if (widget.message != null) ...[
                SizedBox(height: 18 * widget.scale),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.messageHorizontalPadding * widget.scale,
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
