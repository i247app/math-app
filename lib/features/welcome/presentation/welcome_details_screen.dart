import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/features/welcome/widgets/welcome_details_composition.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class WelcomeDetailsScreen extends StatelessWidget {
  const WelcomeDetailsScreen({
    super.key,
    required this.onStart,
    required this.onBack,
  });

  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: AppColors.pageBackground,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: WelcomeDetailsComposition(
                  onStart: onStart,
                  onBack: onBack,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
