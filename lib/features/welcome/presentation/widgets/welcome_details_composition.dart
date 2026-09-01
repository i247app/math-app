import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/presentation/widgets/welcome_details_controls.dart';
import 'package:numi/features/welcome/presentation/widgets/welcome_details_feature_grid.dart';
import 'package:numi/features/welcome/presentation/widgets/welcome_details_header.dart';

class WelcomeDetailsComposition extends StatelessWidget {
  const WelcomeDetailsComposition({
    super.key,
    required this.onStart,
    required this.onBack,
  });

  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.pageBackgroundTop,
                  colors.pageBackground,
                  colors.surface,
                ],
                stops: const [0, 0.42, 1],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.noScaling),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WelcomeDetailsHeader(
                          onBack: onBack,
                          isTablet: isTablet,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const WelcomeDetailsFeatureGrid(),
                              WelcomeDetailsControls(onStart: onStart),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
