import 'package:flutter/material.dart';
// Using an absolute package path bypasses relative directory confusion completely
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WelcomeComposition(
          onStart: onStart,
          onLogin: onLogin,
        ),
      ),
    );
  }
}