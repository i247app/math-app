import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_details_composition.dart';

class WelcomeDetailsScreen extends StatelessWidget {
  const WelcomeDetailsScreen({
    super.key,
    required this.onSignup,
    required this.onBack,
  });

  final VoidCallback onSignup;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: WelcomeDetailsComposition(onSignup: onSignup, onBack: onBack),
      ),
    );
  }
}
