import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/features/auth/widgets/welcome/welcome_details_composition.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_style.dart';

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
        color: WelcomeStyle.background,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: WelcomeDetailsComposition(
                          onStart: onStart,
                          onBack: onBack,
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
}
