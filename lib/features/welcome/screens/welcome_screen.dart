import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_composition.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback onAssessment;
  final VoidCallback onLogin;

  const WelcomeScreen({
    super.key,
    required this.onSignup,
    required this.onAssessment,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.pageBackground,
      body: WelcomeComposition(
        onSignup: onSignup,
        onAssessment: onAssessment,
        onLogin: onLogin,
      ),
    );
  }
}
