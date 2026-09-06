import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_composition.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLogin;

  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.pageBackground,
      body: WelcomeComposition(onStart: onStart, onLogin: onLogin),
    );
  }
}
