import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class WelcomeIntroLoading extends StatefulWidget {
  const WelcomeIntroLoading({super.key});

  @override
  State<WelcomeIntroLoading> createState() => _WelcomeIntroLoadingState();
}

class _WelcomeIntroLoadingState extends State<WelcomeIntroLoading>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.themeColors.brandStrong;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: context.getText(AppKeys.loading),
      liveRegion: true,
      child: SizedBox(
        width: 64,
        height: 32,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final phase = (_controller.value - index * 0.16) % 1.0;
              final pulse = reduceMotion
                  ? 1.0
                  : phase < 0.5
                  ? math.sin(phase * 2 * math.pi)
                  : 0.0;
              return Transform.translate(
                offset: Offset(0, reduceMotion ? 0 : -6 * pulse),
                child: Opacity(
                  opacity: 0.35 + 0.65 * pulse,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 10),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
